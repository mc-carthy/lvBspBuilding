local bspBuilding = {}

local bsp_rng = love.math.newRandomGenerator(os.time())

local iteration = 0

local function _createOuterWalls(self)
    local grid = {}
    for x = 1, self.w do
        grid[x] = {}
        for y = 1, self.h do
            grid[x][y] = {}
            if x == 1 or x == self.w or y == 1 or y == self.h then
                grid[x][y].outerWall = false
            end
        end
    end
    return grid
end

local function _createRoom(self, x, y, w, h)
    for i = x, x + w do
        for j = y, y + h do
            if i == x or i == x + w or j == y or j == y + h then
                self.grid[i][j].outerWall = true
            end
        end
    end
    self._splitRoom(self, x, y, w, h)
end

local _demoWalls = function(self)
    for x = 1, self.w do
        for y = 1, self.h do
            local prob = bsp_rng:random(100)
            if self.grid[x][y].outerWall and prob > 95 then
                self.grid[x][y].outerWall = false
            end
        end
    end
end

--[[
    x and y represent top-left corner coord
--]] 
local function _splitRoom(self, x, y, w, h, minRoomSize)
    iteration = iteration + 1
    local minRoomSize = minRoomSize or 10
    local prob = bsp_rng:random(100)
    local splitH = nil
    
    if prob > 50 then
        splitH = true
    else
        splitH = false
    end

    if h / w > 1.25 then
        splitH = true
    elseif w / h > 1.25 then
        splitH = false
    end

    local max = 0

    if splitH then
        max = h - minRoomSize
    else
        max = w - minRoomSize
    end

    local prob2 = bsp_rng:random(100)
    -- TODO remove hard-coded values
    if (max < minRoomSize) or (iteration > 2 and prob2 < 35) then 
        return
    end

    local split = love.math.random(minRoomSize, max)

    if splitH then
        self:_createRoom(x, y + split, w, h - split)
        iteration = 0
        self:_createRoom(x, y, w, split)
        iteration = 0
    else
        self:_createRoom(x + split, y, w - split, h)
        iteration = 0
        self:_createRoom(x, y, split, h)
        iteration = 0
    end

    return true

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
    -- _addOuterDoor(inst)

    inst._createRoom = _createRoom
    inst._splitRoom = _splitRoom

    _createRoom(inst, 1, 1, w - 1, h - 1)
    _demoWalls(inst)
    return inst
end

return bspBuilding