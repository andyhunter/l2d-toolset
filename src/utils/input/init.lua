-- 输入控制模块
local baton = require 'libs.baton.baton'

local Input = {}
local controls
local controlConfig = {
    -- 移动控制
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
    
    -- 动作按钮
    jump = {'key:space', 'button:a'},
    attack = {'key:x', 'button:x'},
    interact = {'key:e', 'button:y'},
    
    -- 菜单控制
    confirm = {'key:return', 'button:a'},
    cancel = {'key:escape', 'button:b'},
    pause = {'key:escape', 'button:start'},
    
    -- 额外控制
    dash = {'key:lshift', 'button:b'},
    special = {'key:f', 'button:rightshoulder'}
}

-- 初始化输入配置
function Input.init(joystick)
    controls = baton.new({
        controls = controlConfig,
        
        pairs = {
            -- 将方向键组合为移动轴对
            move = {'left', 'right', 'up', 'down'}
        },
        
        -- 控制器死区设置
        deadzone = 0.25,
        squareDeadzone = false,
        
        -- 当前使用的控制器
        joystick = joystick
    })
end

-- 更新输入状态
function Input.update(dt)
    if controls then
        controls:update()
    end
end

-- 获取按钮状态
function Input.down(control)
    return controls and controls:down(control) or false
end

function Input.pressed(control)
    return controls and controls:pressed(control) or false
end

function Input.released(control)
    return controls and controls:released(control) or false
end

-- 获取轴对值
function Input.getAxis(pairName)
    if controls then
        return controls:get(pairName)
    end
    return 0, 0
end

-- 获取单个轴向值
function Input.getValue(control)
    if controls then
        return controls:get(control)
    end
    return 0
end

-- 获取当前活跃的输入设备类型
function Input.getActiveDevice()
    if controls then
        return controls:getActiveDevice()
    end
    return "none"
end

-- 更新游戏手柄
function Input.setJoystick(joystick)
    if controls then
        controls.config.joystick = joystick
    end
end

-- 重新映射按键
function Input.remapControl(action, keyType, key)
    -- 例如：Input.remapControl('jump', 'key', 'space')
    if not controlConfig[action] then return false end
    
    local newBindings = {}
    local replaced = false
    
    -- 遍历现有绑定
    for _, binding in ipairs(controlConfig[action]) do
        local bindingType = binding:match("(.+):.+")
        if bindingType == keyType then
            -- 替换现有的同类型绑定
            table.insert(newBindings, keyType..":"..key)
            replaced = true
        else
            -- 保留其他类型的绑定
            table.insert(newBindings, binding)
        end
    end
    
    -- 如果没有替换任何绑定，添加新的
    if not replaced then
        table.insert(newBindings, keyType..":"..key)
    end
    
    controlConfig[action] = newBindings
    
    -- 重新初始化控制器，应用新的映射
    local joystick = controls and controls.config.joystick or nil
    Input.init(joystick)
    
    return true
end

-- 保存和加载控制配置
function Input.saveConfig(filename)
    local data = {}
    data.controls = controlConfig
    
    local success, message = love.filesystem.write(filename, "return " .. Input.serialize(data))
    return success, message
end

function Input.loadConfig(filename)
    if love.filesystem.getInfo(filename) then
        local chunk = love.filesystem.load(filename)
        local data = chunk()
        
        if data and data.controls then
            controlConfig = data.controls
            Input.init(controls and controls.config.joystick or nil)
            return true
        end
    end
    return false
end

-- 辅助函数：序列化表格为字符串
function Input.serialize(tbl, indent)
    if not indent then indent = 0 end
    local res = "{\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        local formatting = string.rep(" ", indent)
        if type(k) == "number" then
            formatting = formatting .. ""
        else
            formatting = formatting .. k .. " = "
        end
        if type(v) == "table" then
            res = res .. formatting .. Input.serialize(v, indent) .. ",\n"
        elseif type(v) == "string" then
            res = res .. formatting .. string.format("%q", v) .. ",\n"
        else
            res = res .. formatting .. tostring(v) .. ",\n"
        end
    end
    res = res .. string.rep(" ", indent-2) .. "}"
    return res
end

return Input