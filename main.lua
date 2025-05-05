-- filepath: love2d-project/main.lua

local Gamestate = require 'libs.hump.gamestate'

-- Import game states
local Menu = require 'src.states.menu'
local Play = require 'src.states.play'
local Pause = require 'src.states.pause'

function love.load()
    -- Initialize the first game state
    Gamestate.registerEvents()
    Gamestate.switch(Menu)
end

function love.update(dt)
    -- Gamestate handles updates automatically
end

function love.draw()
    -- Gamestate handles rendering automatically
end

function love.keypressed(key)
    -- Gamestate handles keypresses automatically
end