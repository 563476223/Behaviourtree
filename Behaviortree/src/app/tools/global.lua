--------------------------------------------------------------
---------------- manager project global value ----------------
--------------------------------------------------------------
local cc = cc


cc.exports.json = require("cjson.safe")
cc.exports.g_Scheduler = cc.load("tools").Scheduler      --定时器用的比较多设置为全局读取
cc.exports.g_SceneManager = require("app.SceneManager")     -- 场景管理          -- UI相关工具类
cc.exports.g_Event = cc.load("tools").EventDispatch                    -- UI相关工具类
