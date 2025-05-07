-- Animation component
local Concord = require("libs.concord")

return Concord.component("animation", function(c, animations, current)
    c.animations = animations or {}
    c.current = current or "idle"
    c.timer = 0
    c.frame = 1
end)