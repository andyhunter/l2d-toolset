-- Collider component
local Concord = require("libs.concord")

return Concord.component("collider", function(c, width, height, offsetX, offsetY)
    c.width = width or 32
    c.height = height or 32
    c.offsetX = offsetX or 0
    c.offsetY = offsetY or 0
end)