--======================================================
-- Author: Fx
-- Purpose:装饰节点 仅有的一个子节点额外添加一些功能
-- Date:   2018-03-24 03:09:24
--======================================================
local DecoratorNode = class('DecoratorNode',cc.load('mvc').BehaviourNode)

function DecoratorNode:ctor( name,child )
    
end

return DecoratorNode