local MyApp = class("MyApp", cc.load("mvc").AppBase)
function MyApp:onCreate()
	math.randomseed(os.time())
	cc.Image:setPNGPremultipliedAlphaEnabled(false) -- 美术那边已经预乘Alpha,这里要取消掉否则动画黑边
end

function MyApp:loadPackageInit()

	require("app.tools.global")
	require("app.tools.functions")

end

function MyApp:run()
	self:loadPackageInit()
	g_SceneManager.changeSceneByID(g_SceneManager.GAME_SCENE, self)
end


return MyApp
