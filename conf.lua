-- This file contains configuration settings for the Love2D application.

function love.conf(t)
    t.window.title = "Love2D Project"  -- The title of the window
    t.window.width = 800                -- The width of the window
    t.window.height = 600               -- The height of the window
    t.window.resizable = false           -- Disable window resizing
    t.window.fullscreen = false          -- Disable fullscreen mode
    t.window.vsync = 1                   -- Enable vertical sync
    t.console = true                     -- Enable console for debugging
end