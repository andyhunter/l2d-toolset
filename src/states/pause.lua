local Gamestate = require 'libs.hump.gamestate'
local Pause = {}

function Pause:enter()
    -- Initialize pause state
    self.message = "Game Paused"
end

function Pause:update(dt)
    -- Update pause logic (if needed)
end

function Pause:draw()
    -- Draw pause screen
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.message, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

function Pause:keypressed(key)
    if key == "return" then
        Gamestate.pop()
    end
end

return Pause