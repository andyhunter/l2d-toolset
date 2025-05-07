-- Player component
local Concord = require("libs.concord")

return Concord.component("player", function(c, health, speed)
    c.health = health or 100
    c.maxHealth = health or 100
    c.speed = speed or 200
    c.isJumping = false
    c.jumpForce = 400
    c.direction = 1  -- 1 for right, -1 for left
    c.isAttacking = false
    c.attackCooldown = 0  -- 初始化攻击冷却时间
    c.attackSpeed = 1.0
    c.critChance = 0
    c.regen = 0
end)