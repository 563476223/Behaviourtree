-----------------------------------------------------------
---------------- expand Cocos2dx functions ----------------
-----------------------------------------------------------
local cc = cc

device.isPhone = (device.platform == "android" or device.platform == "ios")


function g_Scheduler.stopFunc(schID)
	return cc.load("tools").Scheduler.terminateFunc(schID)
end

-- SceneBase function
local orgSceneBaseCtor = cc.load("mvc").SceneBase.ctor
cc.load("mvc").SceneBase.ctor = function (self, app, name)
    orgSceneBaseCtor(self,app, name)
    self:findBtnClose();
end

-- SceneBase function
cc.load("mvc").SceneBase.findBtnClose = function(self)
    if (not self.mLayout) then
        return
    end
    local close = self.mLayout:seekByName("btnClose");
    if(close)then
        close:addClickEventListener(function()
                                   g_AudioEngine.playEffect(g_HallConfig.buttonClickPath);
                                   self:close();
                                    end);
    end
end

-- 关闭
cc.load("mvc").SceneBase.close = function(self)

    if(self.onClose)then
        self:onClose();
    end
    self.isShow = false;
    g_SceneManager.removeLayout(self, self.showAction);
    return self
end

-- 显示在场景里
cc.load("mvc").SceneBase.showWithScene = function(self, zoder)
    local colorlayer = cc.LayerColor:create(cc.c4b(0,0,0,160))
    self:add(colorlayer,-100)
    zoder = zoder or g_SceneManager.LAYER_ZODER_PANEL;
    if(self.isShow)then return end;
    self.isShow = true;
    self:setVisible(true);
    g_SceneManager.addLayout(self, self.showAction, zoder);
    return self
end
