local SceneBase = class(cc.Node)

local WARNING = DEBUG > 0

-- 替换UI加载工具需要修改此处 !!
function SceneBase.__loadLayoutFile(layout)
    return cc.CreatorReader:create(layout)
end

-- 代码与布局查找关系
function SceneBase.__makeLayoutPath(classpath)
    local i = classpath:find("[^%.]app/") or 1
    return "ui/Layout/"..classpath:sub(i+4,-4).."ccreator"
end

function SceneBase:ctor(app, name)
    self:enableNodeEvents()
    self.mApp       = app
    self.mName      = name
    self.mModule    = {}
    self.mLayout    = nil
    self.showAction = true
    
    self:makeRequirePath()

    if type(self.preCreate) == "function" then self:preCreate() end

    self:loadLayout()
    self:bindModules()

    if type(self.onCreate) == "function" then self:onCreate() end
end

-- 查找基础加载文件夹
function SceneBase:makeRequirePath()
    local path = self.__cpath:gsub("/","%.")
    if path:find("app%.hall%.") then
        self.mRequirePath = "app.hall."
        return
    end
    local i,j = path:find("app%.game%.(.-)%.")
    self.mRequirePath  = path:sub(i,j)
end

--加载界面资源
function SceneBase:loadLayout()
    if type(self.RESOURCE_FILENAME) ~= "string" then
        self.RESOURCE_FILENAME = SceneBase.__makeLayoutPath(self.__cpath)
    end
    xpcall(
        function()
            self.mLayout = SceneBase.__loadLayoutFile(self.RESOURCE_FILENAME)
            self:setContentSize(display.width,display.height)
            self:add(self.mLayout)
        end, 
        function()
            if WARNING then
               -- print("Scene could not find layout: "..self.RESOURCE_FILENAME)
            end
        end
    )
end

-- 绑定其它组件,与ModuleBase相同
function SceneBase:bindModules()
    for i,module in ipairs(self.module or {}) do
        xpcall(
            function()
                local mod = require(self.mRequirePath.."module."..module)
                if rawget(mod,"ctor") then
                    error("[Error] Module "..module.." could not overwrite parent ctor() ,use onCreate() instead ~")
                end
                local m = mod:create(self, module)
                self.mModule[module:gsub("%.","_")] = m
                self:add(m)
            end, 
            function(err)
                if WARNING then
                   -- print("Scene could not load module: "..module)
                    __G__TRACKBACK__(err)
                end
            end
        )
    end
end

-- 刷新UI调用
function SceneBase:refreshUI(data)
    -- implement by children
end

return SceneBase
