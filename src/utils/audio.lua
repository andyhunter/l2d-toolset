-- filepath: love2d-project/src/utils/audio.lua

local Resources = require 'src.utils.resources'
local Config = require 'src.utils.config'

local Audio = {
    -- 当前播放的音乐
    currentMusic = nil,
    
    -- 音频池，用于管理多个相同音效的并发播放
    soundPools = {},
    
    -- 默认设置
    maxPoolSize = 5,
    defaultFadeTime = 1.0
}

-- 初始化音频系统
function Audio.init()
    -- 创建主音量调整器
    Audio.masterVolume = 1.0
    Audio.musicVolume = 0.7
    Audio.sfxVolume = 0.8
    
    -- 从配置加载音量设置
    if Config and Config.get then
        Audio.masterVolume = Config.get("audio", "masterVolume", 1.0)
        Audio.musicVolume = Config.get("audio", "musicVolume", 0.7)
        Audio.sfxVolume = Config.get("audio", "sfxVolume", 0.8)
    end
    
    -- 创建音效池
    Audio.soundPools = {}
end

-- 播放音效
function Audio.playSound(path, volume, pitch, loop)
    volume = volume or 1.0
    pitch = pitch or 1.0
    
    -- 应用主音量和音效音量
    local finalVolume = volume * Audio.masterVolume * Audio.sfxVolume
    
    -- 检查音频池
    if not Audio.soundPools[path] then
        Audio.soundPools[path] = {}
    end
    
    -- 在音频池中寻找可用的实例
    local sound
    local pool = Audio.soundPools[path]
    
    -- 先尝试找到已停止播放的音效实例
    for _, instance in ipairs(pool) do
        if not instance:isPlaying() then
            sound = instance
            break
        end
    end
    
    -- 如果没有找到可用实例，则创建新实例（如果池未满）
    if not sound then
        if #pool < Audio.maxPoolSize then
            sound = Resources.loadSound(path)
            if sound then
                table.insert(pool, sound)
            end
        else
            -- 池已满，使用最早的实例
            sound = pool[1]
            -- 将这个实例移到列表末尾，表示最近使用
            table.remove(pool, 1)
            table.insert(pool, sound)
        end
    end
    
    -- 播放音效
    if sound then
        sound:stop()  -- 停止之前的播放
        sound:setVolume(finalVolume)
        sound:setPitch(pitch)
        sound:setLooping(loop or false)
        sound:play()
    end
    
    return sound
end

-- 播放音乐
function Audio.playMusic(path, volume, loop, fadeTime)
    volume = volume or 1.0
    loop = loop ~= false  -- 默认循环
    fadeTime = fadeTime or Audio.defaultFadeTime
    
    -- 应用主音量和音乐音量
    local finalVolume = volume * Audio.masterVolume * Audio.musicVolume
    
    -- 如果当前有音乐在播放，先淡出
    if Audio.currentMusic and Audio.currentMusic:isPlaying() then
        -- 创建淡出效果
        local currentMusic = Audio.currentMusic
        local startVolume = currentMusic:getVolume()
        local timer = 0
        
        -- 淡出任务
        local fadeOutTask = function(dt)
            timer = timer + dt
            local progress = timer / fadeTime
            if progress >= 1.0 then
                currentMusic:stop()
                return true -- 任务完成
            else
                currentMusic:setVolume(startVolume * (1.0 - progress))
                return false -- 任务继续
            end
        end
        
        -- 添加到更新任务列表
        if Audio.updateTasks then
            table.insert(Audio.updateTasks, fadeOutTask)
        end
    end
    
    -- 加载并播放新音乐
    local music = Resources.loadMusic(path)
    if music then
        music:setVolume(0)  -- 初始音量为0
        music:setLooping(loop)
        music:play()
        
        -- 创建淡入效果
        local timer = 0
        
        -- 淡入任务
        local fadeInTask = function(dt)
            timer = timer + dt
            local progress = timer / fadeTime
            if progress >= 1.0 then
                music:setVolume(finalVolume)
                return true -- 任务完成
            else
                music:setVolume(finalVolume * progress)
                return false -- 任务继续
            end
        end
        
        -- 添加到更新任务列表
        if not Audio.updateTasks then
            Audio.updateTasks = {}
        end
        table.insert(Audio.updateTasks, fadeInTask)
        
        -- 更新当前音乐
        Audio.currentMusic = music
    end
    
    return music
end

-- 停止当前音乐
function Audio.stopMusic(fadeTime)
    fadeTime = fadeTime or Audio.defaultFadeTime
    
    if Audio.currentMusic and Audio.currentMusic:isPlaying() then
        -- 创建淡出效果
        local currentMusic = Audio.currentMusic
        local startVolume = currentMusic:getVolume()
        local timer = 0
        
        -- 淡出任务
        local fadeOutTask = function(dt)
            timer = timer + dt
            local progress = timer / fadeTime
            if progress >= 1.0 then
                currentMusic:stop()
                Audio.currentMusic = nil
                return true -- 任务完成
            else
                currentMusic:setVolume(startVolume * (1.0 - progress))
                return false -- 任务继续
            end
        end
        
        -- 添加到更新任务列表
        if not Audio.updateTasks then
            Audio.updateTasks = {}
        end
        table.insert(Audio.updateTasks, fadeOutTask)
    end
end

-- 暂停当前音乐
function Audio.pauseMusic()
    if Audio.currentMusic then
        Audio.currentMusic:pause()
    end
end

-- 恢复当前音乐
function Audio.resumeMusic()
    if Audio.currentMusic then
        Audio.currentMusic:play()
    end
end

-- 设置主音量
function Audio.setMasterVolume(volume)
    Audio.masterVolume = volume
    
    -- 更新当前音乐音量
    if Audio.currentMusic then
        Audio.currentMusic:setVolume(volume * Audio.musicVolume)
    end
    
    -- 可以保存到配置
    if Config and Config.set then
        Config.set("audio", "masterVolume", volume)
    end
end

-- 设置音乐音量
function Audio.setMusicVolume(volume)
    Audio.musicVolume = volume
    
    -- 更新当前音乐音量
    if Audio.currentMusic then
        Audio.currentMusic:setVolume(Audio.masterVolume * volume)
    end
    
    -- 可以保存到配置
    if Config and Config.set then
        Config.set("audio", "musicVolume", volume)
    end
end

-- 设置音效音量
function Audio.setSfxVolume(volume)
    Audio.sfxVolume = volume
    
    -- 可以保存到配置
    if Config and Config.set then
        Config.set("audio", "sfxVolume", volume)
    end
end

-- 更新音频管理器
function Audio.update(dt)
    -- 处理更新任务
    if Audio.updateTasks then
        local i = 1
        while i <= #Audio.updateTasks do
            local task = Audio.updateTasks[i]
            local completed = task(dt)
            if completed then
                table.remove(Audio.updateTasks, i)
            else
                i = i + 1
            end
        end
    end
end

return Audio