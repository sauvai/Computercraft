os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.inventory)
os.loadAPI(files.utils)

local w1 = 1
local w2 = 1
local pathMaxLength = 20
local pathUpdateFrequency = 8
local mapPath = "data/map"

-- Node struct
local Node = {}

function Node.__init__(baseClass, position)
	self = {}
	setmetatable(self, { __index = Node })
	
	self.position = position
	self.cost = 0		-- f
	self.distance = 0	-- g
	self.heuristic = 0  -- h
	return self
end

setmetatable(Node, { __call = Node.__init__ })

-- PRIVATE
local north = "north"
local south = "south"
local east = "east"
local west = "west"
local up = "up"
local down = "down"

local directionWheel = { north, east, south, west }

local function GetMapKey(vector)
	return vector.x .. "," .. vector.y .. "," .. vector.z
end

local function GetDirection(displacement)
	if displacement.x == 1 then return east end
	if displacement.x == -1 then return west end
	if displacement.y == 1 then return up end
	if displacement.y == -1 then return down end
	if displacement.z == 1 then return south end
	if displacement.z == -1 then return north end
	return nil
end

local function ShortestPath(goal, currentPosition, map)
	local closedList = {}
	local openedList = { Node(currentPosition) }
	if goal:tostring() == currentPosition:tostring() then
		return { "up" } -- return a random direction to prevent A* to search indefinitly for nothing
	end
	
	-- Creating variable here instead of inside the loop for optimization purpose
	local currentNode
	local successors
	local currentSuccessor

	while #openedList > 0 do
		os.queueEvent("fakeEvent");
		os.pullEvent();
		currentNode = table.remove(openedList, 1)
		successors = {}
		if not (map[GetMapKey(vector.new(currentNode.position.x, currentNode.position.y - 1, currentNode.position.z))] == true) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y - 1, currentNode.position.z)))
		end
		if not (map[GetMapKey(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z + 1))] == true) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z + 1)))
		end
		if not (map[GetMapKey(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z - 1))] == true) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z - 1)))
		end
		if not (map[GetMapKey(vector.new(currentNode.position.x + 1, currentNode.position.y, currentNode.position.z))] == true) then
			table.insert(successors, Node(vector.new(currentNode.position.x + 1, currentNode.position.y, currentNode.position.z)))
		end
		if not (map[GetMapKey(vector.new(currentNode.position.x - 1, currentNode.position.y, currentNode.position.z))] == true) then
			table.insert(successors, Node(vector.new(currentNode.position.x - 1, currentNode.position.y, currentNode.position.z)))
		end
		if not (map[GetMapKey(vector.new(currentNode.position.x, currentNode.position.y + 1, currentNode.position.z))] == true) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y + 1, currentNode.position.z)))
		end
		
		for i = 1, #successors do
			currentSuccessor = successors[i]
			currentSuccessor.parent = currentNode
			
			if currentSuccessor.position:tostring() == goal:tostring() or utils.ManhattanDistance(currentSuccessor.position, currentPosition) >= pathMaxLength then
				local movements = {}
				while currentSuccessor.parent do
					local displacement = currentSuccessor.position - currentSuccessor.parent.position
					table.insert(movements, 1, GetDirection(displacement))
					currentSuccessor = currentSuccessor.parent
				end
				return movements
			end
			
			currentSuccessor.distance = currentNode.distance + 1
			currentSuccessor.heuristic = utils.ManhattanDistance(currentSuccessor.position, goal)
			currentSuccessor.cost = w1 * currentSuccessor.distance + w2 * currentSuccessor.heuristic
			
			local shouldSkip = false
			for j = 1, #openedList do
				if openedList[j].position:tostring() == currentSuccessor.position:tostring() and openedList[j].cost <= currentSuccessor.cost then
					shouldSkip = true
					break
				end
			end
			if not shouldSkip then
				for j = 1, #closedList do
					if closedList[j].position:tostring() == currentSuccessor.position:tostring() then
						shouldSkip = true
						break
					end
				end
			end
			if not shouldSkip then
				local j = 1
				while j <= #openedList and openedList[j].cost < currentSuccessor.cost do
					j = j + 1
				end
				table.insert(openedList, j, currentSuccessor)
			end
		end

		table.insert(closedList, currentNode)
	end
end

local function SaveScanToMap(worldPosition, map, scanner)
	local minDistance = scanner:GetRadius() * -1
	local maxDistance = scanner:GetRadius()

	for x = minDistance, maxDistance do
		for y = minDistance, maxDistance do
			for z = minDistance, maxDistance do
				if not (x == 0 and y == 0 and z == 0) then
					map[GetMapKey(worldPosition + vector.new(x, y, z))] = not scanner:IsEmptyBlock(x, y, z)
				end
			end
		end
	end
end

local function LoadMap()
	local map = {}
	local mapFS = fs.open(mapPath, "r")

	if mapFS then
		local line = mapFS.readLine()
		while line do
			map[line] = true
			line = mapFS.readLine()
		end
		mapFS.close()
	end
	return map
end

local function SaveMap(map)
	local mapFS = fs.open(mapPath, "w")

	for key,value in pairs(map) do
		if value then
			mapFS.writeLine(key)
		end
	end

	mapFS.close()
