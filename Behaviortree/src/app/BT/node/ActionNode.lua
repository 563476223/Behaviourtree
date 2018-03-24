--======================================================
-- Author: Fx
-- Purpose:动作节点,直接执行外部方法
-- Date:   2018-03-24 03:10:05
--======================================================

local ActionNode = class('ActionNode',cc.load('node').BehaviourNode)

function ActionNode:ctor( action,name )
    self.action = action
end

function ActionNode:update(  )
    self.action()
    self.status = g_STATUS.SUCCESS
end


return ActionNode