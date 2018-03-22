local config = {} -- 游戏的配置,经过加载后会变成 "g_"+变量名的方式进行全局访问,例如[ g_DEBUG ]

config.SERVER     = 3              -- 链接的服务器配置,1]正式服,2]预发布服,3]测试服,4]开发电脑
config.DEBUG      = true           -- 调试开关总闸

config.UPDATE_SRV = "http://192.168.1.118/update/"

config.USE_LIST_MD5 = true
config.USE_UPDATE_FILE = true --使用更新的资源

config.UPDATE_TARGET = {
	"mac",
	"android",
	"ios",
	"windows",
}

return config