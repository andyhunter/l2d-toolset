local Gamestate = require 'libs.hump.gamestate'
local Menu = {}

function Menu:enter()
    -- Initialize menu state
    self.title = "Main Menu"
    self.options = {"Start Game", "Exit"}
    self.selected = 1
end

function Menu:update(dt)
    -- Update menu logic
end

function Menu:draw()
    love.graphics.printf(self.title, 0, 100, love.graphics.getWidth(), "center")
    for i, option in ipairs(self.options) do
        local color = i == self.selected and {1, 1, 0} or {1, 1, 1}
        love.graphics.setColor(color)
        love.graphics.printf(option, 0, 150 + i * 30, love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(1, 1, 1)
end

function Menu:keypressed(key)
    if key == "up" then
        self.selected = self.selected > 1 and self.selected - 1 or #self.options
    elseif key == "down" then
        self.selected = self.selected < #self.options and self.selected + 1 or 1
    elseif key == "return" then
        if self.selected == 1 then
            Gamestate.switch(require 'src.states.play')
        elseif self.selected == 2 then
            love.event.quit()
        end
    end
end

return Menu