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

-- Private properties
local north = "north"
local south = "south"
local east = "east"
local west = "west"
local up = "up"
local down = "down"

local direction = { north, east, south, west }

local scanner

-- Private functions
local function sortNodeByCost(n1, n2)
	if n1.cost == n2.cost then return n1.distance >= n2.distance end
	return n1.cost <= n2.cost
end

local function manhattanDistance(v1, v2)
	return math.abs(v1.x - v2.x) + math.abs(v1.y - v2.y) + math.abs(v1.z - v2.z)
end

local function isEmptyBlock(x, y, z)
	local block = scanner:GetBlock(x, y, z)
	return block == nil or block.name == "minecraft:air" or block.name == "minecraft:flowing_water" or block.name == "minecraft:flowing_lava"
end

local function shortestPath(goal)
	local closedList = {}
	local openedList = { Node(vector.new(0, 0, 0), 0, 0, 0) }
	local n = 0

	while next(openedList) ~= nil do
		local currentNode = table.remove(openedList, 1)
		local successors = {
			Node(vector.new(currentNode.position.x + 1, currentNode.position.y, currentNode.position.z), 0, 0, 0),
			Node(vector.new(currentNode.position.x - 1, currentNode.position.y, currentNode.position.z), 0, 0, 0),
			Node(vector.new(currentNode.position.x, currentNode.position.y + 1, currentNode.position.z), 0, 0, 0),
			Node(vector.new(currentNode.position.x, currentNode.position.y - 1, currentNode.position.z), 0, 0, 0),
			Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z + 1), 0, 0, 0),
			Node(vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z - 1), 0, 0, 0)
		}

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
			currentSuccessor.heuristic = manhattanDistance(currentSuccessor.position, goal)
			currentSuccessor.cost = currentSuccessor.distance + currentSuccessor.heuristic

			local shouldSkip = not isEmptyBlock(currentSuccessor.position.x, currentSuccessor.position.y, currentSuccessor.position.z)
			for j = 1, #openedList do
				if openedList[j].position:tostring() == currentSuccessor.position:tostring() and openedList[j].cost <= currentSuccessor.cost then
					shouldSkip = true
				end
			end
			for j = 1, #closedList do
				if closedList[j].position:tostring() == currentSuccessor.position:tostring() and closedList[j].cost <= currentSuccessor.cost then
					shouldSkip = true
				end
			end

			if shouldSkip == false then
				-- local index = 1
				-- while index <= #openendList and currentSuccessor.cost >= openedList[index] do
				-- end
				table.insert(openedList, currentSuccessor)
			end
		end

		table.insert(closedList, currentNode)
		table.sort(openedList, sortNodeByCost)
	end
end

local function getGoal(arrival)
	local worldPosition = vector.new(gps.locate())
	local closestPosition = vector.new(0, 0, 0)

	local closestDistance = manhattanDistance(arrival, worldPosition)

	for x = scanner:GetRadius() * -1, scanner:GetRadius() do
		for y = scanner:GetRadius() * -1, scanner:GetRadius() do
			for z = scanner:GetRadius() * -1, scanner:GetRadius() do
				if isEmptyBlock(x, y, z) then
					local position = worldPosition + vector.new(x, y, z)
					local distance = manhattanDistance(arrival, position)
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

function moveTo(arrival, _scanner)
	scanner = _scanner

	local position = vector.new(gps.locate())

	while position:tostring() ~= arrival:tostring() do
		scanner:Scan()
		local goal = getGoal(arrival)
		local direction = shortestPath(goal)

		if direction == nil then
			print("ERROR: no path found")
			return
		end

		if direction == up then
			turtle.up();
		elseif direction == down then
			turtle.down()
		else -- TODO: improve turning (could do just backward instead of 2 turn and 1 forward, or 1 turnLeft instead of 3 turnRight)
			while direction ~= scanner:GetOwnDirection() do
				turtle.turnRight()
				scanner:Scan()
			end
			turtle.forward()
		end

		position = vector.new(gps.locate())
	end
end
