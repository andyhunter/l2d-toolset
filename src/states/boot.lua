local Gamestate = require 'libs.hump.gamestate'
local i18n = require 'libs.smiti18n'
local Resources = require 'src.utils.resources'
local Audio = require 'src.utils.audio'
local Boot = {}

function Boot:enter()
    -- 初始化启动状态
    self.timer = 0
    self.loadingText = i18n('common.loading', {default = "Loading..."})
    self.loadingComplete = false
    self.loadingProgress = 0
    
    -- 游戏资源列表
    self.resources = {
        -- 图像
        { type = "image", path = "assets/images/player.png" },
        { type = "image", path = "assets/images/background.png" },
        { type = "image", path = "assets/images/sprites.png" },
        
        -- 音效
        { type = "sound", path = "assets/audio/sfx/jump.wav" },
        { type = "sound", path = "assets/audio/sfx/attack.wav" },
        { type = "sound", path = "assets/audio/sfx/hit.wav" },
        
        -- 音乐
        { type = "music", path = "assets/audio/music/game.mp3" },
        { type = "music", path = "assets/audio/music/boss.mp3" },
        
        -- 字体
        { type = "font", path = "assets/fonts/NotoSansCJK-Regular.ttc", size = 32 },
        { type = "font", path = "assets/fonts/NotoSansCJK-Regular.ttc", size = 18 },
        
        -- 地图
        { type = "map", path = "assets/maps/level1.lua" }
    }
    
    -- 开始异步加载
    self:loadResourcesAsync()
end

function Boot:loadResourcesAsync()
    -- 创建一个协程来异步加载资源
    self.loadingThread = coroutine.create(function()
        local totalResources = #self.resources
        
        for i, resource in ipairs(self.resources) do
            -- 尝试加载资源，忽略错误（资源可能不存在）
            pcall(function()
                if resource.type == "image" then
                    Resources.loadImage(resource.path)
                elseif resource.type == "sound" then
                    Resources.loadSound(resource.path)
                elseif resource.type == "music" then
                    Resources.loadMusic(resource.path)
                elseif resource.type == "font" then
                    Resources.loadFont(resource.path, resource.size)
                elseif resource.type == "map" then
                    Resources.loadMap(resource.path)
                end
            end)
            
            -- 更新加载进度
            self.loadingProgress = i / totalResources
            
            -- 让协程暂停一帧，防止加载冻结游戏
            coroutine.yield()
        end
        
        -- 加载完成
        self.loadingComplete = true
    end)
    
    -- 首次恢复协程开始加载过程
    coroutine.resume(self.loadingThread)
end

function Boot:update(dt)
    -- 继续异步加载资源
    if self.loadingThread and coroutine.status(self.loadingThread) ~= "dead" then
        coroutine.resume(self.loadingThread)
    end
    
    -- 如果加载完成，等待一小段时间再进入主菜单
    if self.loadingComplete then
        self.timer = self.timer + dt
        if self.timer > 1 then  -- 等待1秒后切换
            -- 播放菜单音乐（如果存在）
            pcall(function()
                Audio.playMusic("assets/audio/music/menu.mp3", 0.7)
            end)
            
            -- 切换到主菜单
            Gamestate.switch(require 'src.states.mainmenu')
        end
    end
end

function Boot:draw()
    -- 绘制启动/加载画面
    love.graphics.setColor(0.1, 0.1, 0.2) -- 设置深蓝色背景
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.loadingText, 0, love.graphics.getHeight() / 2 - 50, 
                        love.graphics.getWidth(), "center")
    
    -- 绘制具有实际进度的加载进度条
    local barWidth = 300
    local barHeight = 20
    local x = (love.graphics.getWidth() - barWidth) / 2
    local y = love.graphics.getHeight() / 2 + 30
    
    -- 进度条边框
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x, y, barWidth, barHeight)
    
    -- 进度条填充
    love.graphics.setColor(0, 0.7, 1) -- 设置蓝色进度条
    local loadProgress = self.loadingComplete and 1 or self.loadingProgress
    love.graphics.rectangle("fill", x, y, barWidth * loadProgress, barHeight)
    
    -- 显示进度百分比
    love.graphics.setColor(1, 1, 1)
    local percent = math.floor(loadProgress * 100)
    love.graphics.printf(percent .. "%", x, y + barHeight + 10, barWidth, "center")
end

function Boot:keypressed(key)
    -- 可以添加跳过加载的选项
    if key == "space" or key == "escape" or key == "return" then
        self.loadingComplete = true
        self.loadingProgress = 1
    end
end

return Boot