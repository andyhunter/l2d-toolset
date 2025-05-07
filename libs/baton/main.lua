-- 导入 baton 库，这是一个 LÖVE 2D 的输入处理库
local baton = require 'baton'

-- 创建一个新的输入控制器实例
local player = baton.new {
    -- 定义控制按键的映射，支持键盘、手柄和鼠标
    controls = {
        left = {'key:left', 'axis:leftx-', 'button:dpleft'},     -- 向左移动的控制
        right = {'key:right', 'axis:leftx+', 'button:dpright'},  -- 向右移动的控制
        up = {'key:up', 'axis:lefty-', 'button:dpup'},          -- 向上移动的控制
        down = {'key:down', 'axis:lefty+', 'button:dpdown'},     -- 向下移动的控制
        action = {'key:x', 'button:a', 'mouse:1'},               -- 动作按钮的控制
    },
    -- 定义控制组合，将上下左右组合成移动控制
    pairs = {
        move = {'left', 'right', 'up', 'down'}
    },
    -- 设置默认使用的手柄（如果有）
    joystick = love.joystick.getJoysticks()[1],
    -- 设置死区值，防止摇杆小幅度移动触发操作
    deadzone = .33,
}

-- 显示效果相关变量
local pairDisplayAlpha = 0       -- 当前移动控制显示的透明度
local pairDisplayTargetAlpha = 0 -- 目标移动控制显示透明度
local buttonDisplayAlpha = 0      -- 当前按钮显示的透明度
local buttonDisplayTargetAlpha = 0 -- 目标按钮显示透明度

-- 性能统计相关变量
local updates = 0      -- 更新次数计数器
local updateTime = 0   -- 累计更新时间

-- LÖVE 2D 的更新函数，每帧调用
function love.update(dt)
    -- 记录开始时间用于性能测量
    local time = love.timer.getTime()

    -- 更新输入控制器状态
    player:update()

    -- 根据移动控制状态设置目标透明度
    -- 按下或释放时完全不透明，持续按下时半透明，未按下时完全透明
    pairDisplayTargetAlpha = player:pressed 'move' and 1
                          or player:released 'move' and 1
                          or player:down 'move' and .5
                          or 0
    -- 平滑过渡当前透明度到目标透明度
    if pairDisplayAlpha > pairDisplayTargetAlpha then
        pairDisplayAlpha = pairDisplayAlpha - 4 * dt
    end
    if pairDisplayAlpha < pairDisplayTargetAlpha then
        pairDisplayAlpha = pairDisplayTargetAlpha
    end

    -- 与移动控制类似，根据动作按钮状态设置目标透明度
    buttonDisplayTargetAlpha = player:pressed 'action' and 1
                            or player:released 'action' and 1
                            or player:down 'action' and .5
                            or 0
    -- 平滑过渡当前透明度到目标透明度
    if buttonDisplayAlpha > buttonDisplayTargetAlpha then
        buttonDisplayAlpha = buttonDisplayAlpha - 4 * dt
    end
    if buttonDisplayAlpha < buttonDisplayTargetAlpha then
        buttonDisplayAlpha = buttonDisplayTargetAlpha
    end

    -- 更新性能统计数据
    updateTime = updateTime + (love.timer.getTime() - time)
    updates = updates + 1
end

-- 键盘按键按下事件处理函数
function love.keypressed(key)
    -- 空格键重置手柄设置
    if key == 'space' then
        player.config.joystick = nil
    end
    -- ESC键退出游戏
    if key == 'escape' then
        love.event.quit()
    end
end

-- 设置显示移动控制的圆形半径
local pairDisplayRadius = 128

-- LÖVE 2D 的绘图函数，每帧调用
function love.draw()
    -- 设置白色
    love.graphics.setColor(1, 1, 1)
    -- 显示当前活跃的输入设备
    love.graphics.print('Current active device: ' .. tostring(player:getActiveDevice()))
    -- 显示平均更新时间（微秒）
    love.graphics.print('Average update time (us): ' .. math.floor(updateTime/updates*1000000), 0, 16)
    -- 显示内存使用量（KB）
    love.graphics.print('Memory usage (kb): ' .. math.floor(collectgarbage 'count'), 0, 32)

    -- 保存当前变换状态并移动坐标原点到屏幕中心位置
    love.graphics.push()
    love.graphics.translate(400, 300)

    -- 绘制移动控制背景圆，透明度随状态变化
    love.graphics.setColor(.25, .25, .25, pairDisplayAlpha)
    love.graphics.circle('fill', 0, 0, pairDisplayRadius)

    -- 绘制移动控制边框圆
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('line', 0, 0, pairDisplayRadius)

    -- 计算死区半径并绘制死区边界
    local r = pairDisplayRadius * player.config.deadzone
    if player.config.squareDeadzone then
        -- 如果使用方形死区，绘制方形边界
        love.graphics.rectangle('line', -r, -r, r*2, r*2)
    else
        -- 否则绘制圆形死区边界
        love.graphics.circle('line', 0, 0, r)
    end

    -- 绘制原始输入位置（灰色点）
    love.graphics.setColor(.5, .5, .5)
    local x, y = player:getRaw 'move'
    love.graphics.circle('fill', x*pairDisplayRadius, y*pairDisplayRadius, 4)
    
    -- 绘制处理后的输入位置（白色点，应用了死区和其他处理）
    love.graphics.setColor(1, 1, 1)
    x, y = player:get 'move'
    love.graphics.circle('fill', x*pairDisplayRadius, y*pairDisplayRadius, 4)

    -- 绘制动作按钮边框
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', -50, 150, 100, 100)
    -- 根据按钮状态填充动作按钮
    love.graphics.setColor(1, 1, 1, buttonDisplayAlpha)
    love.graphics.rectangle('fill', -50, 150, 100, 100)

    -- 恢复之前保存的变换状态
    love.graphics.pop()
end
