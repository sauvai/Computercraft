os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.items)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

local function FindEmptySpaceArround(block, scanner)
	if scanner:IsEmptyBlock(block.x + 1, block.y, block.z) then return vector.new(block.x + 1, block.y, block.z) end
	if scanner:IsEmptyBlock(block.x - 1, block.y, block.z) then return vector.new(block.x - 1, block.y, block.z) end
	if scanner:IsEmptyBlock(block.x, block.y + 1, block.z) then return vector.new(block.x, block.y + 1, block.z) end
	if scanner:IsEmptyBlock(block.x, block.y - 1, block.z) then return vector.new(block.x, block.y - 1, block.z) end
	if scanner:IsEmptyBlock(block.x, block.y, block.z + 1) then return vector.new(block.x, block.y, block.z + 1) end
	if scanner:IsEmptyBlock(block.x, block.y, block.z - 1) then return vector.new(block.x, block.y, block.z - 1) end

	return nil
end

function Listener(id, data)
	local s = scanner.New(utils.FindManipulator("plethora:scanner"))
	s:Scan()

	local minDistance = s:GetRadius() * -1
	local maxDistance = s:GetRadius()

	local computerPosition
	local interface
	local chargers = {}
	-- Find chargers, interface and computer positions
	for x = minDistance, maxDistance do
		for y = minDistance, maxDistance do
			for z = minDistance, maxDistance do
				if s:GetBlock(x, y, z).name == items.peripheralsPlusOne.rfCharger then
					table.insert(chargers, vector.new(x, y, z))
				end
				if s:GetBlock(x, y, z).name == items.ae2.interface then
					interface = vector.new(x, y, z)
				end
				if s:GetBlock(x, y, z).name == items.computerCraft.computer and s:GetBlockMeta(x, y, z).computer.id == os.computerID() then
					computerPosition = vector.new(x, y, z)
				end
			end
		end
	end

	-- Find empty spaces arround chargers
	local chargerPosition
	for _, charger in pairs(chargers) do
		chargerPosition = FindEmptySpaceArround(charger, s)
		if chargerPosition ~= nil then break end
	end
	-- Transform local position to world position
	if chargerPosition ~= nil then
		chargerPosition = googleMaps.Locate() + chargerPosition - computerPosition
	end
	
	local messageData = {
		chargerPosition = chargerPosition,
		interface = {}
	}

	-- Find empty spaces arround interface
	if interface ~= nil then
		local interfacePosition = FindEmptySpaceArround(interface, s)
		-- Transform local position to world position
		if interfacePosition ~= nil then
			messageData.interface.facing = googleMaps.VectorToDirection(interface - interfacePosition)
			interfacePosition = googleMaps.Locate() + interfacePosition - computerPosition
		end
		messageData.interface.position = interfacePosition
	end

	rednet.send(config.serverId, messageData, data.answerProtocol)
end