end

-- PUBLIC
function FindPath(...)
	local arrival = utils.VariadicToVector(arg)
	local position = Locate()
	if position:tostring() == arrival:tostring() then return end
	local scanner = inventory.EquipScanner()
	local map = LoadMap()
	local goal = arrival

	scanner:Scan()
	SaveScanToMap(position, map, scanner)
	
	if map[GetMapKey(arrival)] then
		local emptySpaces = utils.FindEmptySpacesArround(arrival - position, scanner)
		if #emptySpaces == 0 then error("Arrival is occupied and have no empty blocks arround", 2) end
		goal = utils.FindClosest(vector.new(0, 0, 0), table.unpack(emptySpaces)) + position
	else
		goal = arrival
	end

	return ShortestPath(goal, position, map)
end

function MoveTo(...)
	local arrival = utils.VariadicToVector(arg)
	print("Moving to", arrival)
	local position = Locate()
	if position:tostring() == arrival:tostring() then return end
	local scanner = inventory.EquipScanner()
	local map = LoadMap()
	local moveBeforeUpdatePath = 0
	local directions = {}
	local goal = arrival

	while position:tostring() ~= goal:tostring() do
		scanner:Scan()
		SaveScanToMap(position, map, scanner)
		
		if map[GetMapKey(arrival)] then
			local emptySpaces = utils.FindEmptySpacesArround(arrival - position, scanner)
			if #emptySpaces == 0 then error("Arrival is occupied and have no empty blocks arround", 2) end
			goal = utils.FindClosest(vector.new(0, 0, 0), table.unpack(emptySpaces)) + position
		else
			goal = arrival
		end
		if moveBeforeUpdatePath == 0 or #directions == 0 then
			directions = ShortestPath(goal, position, map)
			moveBeforeUpdatePath = pathUpdateFrequency
		end
		
		if directions == nil then
			os.reboot()
			error("No path found, position = "..position..", goal : "..goal, 2)
			return
		end
		
		local direction = table.remove(directions, 1)
		local ownDirection = GetOwnDirection()

		if direction == up then
			turtle.up();
		elseif direction == down then
			turtle.down()
		elseif direction == ownDirection then
			turtle.forward()
		else
			local owDirectionId
			local directionId
			for i = 1, #directionWheel do
				if ownDirection == directionWheel[i] then owDirectionId = i - 1 end
				if direction == directionWheel[i] then directionId = i - 1 end
			end
		
			local wheelTurn = directionId - owDirectionId
			if wheelTurn == 1 or wheelTurn == -3 then
				turtle.turnRight()
				turtle.forward()
			end
			if wheelTurn == 3 or wheelTurn == -1 then
				turtle.turnLeft()
				turtle.forward()
			end
			if wheelTurn == 2 or wheelTurn == -2 then
				turtle.back()
			end
		end
		
		position = Locate()
		moveBeforeUpdatePath = moveBeforeUpdatePath - 1
	end
	
	SaveMap(map)

	if position:tostring() ~= arrival:tostring() then
		FaceDirection(VectorToDirection(arrival - position))
	end
end

function FaceDirection(direction)
	if direction == up or direction == down then return end

	local ownDirection = GetOwnDirection()
	if direction == ownDirection then return end

	local owDirectionId
	local directionId
	for i = 1, #directionWheel do
		if ownDirection == directionWheel[i] then owDirectionId = i - 1 end
		if direction == directionWheel[i] then directionId = i - 1 end
	end

	local wheelTurn = directionId - owDirectionId
	if wheelTurn == 1 or wheelTurn == -3 then turtle.turnRight() end
	if wheelTurn == 3 or wheelTurn == -1 then turtle.turnLeft() end
	if wheelTurn == 2 or wheelTurn == -2 then
		turtle.turnLeft()
		turtle.turnLeft()
	end
end

function GetOwnDirection()
	local scanner = inventory.EquipScanner()
	scanner:Scan()
	return scanner:GetOwnDirection()
end

-- Return the direction (north, east, west, etc...) corresponding to the side (right, left, back, etc ...)
function SideToDirection(side)
	local scanner = inventory.EquipScanner()
	local ownDirection = GetOwnDirection()
	if side == "top" then return up end
	if side == "bottom" then return down end

	local wheelId
	for i = 1, #directionWheel do
		if ownDirection == directionWheel[i] then wheelId = i - 1 end
	end

	local wheelTurn = 0
	if side == "right" then wheelTurn = 1 end
	if side == "left" then wheelTurn = -1 end
	if side == "back" then wheelTurn = 2 end

	return directionWheel[(wheelId - wheelTurn) % 4 + 1]
end

function VectorToDirection(...)
	local v = utils.VariadicToVector(arg)

	if v.x == 1 then return east end
	if v.x == -1 then return west end
	if v.y == 1 then return up end
	if v.y == -1 then return down end
	if v.z == 1 then return south end
	if v.z == -1 then return north end

	error("Wrong vector format "..v:tostring(), 2)
end

function Locate()
	local v
	while not v or v.x ~= v.x or v.y ~= v.y or v.z ~= v.z or (v.x == 0 and v.y == 0 and v.z == 0) do
		v = vector.new(gps.locate())
	end
	config.ownPosition = v
	return v
end
