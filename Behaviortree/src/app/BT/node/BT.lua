--======================================================
-- Author: 付星
-- Purpose:行为树根节点
-- Date: 2018-03-23 11:39:28
--======================================================
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


return  BT