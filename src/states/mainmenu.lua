local Gamestate = require 'libs.hump.gamestate'
local i18n = require 'libs.smiti18n'
local Audio = require 'src.utils.audio'
local Resources = require 'src.utils.resources'
local Config = require 'src.utils.config'
local MainMenu = {}

function MainMenu:enter()
    -- 初始化主菜单状态
    self.title = i18n('mainmenu.title', {default = "Main Menu"})
    self.options = {
        i18n('mainmenu.start', {default = "Start"}),
        i18n('mainmenu.settings', {default = "Settings"}),
        i18n('mainmenu.exit', {default = "Exit"})
    }
    self.selected = 1
    
    -- 尝试加载背景图（如果存在）
    self.background = nil
    pcall(function()
        self.background = Resources.loadImage("assets/images/background.png")
    end)
    
    -- 设置菜单属性
    self.menuY = 150 -- 菜单基础位置
    self.itemHeight = 50 -- 每个菜单项的高度
    self.animationTimer = 0 -- 用于菜单动画
    
    -- 尝试播放菜单音乐（如果未在启动状态中播放）
    pcall(function()
        if not Audio.currentMusic or not Audio.currentMusic:isPlaying() then
            Audio.playMusic("assets/audio/music/menu.mp3", 0.7)
        end
    end)
end

function MainMenu:update(dt)
    -- 简单的菜单动画
    self.animationTimer = self.animationTimer + dt
    
    -- 更新选项标题（以防语言变更）
    self.options = {
        i18n('mainmenu.start', {default = "Start"}),
        i18n('mainmenu.settings', {default = "Settings"}),
        i18n('mainmenu.exit', {default = "Exit"})
    }
end

function MainMenu:draw()
    -- 绘制背景
    love.graphics.setColor(1, 1, 1)
    if self.background then
        love.graphics.draw(self.background, 0, 0, 0, 
            love.graphics.getWidth() / self.background:getWidth(),
            love.graphics.getHeight() / self.background:getHeight())
    else
        -- 如果没有背景图，绘制渐变背景
        self:drawGradientBackground()
    end
    
    -- 绘制游戏标题
    love.graphics.setColor(1, 1, 1)
    local titleY = 80
    local titleScale = 1.0 + math.sin(self.animationTimer * 2) * 0.02 -- 小幅呼吸动画
    local font = Resources.loadFont("assets/fonts/NotoSansCJK-Regular.ttc", 32)
    local oldFont = love.graphics.getFont()
    love.graphics.setFont(font)
    
    -- 标题阴影效果
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.printf(self.title, 2, titleY + 2, love.graphics.getWidth(), "center")
    
    -- 标题
    love.graphics.setColor(1, 0.8, 0.3) -- 金黄色标题
    love.graphics.printf(self.title, 0, titleY, love.graphics.getWidth(), "center")
    
    -- 恢复原来的字体
    love.graphics.setFont(oldFont)
    
    -- 绘制菜单选项
    for i, option in ipairs(self.options) do
        local y = self.menuY + (i - 1) * self.itemHeight
        
        -- 当前选中项有特殊效果
        if i == self.selected then
            -- 选中项动画
            local wobble = math.sin(self.animationTimer * 5) * 3
            
            -- 选中项背景
            love.graphics.setColor(0.2, 0.2, 0.3, 0.7)
            local bgWidth = 200
            local bgHeight = 30
            love.graphics.rectangle("fill", 
                (love.graphics.getWidth() - bgWidth) / 2,
                y - 5,
                bgWidth,
                bgHeight,
                5, 5) -- 圆角
            
            -- 选中项文本
            love.graphics.setColor(1, 1, 0)
            love.graphics.printf(option, wobble, y, love.graphics.getWidth(), "center")
            
            -- 绘制选择指示器
            love.graphics.setColor(1, 0.5, 0)
            love.graphics.printf(">", -120 + math.abs(wobble * 2), y, love.graphics.getWidth(), "center")
            love.graphics.printf("<", 120 - math.abs(wobble * 2), y, love.graphics.getWidth(), "center")
        else
            -- 非选中项
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.printf(option, 0, y, love.graphics.getWidth(), "center")
        end
    end
    
    -- 恢复颜色
    love.graphics.setColor(1, 1, 1)
    
    -- 版本信息
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(i18n('common.version', {"1.0", default = "Version %s"}), 0, love.graphics.getHeight() - 30, 
                        love.graphics.getWidth(), "center")
                        
    -- 如果开启了FPS显示（来自配置）
    if Config.get("graphics", "showFps", false) then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    end
end

-- 绘制渐变背景
function MainMenu:drawGradientBackground()
    -- 创建蓝黑渐变背景
    local width, height = love.graphics.getDimensions()
    local colors = {
        {0.1, 0.1, 0.3, 1}, -- 顶部颜色
        {0.05, 0.05, 0.15, 1} -- 底部颜色
    }
    
    -- 竖直渐变
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    for i=0, height do
        local t = i / height
        local r = (1-t) * colors[1][1] + t * colors[2][1]
        local g = (1-t) * colors[1][2] + t * colors[2][2]
        local b = (1-t) * colors[1][3] + t * colors[2][3]
        love.graphics.setColor(r, g, b, 1)
        love.graphics.line(0, i, width, i)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function MainMenu:keypressed(key)
    if key == "up" then
        self.selected = self.selected > 1 and self.selected - 1 or #self.options
        -- 播放菜单导航音效
        pcall(function() Audio.playSound("assets/audio/sfx/click.wav", 0.7) end)
    elseif key == "down" then
        self.selected = self.selected < #self.options and self.selected + 1 or 1
        -- 播放菜单导航音效
        pcall(function() Audio.playSound("assets/audio/sfx/click.wav", 0.7) end)
    elseif key == "return" or key == "space" then
        -- 播放确认音效
        pcall(function() Audio.playSound("assets/audio/sfx/confirm.wav", 0.9) end)
        
        if self.selected == 1 then
            -- 开始游戏，进入Hub
            Gamestate.switch(require 'src.states.hub')
        elseif self.selected == 2 then
            -- 进入设置，使用push而非switch，这样可以返回到主菜单
            Gamestate.push(require 'src.states.settings')
        elseif self.selected == 3 then
            -- 退出游戏
            love.event.quit()
        end
    end
end

return MainMenu