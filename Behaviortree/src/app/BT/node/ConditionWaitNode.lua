--======================================================
-- Author: Fx
-- Purpose:条件等待节点
-- Date:   2018-03-24 03:09:56
--======================================================
local ConditionWaitNode = class('ConditionWaitNode',cc.load('mvc').BehaviourNode)

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

return ConditionWaitNode