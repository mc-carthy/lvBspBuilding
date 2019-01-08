local Utils = require("src.utils")
local Mst = require('src.mst')

BspBuilding = Class()

local bsp_rng = love.math.newRandomGenerator(os.time())

local iteration = 0
local roomNumber = 1
local dontSplitProb = 35

function BspBuilding:pruneRooms(numRooms)
    for i = 1, numRooms do
        local roomIndex = math.random(#self.rooms)
        table.remove(self.rooms, roomIndex)
    end
end

function BspBuilding:createOuterWalls()
    local grid = {}
    for x = 1, self.w do
        grid[x] = {}
        for y = 1, self.h do
            grid[x][y] = {}
            if x == 1 or x == self.w or y == 1 or y == self.h then
                grid[x][y] = 'outerWall'
            end
        end
    end
    return grid
end

function BspBuilding:createRoom(x, y, w, h)
    for i = x, x + w do
        for j = y, y + h do
            if i == x or i == x + w or j == y or j == y + h then
                self.grid[i][j] = 'outerWall'
            end
        end
    end
    self:splitRoom(x, y, w, h)
end

function BspBuilding:demoWalls()
    for x = 1, self.w do
        for y = 1, self.h do
            local prob = bsp_rng:random(100)
            if self.grid[x][y] == 'outerWall' and prob > 95 then
                self.grid[x][y] = 'outerFloor'
            end
        end
    end
end

function BspBuilding:demoRoomWalls()
    for _, room in ipairs(self.rooms) do
        for _ = 1, 2 do
            local i = math.random(1, #room.edgeWalls)
            local demoWall = room.edgeWalls[i]
            self.grid[demoWall.x][demoWall.y].outerWall = false
        end
    end
end

function BspBuilding:demoNeighbourWall(room, neighbour)
    local sharedWalls = {}
    for _, selfWall in pairs(room.edgeWalls) do
        for _, nWall in pairs(neighbour.edgeWalls) do
            if selfWall.x == nWall.x and selfWall.y == nWall.y then
                table.insert(sharedWalls, selfWall)
            end
        end
    end
    local demoWall = sharedWalls[math.random(1, #sharedWalls)]
    self.grid[demoWall.x][demoWall.y] = 'outerFloor'
end

function BspBuilding:demoNeighbourWalls()
    for i, room in ipairs(self.rooms) do
        while #room.neighbours ~= 0 do
            for j, neighbour in ipairs(room.neighbours) do
                Utils.remove(room.neighbours, neighbour)
                Utils.remove(neighbour.neighbours, room)
                self:demoNeighbourWall(room, neighbour)
            end
        end
    end
end

function BspBuilding:createFinalRoom(x, y, w, h)
    local room = {
        number = roomNumber,
        x = x,
        y = y,
        w = w,
        h = h,
        floor = {},
        edgeWalls = {},
        cornerWalls = {},
        neighbours = {},
        debugColour = { math.random(0, 255) / 255, math.random(0, 255) / 255, math.random(0, 255) / 255, 1 }
    }
    for i = x, x + w do
        for j = y, y + h do
            if i == x or i == x + w or j == y or j == y + h then
                local wall = {
                    x = i,
                    y = j
                }
                if (i == x or i == x + w) and (j == y or j == y + h) then
                    table.insert(room.cornerWalls, wall)
                else
                    table.insert(room.edgeWalls, wall)
                end
            else 
                local floor = {
                    x = i,
                    y = j
                }
                table.insert(room.floor, floor)
            end
        end
    end
    roomNumber = roomNumber + 1
    table.insert(self.rooms, room)
end

function BspBuilding:setRoomNeighbours()
    for i, roomA in ipairs(self.rooms) do
        for x, edgeWallA in ipairs(roomA.edgeWalls) do
            for j, roomB in ipairs(self.rooms) do
                if roomA ~= roomB then
                    for y, edgeWallB in ipairs(roomB.edgeWalls) do
                        if edgeWallA.x == edgeWallB.x and edgeWallA.y == edgeWallB.y then
                            if not Utils.contains(roomA.neighbours, roomB) then
                                table.insert(roomA.neighbours, roomB)
                                table.insert(roomB.neighbours, roomA)
                                -- io.write(roomA.number .. " linked to " .. roomB.number)
                            end
                        end
                    end
                end
            end
        end
    end
end

local getRoomCoords = function(room)
    return { room.x + room.w / 2, room.y + room.h / 2 }
end

function BspBuilding:findRoomByCoords(coords)
    for k, room in pairs(self.rooms) do
        local roomCoords = getRoomCoords(room)
        if roomCoords[1] == coords[1] and roomCoords[2] == coords[2] then
            return room
        end
    end
    assert(false, 'Room not found at x: ' .. coords[1] .. '-' .. coords[2])
end

function BspBuilding:setRoomNeighboursMst()
    for k, room in pairs(self.rooms) do
        room.neighbours = {}
        for l, edge in pairs(self.tree) do
            local edgeX1, edgeY1, edgeX2, edgeY2 = edge[1], edge[2], edge[3], edge[4]
            local room1 = self:findRoomByCoords{ edgeX1, edgeY1 }
            local room2 = self:findRoomByCoords{ edgeX2, edgeY2 }

            if not Utils.contains(room1.neighbours, room2) and not Utils.contains(room2.neighbours, room1) then
                table.insert(room1.neighbours, room2)
                table.insert(room2.neighbours, room1)
            end
        end
    end
end

function BspBuilding:printRoomStatus()
    for i, room in ipairs(self.rooms) do
        io.write("Room number: " .. room.number .. "\n")
        io.write("Room centre: " .. room.x + room.w / 2 .. "-" .. room.y + room.h / 2 .. "\n")
        for j, wall in ipairs(room.cornerWalls) do
            io.write("Room number: " .. i .. " Wall at: " .. room.cornerWalls[j].x .. "-" .. room.cornerWalls[j].y .. "\n")
        end
        for j, wall in ipairs(room.edgeWalls) do
            io.write("Room number: " .. i .. " Wall at: " .. room.edgeWalls[j].x .. "-" .. room.edgeWalls[j].y .. "\n")
        end
    end
end

function BspBuilding.printPointsDataForMst()
    io.write('{')
    for i, room in ipairs(self.rooms) do
        local roomCentreX = room.x + room.w / 2
        local roomCentreY = room.y + room.h / 2
        io.write('{' .. roomCentreX .. ',' .. roomCentreY .. '}')
        if i < #self.rooms then
            io.write(',')
        end
    end
    io.write('}')
    print('')
end

function BspBuilding:getPointsDataForMst()
    local points = {}
    for i, room in ipairs(self.rooms) do
        local roomCentreX = room.x + room.w / 2
        local roomCentreY = room.y + room.h / 2
        table.insert(points, { roomCentreX, roomCentreY })
    end
    return points
end

function BspBuilding:printEdgeDataForMst()
    local edges = {}
    io.write('{')
    for i, room in ipairs(self.rooms) do
        local roomCentreX = room.x + room.w / 2
        local roomCentreY = room.y + room.h / 2
        for j, n in ipairs(room.neighbours) do
            local neighbourCentreX = n.x + n.w / 2
            local neighbourCentreY = n.y + n.h / 2
            local edge = { roomCentreX, roomCentreY, neighbourCentreX, neighbourCentreY }
            local reverseEdge = { neighbourCentreX, neighbourCentreY, roomCentreX, roomCentreY }
            if not Utils.contains(edges, edge) and not Utils.contains(edges, reverseEdge) then
                table.insert(edges, edge)
                io.write('{' .. roomCentreX .. ',' .. roomCentreY .. ',' .. neighbourCentreX .. ',' .. neighbourCentreY .. '}')
            end
            if j < #room.neighbours then
                io.write(',')
            end
        end
        if i < #self.rooms then
            io.write(',')
        end
    end
    io.write('}')
    print('')
end

function BspBuilding:getEdgeDataForMst()
    local edges = {}
    for i, room in ipairs(self.rooms) do
        local roomCentreX = room.x + room.w / 2
        local roomCentreY = room.y + room.h / 2
        for j, n in ipairs(room.neighbours) do
            local neighbourCentreX = n.x + n.w / 2
            local neighbourCentreY = n.y + n.h / 2
            local edge = { roomCentreX, roomCentreY, neighbourCentreX, neighbourCentreY }
            local reverseEdge = { neighbourCentreX, neighbourCentreY, roomCentreX, roomCentreY }
            if not Utils.contains(edges, edge) and not Utils.contains(edges, reverseEdge) then
                table.insert(edges, edge)
            end
        end
    end
    return edges
end

--[[
    x and y represent top-left corner coord
--]] 
function BspBuilding:splitRoom(x, y, w, h, minRoomSize)
    iteration = iteration + 1
    dontSplitProb = dontSplitProb + 5
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
    if (max < minRoomSize) or (iteration > 2 and prob2 < dontSplitProb) then 
            self:createFinalRoom(x, y, w, h)
        return
    end

    local split = love.math.random(minRoomSize, max)

    if splitH then
        self:createRoom(x, y + split, w, h - split)
        iteration = 0
        self:createRoom(x, y, w, split)
        iteration = 0
    else
        self:createRoom(x + split, y, w - split, h)
        iteration = 0
        self:createRoom(x, y, split, h)
        iteration = 0
    end

    return true

end

function BspBuilding.addOuterDoor()
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

function BspBuilding:init(w, h, minRoomSize)
    self.grid = {}
    self.rooms = {}
    self.w = w
    self.h = h
    self.minRoomSize = minRoomSize or 5

    self.grid = self:createOuterWalls()
    -- self:addOuterDoor()

    self:createRoom(1, 1, w - 1, h - 1)
    self:pruneRooms(math.floor(#self.rooms * 0.2))
    self:setRoomNeighbours()
    self.points = self:getPointsDataForMst()
    self.edges = self:getEdgeDataForMst()
    self.tree = Mst.tree(self.points, self.edges)
    -- printRoomStatus()
    -- printPointsDataForMst()
    -- printEdgeDataForMst()
    self:setRoomNeighboursMst()
    -- demoWalls()
    -- demoRoomWalls()
    self:demoNeighbourWalls()
    self:setRoomNeighboursMst()
    -- setRoomNeighbours()
end