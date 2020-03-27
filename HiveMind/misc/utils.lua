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

	if scanner:IsEmptyBlock(block + vector.new(1, 0, 0)) then table.insert(emptyBlocks, block + vector.new(1, 0, 0)) end
	if scanner:IsEmptyBlock(block - vector.new(1, 0, 0)) then table.insert(emptyBlocks, block - vector.new(1, 0, 0)) end
	if scanner:IsEmptyBlock(block + vector.new(0, 1, 0)) then table.insert(emptyBlocks, block + vector.new(0, 1, 0)) end
	if scanner:IsEmptyBlock(block - vector.new(0, 1, 0)) then table.insert(emptyBlocks, block - vector.new(0, 1, 0)) end
	if scanner:IsEmptyBlock(block + vector.new(0, 0, 1)) then table.insert(emptyBlocks, block + vector.new(0, 0, 1)) end
	if scanner:IsEmptyBlock(block - vector.new(0, 0, 1)) then table.insert(emptyBlocks, block - vector.new(0, 0, 1)) end

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

function VariadicToVector(arg)
	if #arg == 1 then
		if type(arg[1]) ~= "table" then
			error("VariadicToVector: argument should be a vector (table), instead received " .. tostring(arg[1]), 2)
		end
		return vector.new(arg[1].x, arg[1].y, arg[1].z)
	elseif #arg == 3 then
		if type(arg[1]) ~= "number" then
			error("VariadicToVector: argument #1 should be a number, instead received "..tostring(arg[1]), 2)
		elseif type(arg[2]) ~= "number" then
			error("VariadicToVector: argument #2 should be a number, instead received "..tostring(arg[2]), 2)
		elseif type(arg[3]) ~= "number" then
			error("VariadicToVector: argument #3 should be a number, instead received "..tostring(arg[3]), 2)
		end
		return vector.new(arg[1], arg[2], arg[3])
	else
		error("VariadicToVector: only accept 1 (vector) or 3 arguments (x, y, z), instead received " .. tostring(#arg), 2)
	end
end