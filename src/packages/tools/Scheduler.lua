local Scheduler = class("Scheduler")
local s = cc.Director:getInstance():getScheduler()

-- 每一帧事件调用执行
function Scheduler.scheduleFunc(func,interval)
	assert(func ~= Scheduler,"please use dot to call Scheduler.scheduleFunc ...")
	return s:scheduleScriptFunc(func,interval or 0,false)
end

-- 终止某个定时器执行
function Scheduler.terminateFunc(handler)
	assert(handler ~= Scheduler,"please use dot to call Scheduler.terminateFunc ...")
	return s:unscheduleScriptEntry(handler)
end

-- 延时执行函数,其中有两个隐含功能,一个是0表示下一帧执行,同时能够把非UI线程抛回UI线程执行
function Scheduler.performDelayFunc(func,delay)
	assert(func ~= Scheduler,"please use dot to call Scheduler.performDelayFunc ...")
	assert(type(func) == "function","please specialize func to do in Scheduler.performDelayFunc ...")
	local handler = 0
	handler = s:scheduleScriptFunc(function (dt)
        s:unscheduleScriptEntry(handler)
        if func then
			func(dt)
		end
	end,delay or 0,false)
	return handler
end

function Scheduler.scheduleGlobal( ... )
	return Scheduler.scheduleFunc( ... )
end

function Scheduler.unscheduleGlobal( ... )
	return Scheduler.terminateFunc( ... )
end

function Scheduler.performWithDelayGlobal( ... )
	return Scheduler.performDelayFunc( ... )
end


function Scheduler.update( ... )
	return Scheduler.scheduleFunc( ... )
end

function Scheduler.stop( ... )
	return Scheduler.terminateFunc( ... )
end

function Scheduler.delay( ... )
	return Scheduler.performDelayFunc( ... )
end

return Scheduler