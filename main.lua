local Grid = require("src.grid")

local grid

function love.load()
    grid = Grid.create()
end

function love.update(dt)

end

function love.draw()
    grid:draw()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'space' then
        _rebuildGrid()
    end
end

function _rebuildGrid()
    grid = Grid.create()
end