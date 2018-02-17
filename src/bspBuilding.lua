local bspBuilding = {}

local bsp_rng = love.math.newRandomGenerator(os.time())

local function _createOuterWalls(self)
    local grid = {}
    for x = 1, self.w do
        grid[x] = {}
        for y = 1, self.h do
            grid[x][y] = {}
            if x == 1 or x == self.w or y == 1 or y == self.h then
                grid[x][y].outerWall = true
            end
        end
    end
    return grid
end

local function _addOuterDoor(self)
    local prob = bsp_rng:random(100)
    if prob < 25 then
        self.grid[1][love.math.random(2, self.h - 1)].outerWall = false
    elseif prob < 50 then
        self.grid[self.w][love.math.random(2, self.h - 1)].outerWall = false
    elseif prob < 75 then
        self.grid[love.math.random(2, self.w - 1)][1].outerWall = false
    else
        self.grid[love.math.random(2, self.w - 1)][self.h].outerWall = false
    end
end

bspBuilding.create = function(w, h, minRoomSize)
    local inst = {}

    inst.grid = {}
    inst.w = w
    inst.h = h
    inst.minRoomSize = minRoomSize or 5

    inst.grid = _createOuterWalls(inst)
    _addOuterDoor(inst)

    return inst
end

return bspBuilding