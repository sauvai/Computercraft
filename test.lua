os.loadAPI("api/inventory.lua")

local w1 = 1
local w2 = 10
local pathUpdateFrequency = 5

-- Node struct
local Node = {}

function Node.__init__(baseClass, position, cost, distance, heuristic)
	self = {}
	setmetatable(self, { __index = Node })
	
	self.position = position
	self.cost = cost			-- f
	self.distance = distance	-- g
	self.heuristic = heuristic  -- h
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

local direction = { north, east, south, west }

local function ManhattanDistance(v1, v2)
	return math.abs(v1.x - v2.x) + math.abs(v1.y - v2.y) + math.abs(v1.z - v2.z)
end

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

local function ShortestPath(goal, map)
	local currentPosition = Locate()
	local closedList = {}
	local openedList = { Node(currentPosition, 0, 0, 0) }
	
	while #openedList > 0 do
		os.queueEvent("fakeEvent");
		os.pullEvent();
		local currentNode = table.remove(openedList, 1)
		local successors = {
			Node(vector.new(currentNode.position.x, currentNode.position.y - 1, currentNode.position.z), 0, 0, 0),
			Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z + 1), 0, 0, 0),
			Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z - 1), 0, 0, 0),
			Node(vector.new(currentNode.position.x + 1, currentNode.position.y, currentNode.position.z), 0, 0, 0),
			Node(vector.new(currentNode.position.x - 1, currentNode.position.y, currentNode.position.z), 0, 0, 0),
			Node(vector.new(currentNode.position.x, currentNode.position.y + 1, currentNode.position.z), 0, 0, 0),
		}
		
		for i = 1, #successors do
			local currentSuccessor = successors[i]
			currentSuccessor.parent = currentNode
			
			if currentSuccessor.position:tostring() == goal:tostring() then
				local movements = {}
				while currentSuccessor.parent do
					local displacement = currentSuccessor.position - currentSuccessor.parent.position
					table.insert(movements, 1, GetDirection(displacement))
					currentSuccessor = currentSuccessor.parent
				end
				return movements
			end
			
			currentSuccessor.distance = currentNode.distance + 1
			currentSuccessor.heuristic = ManhattanDistance(currentSuccessor.position, goal)
			currentSuccessor.cost = w1 * currentSuccessor.distance + w2 * currentSuccessor.heuristic
			
			local block = map[GetMapKey(currentSuccessor.position)]
			if block == nil then
				currentSuccessor.distance = currentSuccessor.distance + 1
				block = false
			end
	
			local shouldSkip = block
			if not shouldSkip then
				for j = 1, #openedList do
					if openedList[j].position:tostring() == currentSuccessor.position:tostring() and openedList[j].cost <= currentSuccessor.cost then
						shouldSkip = true
						break
					end
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
				local k = 1
				while k <= #openedList and openedList[k].cost < currentSuccessor.cost do
					k = k + 1
				end
				table.insert(openedList, k, currentSuccessor)
			end
		end

		-- sleep(1)
		table.insert(closedList, currentNode)
	end
end

local function SaveScanToMap(map, scanner)
	local worldPosition = Locate()

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

	return closestPosition
end

local function LoadMap()
	local map = {}
	local mapFS = fs.open("api/data/map", "r")

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
	local mapFS = fs.open("api/data/map", "w")

	for key,value in pairs(map) do
		if value then
			mapFS.writeLine(key)
		end
	end

	mapFS.close()
end

-- PUBLIC
function MoveTo(arrival)
	local scanner = inventory.EquipScanner()
	local position = Locate()
	local map = LoadMap()
	local moveBeforeUpdatePath = 0
	local directions

	while position:tostring() ~= arrival:tostring() do
		scanner:Scan()
		SaveScanToMap(map, scanner)
		
		if moveBeforeUpdatePath == 0 or #directions == 0 then
			directions = ShortestPath(arrival, map)
			moveBeforeUpdatePath = pathUpdateFrequency
		end
		
		if directions == nil then
			print("ERROR: no path found")
			return
		end
		
		local direction = table.remove(directions, 1)
		if direction == up then
			turtle.up();
		elseif direction == down then
			turtle.down()
		else
			while direction ~= GetOwnDirection() do
				turtle.turnRight()
			end
			turtle.forward()
		end
		
		position = Locate()
		moveBeforeUpdatePath = moveBeforeUpdatePath - 1

		while #map > 900000 do
			table.remove(map, 1)
		end
	end
	
	SaveMap(map)
end

function FaceDirection(direction)
	while direction ~= GetOwnDirection() do
		turtle.turnRight()
	end
end

function GetOwnDirection()
	local scanner = inventory.EquipScanner()
	scanner:Scan()
	return scanner:GetOwnDirection()
end

function Locate()
	return vector.new(gps.locate())
end

MoveTo(vector.new(-519, 156, -1293))
print(fs.getSize("api/data/map"))
print(fs.getFreeSpace("api/data/map"))