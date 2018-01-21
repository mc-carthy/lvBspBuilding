local grid = {}

local gridDebugFlag = true

local grid_rng = love.math.newRandomGenerator(os.time())

local _generateGrid = function(self)
    for x = 1, self.xSize do
        self[x] = {}
        for y = 1, self.ySize do
            self[x][y] = {}
            -- self[x][y].walkable = true
        end
    end
end

local _populateGrid = function(self)
    for x = 1, self.xSize do
        for y = 1, self.ySize  do
            -- local prob = grid_rng:random(100)
            -- if prob >= 85 then
            --     self[x][y].walkable = false
            -- end
        end
    end
end

local worldSpaceToGrid = function(self, x, y)
    gridx = math.floor(x / self.cellSize) + 1
    gridy = math.floor(y / self.cellSize) + 1
    return gridx, gridy
end

local isWalkable = function(self, gridX, gridY)
    if self[gridX] and self[gridX][gridY] then
        return self[gridX][gridY].walkable
    else
        return true
    end
end

local update = function(self, dt)
end

local draw = function(self)
    for x = 1, self.xSize do
        for y = 1, self.ySize do
            love.graphics.setColor(127, 127, 127)
            if self[x][y].walkable == false then
                love.graphics.setColor(31, 31, 31)
            end
            if gridDebugFlag then
                love.graphics.rectangle('fill', (x - 1) * self.cellSize, (y - 1) * self.cellSize, self.cellDrawSize, self.cellDrawSize)
            end
        end
    end
end

grid.create = function(xSize, ySize)
    local inst = {}

    inst.tag = "grid"
    inst.cellSize = 20
    inst.worldScaleInScreens = 1
    local border = 1
    inst.cellDrawSize = inst.cellSize - border
    inst.xSize = xSize or love.graphics.getWidth() / inst.cellSize * inst.worldScaleInScreens
    inst.ySize = ySize or love.graphics.getHeight() / inst.cellSize * inst.worldScaleInScreens

    _generateGrid(inst)
    _populateGrid(inst)

    inst.worldSpaceToGrid = worldSpaceToGrid
    inst.isWalkable = isWalkable
    inst.update = update
    inst.draw = draw

    return inst
end

return grid
