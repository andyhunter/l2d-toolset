-- filepath: love2d-project/src/utils/resources.lua

local Resources = {
    -- 缓存
    images = {},
    sounds = {},
    fonts = {},
    animations = {},
    maps = {},
    
    -- 默认设置
    defaultFontSize = 16
}

-- 加载图像并缓存
function Resources.loadImage(path)
    if Resources.images[path] == nil then
        local success, image = pcall(love.graphics.newImage, path)
        if success then
            Resources.images[path] = image
            return image
        else
            print("Error loading image: " .. path)
            return nil
        end
    end
    return Resources.images[path]
end

-- 加载音效并缓存
function Resources.loadSound(path)
    if Resources.sounds[path] == nil then
        local success, sound = pcall(love.audio.newSource, path, "static")
        if success then
            Resources.sounds[path] = sound
            return sound
        else
            print("Error loading sound: " .. path)
            return nil
        end
    end
    return Resources.sounds[path]
end

-- 加载音乐并缓存
function Resources.loadMusic(path)
    if Resources.sounds[path] == nil then
        local success, music = pcall(love.audio.newSource, path, "stream")
        if success then
            Resources.sounds[path] = music
            return music
        else
            print("Error loading music: " .. path)
            return nil
        end
    end
    return Resources.sounds[path]
end

-- 加载字体并缓存
function Resources.loadFont(path, size)
    size = size or Resources.defaultFontSize
    local key = path .. "_" .. size
    
    if Resources.fonts[key] == nil then
        local success, font = pcall(love.graphics.newFont, path, size)
        if success then
            Resources.fonts[key] = font
            return font
        else
            print("Error loading font: " .. path)
            return love.graphics.getFont()
        end
    end
    return Resources.fonts[key]
end

-- 使用anim8创建动画并缓存
function Resources.newAnimation(imagePath, frameWidth, frameHeight, duration, frames)
    local key = imagePath .. "_" .. frameWidth .. "_" .. frameHeight .. "_" .. tostring(duration)
    
    if Resources.animations[key] == nil then
        local anim8 = require 'libs.anim8.anim8'
        local image = Resources.loadImage(imagePath)
        
        if image then
            local g = anim8.newGrid(frameWidth, frameHeight, image:getWidth(), image:getHeight())
            local animation = anim8.newAnimation(frames or g('1-1',1), duration or 0.1)
            
            Resources.animations[key] = {
                image = image,
                animation = animation
            }
            return Resources.animations[key]
        else
            return nil
        end
    end
    return Resources.animations[key]
end

-- 加载Tiled地图并缓存
function Resources.loadMap(path)
    if Resources.maps[path] == nil then
        local sti = require 'libs.sti'
        local success, map = pcall(sti, path)
        
        if success then
            Resources.maps[path] = map
            return map
        else
            print("Error loading map: " .. path)
            return nil
        end
    end
    return Resources.maps[path]
end

-- 预加载资源
function Resources.preload(resourceList)
    for _, resource in ipairs(resourceList) do
        if resource.type == "image" then
            Resources.loadImage(resource.path)
        elseif resource.type == "sound" then
            Resources.loadSound(resource.path)
        elseif resource.type == "music" then
            Resources.loadMusic(resource.path)
        elseif resource.type == "font" then
            Resources.loadFont(resource.path, resource.size)
        elseif resource.type == "animation" then
            Resources.newAnimation(resource.path, resource.frameWidth, resource.frameHeight, resource.duration, resource.frames)
        elseif resource.type == "map" then
            Resources.loadMap(resource.path)
        end
    end
end

-- 清除特定类型的资源缓存
function Resources.clear(resourceType)
    if resourceType == "images" then
        Resources.images = {}
    elseif resourceType == "sounds" then
        Resources.sounds = {}
    elseif resourceType == "fonts" then
        Resources.fonts = {}
    elseif resourceType == "animations" then
        Resources.animations = {}
    elseif resourceType == "maps" then
        Resources.maps = {}
    else
        -- 清除所有缓存
        Resources.images = {}
        Resources.sounds = {}
        Resources.fonts = {}
        Resources.animations = {}
        Resources.maps = {}
    end
end

return Resources