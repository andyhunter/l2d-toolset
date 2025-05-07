-- Player related components
local Concord = require("libs.concord")

-- Position component
Concord.component("position", function(c, x, y)
    c.x = x or 0
    c.y = y or 0
end)

-- Velocity component
Concord.component("velocity", function(c, x, y)
    c.x = x or 0
    c.y = y or 0
end)

-- Player specific component
Concord.component("player", function(c, health, speed)
    c.health = health or 100
    c.speed = speed or 200
    c.isJumping = false
    c.jumpForce = 400
    c.direction = 1  -- 1 for right, -1 for left
end)

-- Sprite component
Concord.component("sprite", function(c, image, width, height, scale)
    c.image = image
    c.width = width or 32
    c.height = height or 32
    c.scale = scale or 1
    c.flipped = false
end)

-- Animation component
Concord.component("animation", function(c, animations, current)
    c.animations = animations or {}
    c.current = current or "idle"
    c.timer = 0
    c.frame = 1
end)

-- Collider component
Concord.component("collider", function(c, width, height, offsetX, offsetY)
    c.width = width or 32
    c.height = height or 32
    c.offsetX = offsetX or 0
    c.offsetY = offsetY or 0
end)