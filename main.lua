-- filepath: love2d-project/main.lua

local Gamestate = require 'libs.hump.gamestate'
local i18n = require 'libs.smiti18n'
local Input = require 'src.utils.input'

-- 导入我们新添加的管理器
local Resources = require 'src.utils.resources'
local Config = require 'src.utils.config'
local Audio = require 'src.utils.audio'

-- 导入ECS世界管理器
local World = require 'src.esc.world'

-- Import game states
local Boot = require 'src.states.boot'
local MainMenu = require 'src.states.mainmenu'
local Hub = require 'src.states.hub'
local Run = require 'src.states.run'
local PauseMenu = require 'src.states.pausemenu'
local GameOver = require 'src.states.gameover'
local Settings = require 'src.states.settings'

-- Initialize i18n system
local function initI18n()
    -- 加载所有翻译文件
    i18n.loadFile('locales/en.lua')
    i18n.loadFile('locales/zh-CN.lua')
    
    -- 设置默认语言（可以根据系统语言或用户选择进行设置）
    i18n.setLocale('en')  -- 默认使用英语
    i18n.setFallbackLocale('en')  -- 找不到翻译时使用英语
    
    -- 添加一个改变语言的函数，供游戏设置中使用
    GAME = GAME or {}
    GAME.setLanguage = function(lang)
        i18n.setLocale(lang)
    end
end

-- 预加载常用资源
local function preloadResources()
    Resources.preload({
        -- 字体
        { type = "font", path = "assets/fonts/NotoSansCJK-Regular.ttc", size = 24 },
        { type = "font", path = "assets/fonts/NotoSansCJK-Regular.ttc", size = 16 },
        
        -- UI 音效
        { type = "sound", path = "assets/audio/sfx/click.wav" },
        { type = "sound", path = "assets/audio/sfx/confirm.wav" },
        
        -- 背景音乐 (如果存在的话)
        { type = "music", path = "assets/audio/music/menu.mp3" },
        
        -- 玩家角色图片 (假设路径)
        { type = "image", path = "assets/images/player.png" },
    })
end

-- 初始化ECS系统
local function initECSSystem()
    -- 预加载所有组件
    World.loadComponents()
    
    -- 将世界实例存储到全局游戏对象中
    GAME = GAME or {}
    GAME.ecsWorld = nil -- 将在游戏状态中初始化
    
    -- 添加创建世界的便捷方法
    GAME.createWorld = function()
        GAME.ecsWorld = World.initialize()
        return GAME.ecsWorld
    end
    
    -- 添加清理世界的方法
    GAME.cleanupWorld = function()
        World.cleanup(GAME.ecsWorld)
        GAME.ecsWorld = nil
    end
end

function love.load()
    -- 初始化游戏
    love.graphics.setDefaultFilter("nearest", "nearest")  -- 像素风格平滑处理
    math.randomseed(os.time())  -- 随机数种子
    
    -- 初始化配置管理器
    Config.load() -- 加载已保存的设置，如果存在
    
    -- 初始化资源系统
    preloadResources()
    
    -- 初始化音频系统
    Audio.init()
    
    -- 初始化ECS系统
    initECSSystem()
    
    -- 设置默认字体
    font = Resources.loadFont("assets/fonts/NotoSansCJK-Regular.ttc", 24)
    love.graphics.setFont(font)
    
    -- 初始化国际化
    initI18n()
    
    -- 应用配置
    Config.apply()
    
    -- 初始化输入系统
    local joystick = love.joystick.getJoysticks()[1]  -- 获取第一个连接的手柄（如果有的话）
    Input.init(joystick)
    
    -- 初始化状态管理
    Gamestate.registerEvents()
    
    -- 播放菜单音乐 (如果文件存在)
    local success = pcall(function() 
        Audio.playMusic("assets/audio/music/menu.mp3", 0.7)
    end)
    
    -- 从 Boot 状态开始游戏
    Gamestate.switch(Boot)
end

function love.update(dt)
    -- 更新输入状态
    Input.update(dt)
    
    -- 更新音频系统
    Audio.update(dt)
    
    -- Gamestate 会自动处理状态更新
end

function love.draw()
    -- Gamestate 会自动处理状态绘制
    
    -- 如果需要，显示 FPS
    if Config.get("graphics", "showFps", false) then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
        love.graphics.setColor(1, 1, 1)
    end
end

function love.keypressed(key)
    -- Gamestate 会自动处理按键
    if key == "escape" then
        -- 如果当前状态是 Run，则暂停游戏
        if Gamestate.current() == Run then
            Gamestate.push(PauseMenu)
        end
    end
end

-- 处理控制器连接事件
function love.joystickadded(joystick)
    -- 当新的控制器连接时更新输入系统
    Input.setJoystick(joystick)
end

-- 处理控制器断开事件
function love.joystickremoved(joystick)
    -- 当控制器断开连接时，如果有其他控制器，则使用第一个
    local availableJoystick = love.joystick.getJoysticks()[1]
    Input.setJoystick(availableJoystick)
end

-- 关闭应用前保存配置
function love.quit()
    Config.save()
    return false -- 允许应用关闭
end