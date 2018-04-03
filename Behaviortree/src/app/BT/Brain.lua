--======================================================
-- Author: FX
-- Purpose:大脑
-- Date: 2018-03-23 11:20:43
--======================================================
BrainManager = class('BrainManager')  --brain管理

function BrainManager:ctor(...)
	self.instances = {}  --实例集合
	self.updaters = {} --更新集合
    self.tickwaiters = {} --等待集合
end

--添加大脑
function BrainManager:addInstance(brain)
	self.instances[brain] = self.updaters
	self.updaters[brain] = true
end

--移除
function BrainManager:removeInstance(brain)
    self.updaters[brain] = nil
    for k,v in pairs(self.tickwaiters) do --等待集合
        v[brain] = nil --
    end
    self.instances[brain] = nil
end

--更新
--当前帧数，使用帧进行计算
function BrainManager:onUpdate(current_tick)
	local waiters = self.tickwaiters[current_tick] --获取当前帧等待的brain
	if waiters then
		for k, v in pairs(waiters) do
			self.updaters[k] = true
			self.instances[k] = self.updaters
		end
		self.tickwaiters[current_tick] = nil
	end
	
	for k, v in pairs(self.updaters) do --更新
		k:OnUpdate() --更新可能由前置条件
		local sleep_amount = k:GetSleepTime()
		if sleep_amount then
			if sleep_amount > GetTickTime() then --必须比一帧的时间大，不然没有必要休眠
				self:sleep(k, sleep_amount)
			end
		end
	end
end


--GetTickTime 每帧时间，固定值
--GetTick 当前运行的总帧数
function BrainManager:sleep(brain, time_to_waite)
	--获取需要休眠的帧数
	local sleep_ticks = time_to_wait / GetTickTime()
	
	if sleep_ticks == 0 then sleep_ticks = 1 end --下一帧在执行
	
	local target_tick = math.floor(GetTick() + sleep_ticks)
	
    if target_tick > GetTick() then --休眠的帧数满足了
        
		local waiters = self.tickwaiters[target_tick]
		
		if not waiters then
			waiters = {}
			self.tickwaiters[target_tick] = waiters
        end
        
		self:pushToList(brain,waiters)
	end
end

--放入列表
--将update里面的bran，放入新的list
function BrainManager:pushToList(brain, list)
	local old_list = self.instances[brain]
	
    if old_list and old_list ~= list then
        
        old_list[brain] = nil
        
		self.instances[inst] = list
		
		if list then
			list[inst] = true
		end
	end
end


--------具体大脑
Brain = class("Brain")

function Brain:Start()
	if self.OnStart then
		self:OnStart()
    end
    
    BrainManager:addInstance(self)
    
	if self.OnInitializationComplete then --初始化完成时候回调
		self:OnInitializationComplete()
	end
end

function Brain:OnUpdate()
	
	if self.DoUpdate then --当前大脑更新之前回调
		self:DoUpdate()
	end
	
	if self.bt then
		self.bt:Update()
	end
end

function Brain:Stop()
	if self.OnStop then
		self:OnStop()
	end
	if self.bt then
		self.bt:Stop()
	end
	BrainManager:removeInstance(self)
end

return Brain 