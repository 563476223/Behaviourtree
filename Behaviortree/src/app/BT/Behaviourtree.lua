--======================================================
-- Author: fx
-- Purpose:
-- Date: 2018-03-29 02:30:52
--======================================================

RUNNING       = 'RUNNING'
READY		 = 'READY'
FAILED        = 'FAILED'
SUCCESS       = 'SUCCESS'

---------------BT tree----------

local BT = class("BT")

function BT:ctor( root  )
	self.root = root
end

--强制更新
function BT:forceUpdate(  )
	self.forceupdate = true
end

--更新root
function BT:update(  )
	self.root:update()
	self.forceupdate = false
end

--获取休眠时间
function BT:getSleepTime(  )
	if self.forceupdate then
		return 0
	end
	return self.root:getTreeSleepTime()
end

--暂停
function BT:stop(  )
	self.root:stop()
end

----------------------------behaviorbase--------------------


local BehaviourNode = class("BehaviourNode")

function BehaviourNode:ctor(name, children)
	self.name = name or ''
	self.children = children
	self.nextupdatetime = nil --下次更新时间
	self.status = g_STATUS.READY
	self.parent = nil
	if self.children then
		for _, v in pairs(self.children) do
			v.parent = self
		end
	end
end

--设置当前树的休眠时间，只能在叶节点设置
function BehaviourNode:sleep(t)
	self.nextupdatetime = GetTime() + t --当前时间+设置时间
end


--获取当前树的休眠时间,只能放在行为节点里面
function BehaviourNode:getSleepTime()
	if self.status == g_STATUS.RUNNING and not self.children then
		if self.nextupdatetime then
			local time_to = self.nextupdatetime - GetTime()
			if time_to < 0 then
				time_to = 0
			end
			return time_to
		end
		return 0
	end
	return nil
end

--获取这颗树的最小休眠时间
function BehaviourNode:getTreeSleepTime()
	local sleeptime = nil
	
	if self.children then
		for _, v in pairs(self.children) do
			if v.status == g_STATUS.RUNNING then
				local t = v:getTreeSleepTime()
				if t and(not sleeptime or sleeptime > t) then
					sleeptime = t
				end
			end
		end
	end
	
	local my_t = self:getSleepTime()
	
	if my_t and(not sleeptime or sleeptime > my_t) then
		sleeptime = my_t
	end
	
	return sleeptime
end

--更新
function BehaviourNode:update()
	self.status = g_STATUS.FAILED
end

--重置
function BehaviourNode:reset()
	if self.status ~= g_STATUS.READY then
		self.status = g_STATUS.READY
		if self.children then
			for _, v in pairs(self.children) do
				v:reset()
			end
		end
	end
end

--暂停行为树
function BehaviourNode:stop()
	if type(self.onStop) == 'function' then
		self:onStop()
	end
	if self.children then
		for _, child in pairs(self.children) do
			child:stop()
		end
	end
end

-----------行为节点-----

local ActionNode = class('ActionNode',BehaviourNode)

function ActionNode:ctor( action,name )
    self.action = action
end

function ActionNode:update(  )
    self.action()
    self.status = g_STATUS.SUCCESS
end

----------条件节点--------
local ConditionNode = class('ConditionNode',BehaviourNode)

function ConditionNode:ctor( name,fn )
    self.fn = fn
end

function ConditionNode:update(  )
    if self.fn() then
        self.status = g_STATUS.SUCCESS
    else
        self.status = g_STATUS.FAILED
    end
end

-----------选择节点--------

local SelectorNode = class("SelectorNode",BehaviourNode)

function SelectorNode:ctor(name,child )
	self.idx = 1
end

--结束的标识，success或者faile
function SelectorNode:update(  )

	if self.status ~= g_STATUS.RUNNING then
		self.idx = 1
	end

	while self.idx <= #self.children do
		local child = self.children[self.idx]
		child:update()
		if child.status == g_STATUS.RUNNING or child.status == g_STATUS.SUCCESS then
			self.status = child.status
			return
		end
		self.idx = self.idx + 1
	end
	self.status = g_STATUS.FAILED
end

-----------并行节点------------
local ParallelNode = class("ParallelNode", BehaviourNode)

function ParallelNode:ctor()
	
end

function ParallelNode:update()
	local done = true
	
	for _, child in ipairs(self.children) do
		
		child:update()
		if child.status == g_STATUS.FAILED then
			self.status = g_STATUS.FAILED
			return
		end
		
		if child.status == g_STATUS.RUNNING then --只要有一个未完成直接返回false
			done = false
		end
	end
	
	if done then
		self.status = g_STATUS.SUCCESS
	else
		self.status = g_STATUS.FAILED
	end
end

--------顺序节点-------------
local SequenceNode = class("SequenceNode", BehaviourNode)

function SequenceNode:ctor(name, child)
	self.idx = 1
end

function SequenceNode:update()
	
	if self.status ~= g_STATUS.RUNNING then
		self.idx = 1
	end
	
	while self.idx <= #self.children do
		
		local child = self.children[self.idx]
		
		if self.status ~= g_STATUS.SUCCESS then
			child:update()
			
			if child.status == g_STATUS.RUNNING or child.status == g_STATUS.FAILED then
				self.status = child.status
				return
			end
		end
		
		self.idx = self.idx + 1
	end
	
	self.status = g_STATUS.SUCCESS
end

-------------循环节点------------


local LoopNode = class("LoopNode",cc.load('mvc').BehaviourNode)

function LoopNode:ctor( name,maxpre )
	self.maxpre = maxpre or 1--循环的次数
	self.idx = 1
	self.rep = 0
end

function LoopNode:update(  )

	if self.status ~= g_STATUS.RUNNING then
		self.idx = 1
	end

	while self.idx <= #self.children do
		local child = self.children[self.idx]

		if self.status ~= g_STATUS.SUCCESS then
			child:update()
			if child.status == g_STATUS.RUNNING or child.status == g_STATUS.FAILED then
				self.status = child.status
				return
			end
		end

		self.idx = self.idx + 1
	end

	self.idx = 1

	self.rep = self.rep + 1

	if self.rep >= self.maxpre then
		self.status = g_STATUS.SUCCESS
	else
		for _,child in ipairs(self.children) do
			child:reset()
		end
	end
end

-----装饰节点----
local DecoratorNode = class('DecoratorNode',BehaviourNode)

function DecoratorNode:ctor( name,child )
    
end

-------条件等待节点----

local ConditionWaitNode = class('ConditionWaitNode',BehaviourNode)

function ConditionWaitNode:ctor( fn,name )
    self.fn = fn
end

function ConditionWaitNode:update(  )
    if self.fn() then
        self.status = g_STATUS.SUCCESS
    else
        self.status = g_STATUS.RUNNING
    end
end



