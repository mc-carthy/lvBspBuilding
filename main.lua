Class = require('src.utils.class')
require('src.bspBuilding')
local Grid = require("src.grid")

local grid

drawColouredFloors = true
drawRoomCentres = true
drawRoomLines = true
drawMst = true

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
    if key == 'f' then
        drawColouredFloors = not drawColouredFloors
    end
    if key == 'c' then
        drawRoomCentres = not drawRoomCentres
    end
    if key == 'l' then
        drawRoomLines = not drawRoomLines
    end
    if key == 'm' then
        drawMst = not drawMst
    end
end

function _rebuildGrid()
    grid = Grid.create()
end