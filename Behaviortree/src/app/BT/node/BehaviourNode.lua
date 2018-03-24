--======================================================
-- Author: 付星
-- Purpose:行为根节点
-- Date: 2018-03-23 11:56:12
--======================================================
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



return BehaviourNode 