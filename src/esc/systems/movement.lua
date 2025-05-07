-- Movement system for ECS architecture
local Concord = require("libs.concord")

-- Create a new system for handling movement
local MovementSystem = Concord.system({
    pool = {"position", "velocity", "player"}
})

function MovementSystem:init()
    -- Any initialization logic
end

function MovementSystem:update(dt)
    -- Process all entities with position, velocity, and player components
    for _, entity in ipairs(self.pool) do
        local position = entity.position
        local velocity = entity.velocity
        local player = entity.player
        
        -- Update position based on velocity
        position.x = position.x + velocity.x * dt
        position.y = position.y + velocity.y * dt
        
        -- Apply gravity if the player is jumping
        if player.isJumping then
            velocity.y = velocity.y + 800 * dt -- Gravity
            
            -- Check if player has landed (simplified, you'd check collision)
            if position.y >= 400 then -- Ground position
                position.y = 400
                velocity.y = 0
                player.isJumping = false
            end
        end
        
        -- Slow down horizontal movement (friction)
        velocity.x = velocity.x * 0.95
    end
end

return MovementSystem