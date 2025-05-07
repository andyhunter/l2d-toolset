local Gamestate = require 'libs.hump.gamestate'
local Timer = require 'libs.hump.timer'
local i18n = require 'libs.smiti18n'
local Input = require 'src.utils.input'

-- 导入ECS世界管理器和组件
local World = require 'src.esc.world'

local Run = {}

function Run:enter(previous, runData)
    -- 创建ECS世界
    self.world = GAME.createWorld()
    
    -- 创建玩家实体
    self.player = World.createPlayer(self.world, 100, 100)
    
    -- 获取玩家组件的引用，方便直接操作
    self.playerComponents = {
        position = self.player.position,
        velocity = self.player.velocity,
        player = self.player.player,
        sprite = self.player.sprite,
        collider = self.player.collider
    }
    
    -- 设置玩家初始属性
    self.playerComponents.player.health = 100
    self.playerComponents.player.maxHealth = 100
    self.playerComponents.player.attackSpeed = 1.0
    self.playerComponents.player.critChance = 0
    self.playerComponents.player.regen = 0
    
    -- 初始化游戏状态变量
    self.timer = Timer.new()
    self.gameTime = 0
    self.currentFloor = 1
    self.activeBuffs = {}
    self.score = 0
    
    -- 处理玩家选择的buff（如果有）
    if runData and runData.buffs then
        for _, buff in ipairs(runData.buffs) do
            table.insert(self.activeBuffs, buff)
            self:applyBuff(buff)
        end
    end
    
    -- 初始化随机关卡生成
    self:generateLevel(self.currentFloor)
    
    print("Starting new run with " .. #self.activeBuffs .. " buffs")
end

function Run:applyBuff(buff)
    -- 将buff效果应用到玩家组件上
    local player = self.playerComponents.player
    
    if buff.name == i18n('hub.buffs.health_up.name', {default = "Health Up"}) then
        local healthBonus = player.maxHealth * 0.25
        player.maxHealth = player.maxHealth + healthBonus
        player.health = player.health + healthBonus
    elseif buff.name == i18n('hub.buffs.attack_speed.name', {default = "Attack Speed"}) then
        player.attackSpeed = player.attackSpeed * 1.15
    elseif buff.name == i18n('hub.buffs.critical_hit.name', {default = "Critical Hit"}) then
        player.critChance = player.critChance + 0.1
    elseif buff.name == i18n('hub.buffs.regeneration.name', {default = "Regeneration"}) then
        player.regen = 1 -- 每秒恢复1点生命值
    end
end

function Run:generateLevel(floor)
    -- 随机生成新关卡/楼层
    -- 这里是占位符 - 在实际游戏中，你需要实现适当的生成逻辑
    self.currentRoom = 1
    self.totalRooms = 5 + math.floor(floor * 1.5) -- 更深的楼层有更多房间
    
    -- 演示目的
    print(i18n('run.debug.floor_generated', {floor, self.totalRooms, default = "Generated floor %d with %d rooms"}))
end

function Run:update(dt)
    -- 更新游戏逻辑
    self.gameTime = self.gameTime + dt
    
    local player = self.playerComponents.player
    local position = self.playerComponents.position
    local velocity = self.playerComponents.velocity
    
    -- 应用恢复效果（如果玩家有的话）
    if player.regen > 0 then
        player.health = math.min(player.health + player.regen * dt, player.maxHealth)
    end
    
    -- 手动处理玩家输入（不使用input系统，因为有自定义逻辑）
    local moveX, moveY = Input.getAxis('move')
    velocity.x = moveX * player.speed
    velocity.y = moveY * player.speed
    
    -- 边界检查
    if position.x < 20 then position.x = 20 end
    if position.x > love.graphics.getWidth() - 20 then position.x = love.graphics.getWidth() - 20 end
    if position.y < 20 then position.y = 20 end
    if position.y > love.graphics.getHeight() - 20 then position.y = love.graphics.getHeight() - 20 end
    
    -- 处理攻击输入
    if Input.pressed('attack') then
        self:playerAttack()
    end
    
    -- 处理特殊能力输入
    if Input.pressed('special') then
        self:useSpecialAbility()
    end
    
    -- 处理跳跃/闪避输入
    if Input.pressed('jump') then
        self:playerJumpOrDodge()
    end
    
    -- 处理冲刺输入
    if Input.pressed('dash') then
        self:playerDash()
    end
    
    -- 处理交互输入
    if Input.pressed('interact') then
        self:playerInteract()
    end
    
    -- 处理攻击冷却时间
    if player.attackCooldown > 0 then
        player.attackCooldown = player.attackCooldown - dt
        if player.attackCooldown <= 0 then
            player.isAttacking = false
        end
    end

    -- 更新ECS世界
    self.world:emit("update", dt)
    
    -- 更新计时器
    self.timer:update(dt)
    
    -- 检查游戏条件
    if player.health <= 0 then
        Gamestate.switch(require 'src.states.gameover', { score = self.score })
    end
    
    -- 处理暂停输入
    if Input.pressed('pause') then
        -- 暂停游戏
        Gamestate.push(require 'src.states.pausemenu')
    end
end

-- 玩家动作
function Run:playerAttack()
    -- 攻击示例实现
    local player = self.playerComponents.player
    
    if not player.attackCooldown or player.attackCooldown <= 0 then
        player.isAttacking = true
        player.attackCooldown = 1.0 / player.attackSpeed
        
        self.score = self.score + 10
        
        -- 暴击几率展示
        if math.random() < player.critChance then
            self.score = self.score + 10 -- 暴击双倍得分
            print("Critical hit!")
        end
    end
end

function Run:playerJumpOrDodge()
    -- 跳跃/闪避示例实现
    local player = self.playerComponents.player
    
    print("Player jumped or dodged!")
    -- 在这里添加跳跃/闪避逻辑
    if not player.isJumping then
        player.isJumping = true
        self.playerComponents.velocity.y = -player.jumpForce
    end
end

function Run:playerDash()
    -- 冲刺示例实现
    print("Player dashed!")
    -- 在这里添加冲刺逻辑
end

function Run:playerInteract()
    -- 交互示例实现
    print("Player interacted!")
    
    -- 示例：进入下一个房间
    self.currentRoom = self.currentRoom + 1
    if self.currentRoom > self.totalRooms then
        -- 进入下一层
        self.currentFloor = self.currentFloor + 1
        self:generateLevel(self.currentFloor)
        self.score = self.score + 100 -- 完成一层的奖励
    end
end

function Run:useSpecialAbility()
    -- 特殊能力示例实现
    print("Player used special ability!")
    -- 受到伤害（用于测试游戏结束条件）
    local player = self.playerComponents.player
    player.health = player.health - 10
    if player.health <= 0 then
        Gamestate.switch(require 'src.states.gameover', { score = self.score })
    end
end

function Run:draw()
    -- 绘制ECS实体
    self.world:emit("draw")
    
    -- 绘制用户界面
    love.graphics.setColor(1, 1, 1)
    local player = self.playerComponents.player
    love.graphics.print(i18n('run.health', {math.floor(player.health), math.floor(player.maxHealth), default = "Health: %d/%d"}), 10, 10)
    love.graphics.print(i18n('run.score', {self.score, default = "Score: %d"}), 10, 30)
    love.graphics.print(i18n('run.time', {math.floor(self.gameTime), default = "Time: %d"}), 10, 50)
    love.graphics.print(i18n('run.floor', {self.currentFloor, self.currentRoom, self.totalRooms, default = "Floor: %d (Room %d/%d)"}), 10, 70)
    
    -- 绘制激活的buff
    love.graphics.print(i18n('run.active_buffs', {default = "Active Buffs:"}), 10, 100)
    for i, buff in ipairs(self.activeBuffs) do
        love.graphics.print("- " .. buff.name, 20, 100 + i * 20)
    end
    
    -- 根据活动设备绘制控制提示
    local deviceType = Input.getActiveDevice()
    local controlHints
    
    if deviceType == "kbm" then
        -- 键盘控制提示
        controlHints = "WASD/Arrows: Move, X: Attack, Space: Jump, E: Interact, F: Special, Shift: Dash, Esc: Pause"
    elseif deviceType == "joy" then
        -- 游戏手柄控制提示
        controlHints = "Left Stick: Move, X: Attack, A: Jump, Y: Interact, RB: Special, B: Dash, Start: Pause"
    else
        controlHints = "No controls detected"
    end
    
    love.graphics.print(controlHints, 10, love.graphics.getHeight() - 30)
end

-- 我们仍然保留keypressed用于其他键盘处理（如果需要的话）
function Run:keypressed(key)
    -- 任何额外的键盘处理
end

-- 退出此状态时清理
function Run:leave()
    -- 保存游戏状态，释放资源等
    print(i18n('run.debug.run_ended', {self.currentFloor, self.score, default = "Run ended on floor %d with a score of %d"}))
    
    -- 清理ECS世界
    GAME.cleanupWorld()
end

return Run