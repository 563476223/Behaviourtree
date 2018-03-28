--======================================================
-- Author: FX
-- Purpose: 循环节点
-- Date: 2018-03-28 03:17:19
--======================================================

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

return  LoopNode