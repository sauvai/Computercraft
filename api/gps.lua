os.loadAPI("api/inventory.lua")

local w1 = 1
local w2 = 1

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

local function ShortestPath(goal, scanner)
	local closedList = {}
	local openedList = { Node(vector.new(0, 0, 0), 0, 0, 0) }

	while next(openedList) ~= nil do
		os.queueEvent("fakeEvent");
		os.pullEvent();
		local currentNode = table.remove(openedList, 1)
		local successors = {}

		if currentNode.position.z + 1 < 10 and scanner:IsEmptyBlock(currentNode.position.x, currentNode.position.y, currentNode.position.z + 1) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z + 1), 0, 0, 0))
		end
		if currentNode.position.z - 1 > -10 and scanner:IsEmptyBlock(currentNode.position.x, currentNode.position.y, currentNode.position.z - 1) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z - 1), 0, 0, 0))
		end
		if currentNode.position.x + 1 < 10 and scanner:IsEmptyBlock(currentNode.position.x + 1, currentNode.position.y, currentNode.position.z) then
			table.insert(successors, Node(vector.new(currentNode.position.x + 1, currentNode.position.y, currentNode.position.z), 0, 0, 0))
		end
		if currentNode.position.x - 1 > -10 and scanner:IsEmptyBlock(currentNode.position.x - 1, currentNode.position.y, currentNode.position.z) then
			table.insert(successors, Node(vector.new(currentNode.position.x - 1, currentNode.position.y, currentNode.position.z), 0, 0, 0))
		end
		if currentNode.position.y + 1 < 10 and scanner:IsEmptyBlock(currentNode.position.x, currentNode.position.y + 1, currentNode.position.z) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y + 1, currentNode.position.z), 0, 0, 0))
		end
		if currentNode.position.y - 1 > -10 and scanner:IsEmptyBlock(currentNode.position.x, currentNode.position.y - 1, currentNode.position.z) then
			table.insert(successors, Node(vector.new(currentNode.position.x, currentNode.position.y - 1, currentNode.position.z), 0, 0, 0))
		end

		for i = 1, #successors do
			local currentSuccessor = successors[i]
			currentSuccessor.parent = currentNode

			if currentSuccessor.position:tostring() == goal:tostring() then
				while currentSuccessor.parent.position:tostring() ~= vector.new(0, 0, 0):tostring() do
					currentSuccessor = currentSuccessor.parent
				end

				if currentSuccessor.position.x == 1 then return east end
				if currentSuccessor.position.x == -1 then return west end
				if currentSuccessor.position.y == 1 then return up end
				if currentSuccessor.position.y == -1 then return down end
				if currentSuccessor.position.z == 1 then return south end
				if currentSuccessor.position.z == -1 then return north end

				return nil
			end

			currentSuccessor.distance = currentNode.distance + 1
			currentSuccessor.heuristic = ManhattanDistance(currentSuccessor.position, goal)
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

			if shouldSkip == false then
				local k = 1
				while k <= #openedList and openedList[k].cost < currentSuccessor.cost do
					k = k + 1
				end
				table.insert(openedList, k, currentSuccessor)
			end
		end

		table.insert(closedList, currentNode)
	end
end

local function GetGoal(arrival, scanner)
	local worldPosition = Locate()
	local closestPosition = vector.new(0, 0, 0)

	local closestDistance = ManhattanDistance(arrival, worldPosition)
	local minDistance = scanner:GetRadius() * -1 - 1
	local maxDistance = scanner:GetRadius() + 1

	for x = minDistance, maxDistance do
		for y = minDistance, maxDistance do
			for z = minDistance, maxDistance do
				if scanner:IsEmptyBlock(x, y, z) then
					local position = worldPosition + vector.new(x, y, z)
					local distance = ManhattanDistance(arrival, position)
					if distance < closestDistance then
						closestPosition = vector.new(x, y, z)
						closestDistance = distance
					end
				end
			end
		end
	end

	return closestPosition
end


-- PUBLIC
function MoveTo(arrival)
	local scanner = inventory.EquipScanner()
	local position = Locate()

	while position:tostring() ~= arrival:tostring() do
		scanner:Scan()

		local goal = GetGoal(arrival, scanner)
		local direction = ShortestPath(goal, scanner)

		if direction == nil then
			print("ERROR: no path found")
			return
		end

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
	end
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
