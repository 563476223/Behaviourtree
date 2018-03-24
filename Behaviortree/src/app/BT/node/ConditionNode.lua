--======================================================
-- Author: Fx
-- Purpose:条件节点
-- Date:   2018-03-24 03:09:33
--======================================================
local ConditionNode = class('ConditionNode',cc.load('mvc').BehaviourNode)

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

return ConditionNode