--======================================================
-- Author: FX
-- Purpose: 顺序节点
-- Date: 2018-03-28 03:07:19
--======================================================
local SequenceNode = class("SequenceNode", cc.load('mvc').BehaviourNode)

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

return SequenceNode 