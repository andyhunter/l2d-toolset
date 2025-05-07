-- Sprite component
local Concord = require("libs.concord")

return Concord.component("sprite", function(c, image, width, height, scale)
    c.image = image
    c.width = width or 32
    c.height = height or 32
    c.scale = scale or 1
    c.flipped = false
end)