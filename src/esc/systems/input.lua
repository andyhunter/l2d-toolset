-- Input system for ECS architecture
local Concord = require("libs.concord")
local Input = require("src.utils.input") -- 引入 utils 的 Input 模块

-- Create a new system for handling player input
local InputSystem = Concord.system({
    pool = {"player", "velocity"}
})

function InputSystem:init()
    -- 不再需要单独的按键映射，将使用 utils Input 模块的映射
end

function InputSystem:update(dt)
    -- Process all entities with player and velocity components
    for _, entity in ipairs(self.pool) do
        local velocity = entity.velocity
        local player = entity.player
        local speed = player.speed
        
        -- 使用 utils 的 Input 模块处理水平移动
        if Input.down("left") then
            velocity.x = -speed
            player.direction = -1
            if entity.sprite then entity.sprite.flipped = true end
            if entity.animation then entity.animation.current = "run" end
        elseif Input.down("right") then
            velocity.x = speed
            player.direction = 1
            if entity.sprite then entity.sprite.flipped = false end
            if entity.animation then entity.animation.current = "run" end
        else
            -- If not moving horizontally, set to idle animation
            if math.abs(velocity.x) < 20 and entity.animation then
                entity.animation.current = "idle"
            end
        end
        
        -- 使用 utils 的 Input 模块处理跳跃
        if Input.pressed("jump") and not player.isJumping then
            velocity.y = -player.jumpForce
            player.isJumping = true
            if entity.animation then entity.animation.current = "jump" end
        end
        
        -- 也可以使用移动轴来获取更精确的移动输入
        -- local moveX, moveY = Input.getAxis("move")
        -- velocity.x = moveX * speed
    end
end

return InputSystem