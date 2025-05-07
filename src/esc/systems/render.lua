-- Render system for ECS architecture
local Concord = require("libs.concord")

-- Create a new system for rendering entities
local RenderSystem = Concord.system({
    pool = {"position", "sprite"}
})

function RenderSystem:init()
    -- Initialization if needed
end

function RenderSystem:draw()
    for _, entity in ipairs(self.pool) do
        local position = entity.position
        local sprite = entity.sprite
        
        -- Set default color
        love.graphics.setColor(1, 1, 1)
        
        -- Draw the sprite if it exists
        if sprite.image then
            local scaleX = sprite.scale
            if sprite.flipped then scaleX = -sprite.scale end
            
            love.graphics.draw(
                sprite.image, 
                position.x, 
                position.y, 
                0, 
                scaleX, 
                sprite.scale, 
                sprite.width/2, 
                sprite.height/2
            )
        else
            -- Fallback rectangle if no image available
            love.graphics.rectangle("fill", 
                position.x - sprite.width/2, 
                position.y - sprite.height/2, 
                sprite.width, 
                sprite.height
            )
        end
        
        -- Optional: Draw collision debug info
        if entity.collider and _G.DEBUG_MODE then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("line",
                position.x - entity.collider.width/2 + entity.collider.offsetX,
                position.y - entity.collider.height/2 + entity.collider.offsetY,
                entity.collider.width,
                entity.collider.height
            )
        end
    end
end

return RenderSystem