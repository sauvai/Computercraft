function VectorToString(vector)
	local positionString
	if vector == nil then
		positionString = "nil"
	else
		positionString = tostring(vector.x) .. ", " .. tostring(vector.y) .. ", " .. tostring(vector.z)
	end
	return positionString
end

function FindManipulator(module)
	for _, side in pairs(peripheral.getNames()) do
		if peripheral.getType(side) == "manipulator" and peripheral.call(side, "hasModule", module) then
			return peripheral.wrap(side)
		end
	end
	error("Manipulator with "..module.." not found", 2)
end

function FindPeripheral(peripheralName)
	for _, side in pairs(peripheral.getNames()) do
		if peripheral.getType(side) == peripheralName then
			return peripheral.wrap(side), side
		end
	end
	error(peripheralName.." not found", 2)
end

function FindEmptySpacesArround(block, scanner)
	local emptyBlocks = {}

	if scanner:IsEmptyBlock(block.x + 1, block.y, block.z) then table.insert(emptyBlocks, vector.new(block.x + 1, block.y, block.z)) end
	if scanner:IsEmptyBlock(block.x - 1, block.y, block.z) then table.insert(emptyBlocks, vector.new(block.x - 1, block.y, block.z)) end
	if scanner:IsEmptyBlock(block.x, block.y + 1, block.z) then table.insert(emptyBlocks, vector.new(block.x, block.y + 1, block.z)) end
	if scanner:IsEmptyBlock(block.x, block.y - 1, block.z) then table.insert(emptyBlocks, vector.new(block.x, block.y - 1, block.z)) end
	if scanner:IsEmptyBlock(block.x, block.y, block.z + 1) then table.insert(emptyBlocks, vector.new(block.x, block.y, block.z + 1)) end
	if scanner:IsEmptyBlock(block.x, block.y, block.z - 1) then table.insert(emptyBlocks, vector.new(block.x, block.y, block.z - 1)) end

	return emptyBlocks
end

function ManhattanDistance(v1, v2)
	if type(v1) ~= "table" then error("ManhattanDistance: Vector 1 is not a table", 2) end
	if type(v2) ~= "table" then error("ManhattanDistance: Vector 2 is not a table", 2) end

	return math.abs(v1.x - v2.x) + math.abs(v1.y - v2.y) + math.abs(v1.z - v2.z)
end

function FindClosest(position, ...)
	if #arg == 0 then error("FindClosest: no arguments sent") end

	local minDistance = 9999999
	local closest = position
	for i = 1, #arg do
		local currentDistance = ManhattanDistance(position, arg[i])
		if currentDistance < minDistance then
			minDistance = currentDistance
			closest = arg[i]
		end
	end

	return closest
end
