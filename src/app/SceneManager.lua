local SceneManager = {}

SceneManager.LOGIN_SCENE = 1;
SceneManager.HALL_SCENE = 2;
SceneManager.GAME_SCENE = 3;
SceneManager.SHOP_SCENE = 4;

-- 显示层级
SceneManager.LAYER_ZODER_HALL = 0;
SceneManager.LAYER_ZODER_GAME = 10;
SceneManager.LAYER_ZODER_PANEL = 20;
SceneManager.LAYER_ZODER_EFFECT = 40;
SceneManager.LAYER_ZODER_TIP = 80;
SceneManager.LAYER_ZODER_TOP = 100;


local app_ = nil;
local curScene = nil;
local curSceneId = -1;
local showList = {};
local loadLayer = nil;
local loadingTimer = nil;
local loadingSign = nil;
local closeSign = nil;


local function showScene()
	if(curSceneId == -1) then return end;
	local layer = nil;
	if(curSceneId == SceneManager.GAME_SCENE)then
		layer = app_:createView(app_.configs_.GameScene);
		layer:showWithScene(SceneManager.LAYER_ZODER_HALL);
	end
end

-- 卸载游戏资源
function SceneManager.clearGameRes()
	for k,v in pairs(package.loaded) do
        if (string.find(k, "app.game") or 17) <= 5 then
			print("unload "..k)
            package.loaded[k] = nil
        end
    end


end

--
function SceneManager.clearCurScene()
	if closeSign then
		g_Scheduler.stopFunc(closeSign);
		closeSign = nil;
	end
	
	for k,v in ipairs(showList) do
		if v then
			v:removeFromParent(true)
		end
	end
	showList = {}
end

local function onBackKeyDown()
	local leng = #showList
	if leng == 1 then
		if curSceneId == SceneManager.GAME_SCENE then return end
		local data = {};
		data.type = 2;
		data.txt = "您确定要退出游戏？"; 
		data.call = SceneManager.exitApp
		SceneManager.showConfirm(data)
		return true
	end
	local layer = showList[leng]
	if layer.mName == app_.configs_.netLoading or layer.mName == app_.configs_.confirmScene or layer.mName == app_.configs_.DismissScene then return end
	SceneManager.removeLayout(layer, layer.showAction)
	return true
end

function SceneManager.exitApp()
    cc.Director:sharedDirector():endToLua()
    if device.platform == "windows" or device.platform == "mac" or device.platform == "ios" then
        os.exit()
    end 
end

-- 切换到指定场景
function SceneManager.changeSceneByID(sceneId, app, transition, time, more)
	if(curSceneId == sceneId)then return end;
	if app ~= nil then
		app_ = app
		
	end
	SceneManager.clearCurScene()
	curSceneId = sceneId;
	curScene = display.newScene(sceneId);
	showScene();
	display.runScene(curScene, transition, time, more)
	g_Event.listen(g_Event.ONKEY_BACK, onBackKeyDown, curScene)
	
end

-- 切换到下一个场景
function SceneManager.nextScene()
	SceneManager.changeSceneByID(curSceneId + 1);
end

-- 在显示列表里找layer
local function findLayerInShowList(layer)
	for k,v in ipairs(showList) do
		if(v == layer)then
			return layer;
		end
	end

	return nil;
end

-- 添加一个layer
function SceneManager.addLayout(layer, isAction, zoder)
	zoder = zoder or SceneManager.LAYER_ZODER_PANEL;

	if(not layer)then return end

	if(findLayerInShowList(layer))then return end;
	showList[#showList + 1] = layer;
    curScene:addChild(layer, zoder);
    if(isAction)then
    	SceneManager.showAction(layer);
    end
	
end

-- 将界面从list里移除
local function removeFromList(layer)
	if(showList[#showList] == layer)then
		table.remove(showList, #showList);
		print("remove first : " .. layer.RESOURCE_FILENAME)
	else
		-- print("remove ... " .. layer.RESOURCE_FILENAME)
		for k,v in ipairs(showList) do
			if(v == layer)then
				table.remove(showList, k);
				print("remove layer by index: " .. k);
				break;
			end
		end
	end
end

-- 动画回调
local function closeActionCallBack(sender)
	closeSign = nil;
	if sender then
		sender:removeFromParent(true);
	end
end

-- 移除一个layer
function SceneManager.removeLayout(layer, isAction)
	removeFromList(layer)
	if layer.mLayout and isAction then
    	SceneManager.closeAction(layer);
    else
    	if closeSign then
			g_Scheduler.stopFunc(closeSign);
			closeSign = nil;
		end
    	closeSign = g_Scheduler.performDelayFunc(handler(layer, closeActionCallBack), 0);
    end
end

-- 打开界面动画
function SceneManager.showAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
	if layer.mLayout then
		layer.mLayout:setScale(0.1);
		local scaleAction = cc.ScaleTo:create(time, 1, 1);
		local seq = cc.Sequence:create(cc.EaseBackOut:create(scaleAction));
	    layer.mLayout:runAction(seq);
	end
	
end

-- 关闭界面动画
function SceneManager.closeAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
	print("关闭界面动画"..time)
	layer:setScale(1);
    local scaleAction = cc.ScaleTo:create(time, 0.1);
    local actionSequence = cc.Sequence:create(cc.EaseBackIn:create(scaleAction), cc.CallFunc:create(handler(layer, closeActionCallBack)));
    layer.mLayout:runAction(actionSequence);

end


return SceneManager;