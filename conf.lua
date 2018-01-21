function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.title = 'LÖVE Boilerplate'
    t.window.icon = nil

    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = true
    t.modules.window = true
    t.modules.thread = true
end

