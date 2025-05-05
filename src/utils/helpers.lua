-- filepath: love2d-project/src/utils/helpers.lua

local helpers = {}

function helpers.loadImage(path)
    return love.graphics.newImage(path)
end

function helpers.randomChoice(list)
    return list[math.random(#list)]
end

function helpers.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function helpers.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

return helpers