-- filepath: love2d-project/src/utils/config.lua

local Config = {
    -- 默认设置
    settings = {
        -- 视觉设置
        graphics = {
            fullscreen = false,
            vsync = true,
            width = 800,
            height = 600,
            showFps = false,
        },
        
        -- 音频设置
        audio = {
            masterVolume = 1.0,
            musicVolume = 0.7,
            sfxVolume = 0.8,
            mute = false,
        },
        
        -- 游戏设置
        game = {
            language = "en",
            difficulty = "normal",
            tutorialEnabled = true,
        },
        
        -- 输入设置
        input = {
            keymap = {}, -- 由输入管理器填充
        },
        
        -- 开发者设置
        dev = {
            debugMode = false,
            showColliders = false,
        }
    },
    
    -- 配置文件名
    filename = "settings.json",
}

-- 加载配置
function Config.load()
    if love.filesystem.getInfo(Config.filename) then
        local contents = love.filesystem.read(Config.filename)
        if contents then
            local success, data = pcall(function() 
                return require("libs.lume.lume").deserialize(contents) 
            end)
            
            if success then
                -- 合并保存的配置和默认配置（保留默认值作为后备）
                Config.settings = Config.mergeSettings(Config.settings, data)
                return true
            else
                print("配置文件解析失败:", data)
            end
        end
    end
    
    return false
end

-- 保存配置
function Config.save()
    local data = require("libs.lume.lume").serialize(Config.settings)
    local success, message = love.filesystem.write(Config.filename, data)
    
    if not success then
        print("配置保存失败:", message)
    end
    
    return success
end

-- 设置配置项
function Config.set(category, key, value)
    if Config.settings[category] then
        Config.settings[category][key] = value
        return true
    end
    return false
end

-- 获取配置项
function Config.get(category, key, default)
    if Config.settings[category] and Config.settings[category][key] ~= nil then
        return Config.settings[category][key]
    end
    return default
end

-- 应用配置项到游戏
function Config.apply()
    -- 应用图形设置
    local graphics = Config.settings.graphics
    if graphics.fullscreen ~= love.window.getFullscreen() then
        love.window.setFullscreen(graphics.fullscreen)
    end
    
    love.window.setVSync(graphics.vsync and 1 or 0)
    
    -- 如果不是全屏，则应用窗口尺寸
    if not graphics.fullscreen then
        local currentWidth, currentHeight = love.window.getMode()
        if currentWidth ~= graphics.width or currentHeight ~= graphics.height then
            love.window.setMode(graphics.width, graphics.height)
        end
    end

    -- 应用音频设置
    local audio = Config.settings.audio
    -- 这里你可以应用音频设置到音频系统
    
    -- 应用语言设置
    local i18n = require 'libs.smiti18n'
    i18n.setLocale(Config.settings.game.language)
    
    -- 应用其他可能的设置...
end

-- 辅助函数：将保存的设置合并到默认设置中，保持结构一致
function Config.mergeSettings(defaults, saved)
    local result = {}
    
    for category, values in pairs(defaults) do
        result[category] = {}
        
        -- 复制默认值
        for k, v in pairs(values) do
            result[category][k] = v
        end
        
        -- 应用保存的值（如果存在）
        if saved[category] then
            for k, v in pairs(saved[category]) do
                if defaults[category][k] ~= nil then  -- 只合并存在于默认设置中的键
                    result[category][k] = v
                end
            end
        end
    end
    
    return result
end

-- 重置所有设置为默认值
function Config.resetToDefaults()
    local defaultSettings = {
        -- 视觉设置
        graphics = {
            fullscreen = false,
            vsync = true,
            width = 800,
            height = 600,
            showFps = false,
        },
        
        -- 音频设置
        audio = {
            masterVolume = 1.0,
            musicVolume = 0.7,
            sfxVolume = 0.8,
            mute = false,
        },
        
        -- 游戏设置
        game = {
            language = "en",
            difficulty = "normal",
            tutorialEnabled = true,
        },
        
        -- 输入设置
        input = {
            keymap = {}, -- 由输入管理器填充
        },
        
        -- 开发者设置
        dev = {
            debugMode = false,
            showColliders = false,
        }
    }
    
    Config.settings = defaultSettings
    Config.save()
end

return Config