local BspBuilding = require("src.bspBuilding")

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
        for y = 1, self.ySize do
            -- local prob = grid_rng:random(100)
            -- if prob >= 85 then
            --     self[x][y].walkable = false
            -- end    
        end
    end
end

local function _addBuilding(self, buildingX, buildingY, buildingW, buildingH)
    local buildingX, buildingY = buildingX,buildingY
    local bspBuilding = BspBuilding.create(buildingW, buildingH)

    for x = 1, bspBuilding.w do
        for y = 1, bspBuilding.h do
            if bspBuilding.grid[x][y].outerWall then
                self[x + buildingX][y + buildingY].walkable = false
            end
        end
    end

    return bspBuilding
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

local _drawRoomCentres = function(self)
    love.graphics.setColor(191 / 255, 0, 0, 255 / 255)
    for i, room in ipairs(self.building.rooms) do
        love.graphics.circle("fill", (room.x + room.w / 2) * self.cellSize, (room.y + room.h / 2) * self.cellSize, 5)
    end
end

local _drawRoomFloors = function(self)
    for i, room in ipairs(self.building.rooms) do
        for j, floorTile in ipairs(room.floor) do
            love.graphics.setColor(unpack(room.debugColour))
            love.graphics.rectangle("fill", (floorTile.x - 1) * self.cellSize, (floorTile.y - 1) * self.cellSize, self.cellDrawSize, self.cellDrawSize)
        end
    end
end

local _drawRoomLines = function(self)
    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    for i, room in ipairs(self.building.rooms) do
        for j, neighbour in ipairs(room.neighbours) do
            love.graphics.line((room.x + room.w / 2) * self.cellSize, (room.y + room.h / 2) * self.cellSize, (neighbour.x + neighbour.w / 2) * self.cellSize,  (neighbour.y + neighbour.h / 2) * self.cellSize)
        end
    end
end

local _drawMst = function(self)
    love.graphics.setColor(1, 0, 1, 1)
    for i = 1, #self.building.tree do
        love.graphics.line(self.building.tree[i][1] * 10,self.building.tree[i][2] * 10,self.building.tree[i][3] * 10,self.building.tree[i][4] * 10)
    end
end

local update = function(self, dt)
end

local draw = function(self)
    for x = 1, self.xSize do
        for y = 1, self.ySize do
            love.graphics.setColor(127 / 255, 127 / 255, 127 / 255)
            if self[x][y].walkable == false then
                love.graphics.setColor(31 / 255, 31 / 255, 31 / 255)
            end
            if gridDebugFlag then
                love.graphics.rectangle('fill', (x - 1) * self.cellSize, (y - 1) * self.cellSize, self.cellDrawSize, self.cellDrawSize)
            end
        end
    end
    if drawColouredFloors then
        _drawRoomFloors(self)
    end
    if drawRoomLines then
        _drawRoomLines(self)
    end
    if drawRoomCentres then
        _drawRoomCentres(self)
    end
    if drawMst then
        _drawMst(self)
    end
end

grid.create = function(xSize, ySize)
    local inst = {}

    inst.tag = "grid"
    inst.cellSize = 10
    inst.worldScaleInScreens = 1
    local border = 1
    inst.cellDrawSize = inst.cellSize - border
    inst.xSize = xSize or love.graphics.getWidth() / inst.cellSize * inst.worldScaleInScreens
    inst.ySize = ySize or love.graphics.getHeight() / inst.cellSize * inst.worldScaleInScreens

    _generateGrid(inst)
    _populateGrid(inst)
    inst.building = _addBuilding(inst, 0, 0, inst.xSize, inst.ySize)

    inst.worldSpaceToGrid = worldSpaceToGrid
    inst.isWalkable = isWalkable
    inst.update = update
    inst.draw = draw

    return inst
end

return grid
