local Gamestate = require 'libs.hump.gamestate'
local Timer = require 'libs.hump.timer'
local Play = {}

function Play:enter()
    -- Initialize play state
    self.player = {x = 100, y = 100, speed = 200}
    self.timer = Timer.new()
end

function Play:update(dt)
    -- Update game logic
    if love.keyboard.isDown("left") then
        self.player.x = self.player.x - self.player.speed * dt
    elseif love.keyboard.isDown("right") then
        self.player.x = self.player.x + self.player.speed * dt
    end

    if love.keyboard.isDown("up") then
        self.player.y = self.player.y - self.player.speed * dt
    elseif love.keyboard.isDown("down") then
        self.player.y = self.player.y + self.player.speed * dt
    end

    self.timer:update(dt)
end

function Play:draw()
    -- Draw game screen
    love.graphics.circle("fill", self.player.x, self.player.y, 20)
end

function Play:keypressed(key)
    if key == "escape" then
        Gamestate.push(require 'src.states.pause')
    end
end

return Play