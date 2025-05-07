-- Player entity factory
local Concord = require("libs.concord")
local Resources = require("src.utils.resources")

-- Return a function that creates and returns a player entity
return function(world, x, y)
    -- Load required components
    require("src.esc.components.position")
    require("src.esc.components.velocity")
    require("src.esc.components.player")
    require("src.esc.components.sprite")
    require("src.esc.components.animation")
    require("src.esc.components.collider")
    
    -- Create a new entity
    local player = Concord.entity(world)
    
    -- 修复：使用loadImage方法而不是getImage，并指定完整路径
    local playerImage = Resources.loadImage("assets/images/player.png")
    
    -- 如果找不到图像，创建一个简单的替代图像
    if not playerImage then
        -- 创建一个16x16的空白图像数据
        local imageData = love.image.newImageData(32, 64)
        -- 填充为白色
        for y = 0, imageData:getHeight() - 1 do
            for x = 0, imageData:getWidth() - 1 do
                imageData:setPixel(x, y, 1, 1, 1, 1)
            end
        end
        playerImage = love.graphics.newImage(imageData)
        print("Warning: Player image not found, using placeholder.")
    end
    
    -- Animation frames configuration
    local animations = {
        idle = {
            frames = {1, 2, 3, 4},
            frameTime = 0.2
        },
        run = {
            frames = {5, 6, 7, 8},
            frameTime = 0.1
        },
        jump = {
            frames = {9, 10},
            frameTime = 0.2
        }
    }
    
    -- Add components to the entity
    player:give("position", x, y)
          :give("velocity", 0, 0)
          :give("player", 100, 200) -- 100 health, 200 speed
          :give("sprite", playerImage, 32, 64, 2) -- width, height, scale
          :give("animation", animations, "idle")
          :give("collider", 28, 56, 2, 8) -- slightly smaller than sprite with offset
    
    return player
end