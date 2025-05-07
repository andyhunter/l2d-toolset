-- Central registry for ECS components, systems, and entities
local Concord = require("libs.concord")

-- Game world
local World = {}

-- Initialize the world with all systems and entities
function World.initialize()
    -- Create a new world instance
    local world = Concord.world()
    
    -- Register systems - 修复：不要调用系统构造函数，直接传递系统类
    world:addSystem(require("src.esc.systems.input"))
    world:addSystem(require("src.esc.systems.movement"))
    world:addSystem(require("src.esc.systems.render"))
    
    return world
end

-- Function to create a player entity
function World.createPlayer(world, x, y)
    local createPlayer = require("src.esc.entities.player")
    return createPlayer(world, x, y)
end

-- Add more entity creation functions as needed
-- function World.createEnemy(world, x, y, type)
--     local createEnemy = require("src.esc.entities.enemy")
--     return createEnemy(world, x, y, type)
-- end

-- Helper function to load all components
function World.loadComponents()
    -- Components are loaded on-demand by entities, but we can preload them here if needed
    require("src.esc.components.position")
    require("src.esc.components.velocity")
    require("src.esc.components.player")
    require("src.esc.components.sprite")
    require("src.esc.components.animation")
    require("src.esc.components.collider")
    
    -- Add more components here as they are created
end

-- Helper function for cleanup
function World.cleanup(world)
    if world then
        world:clear()
    end
end

return World