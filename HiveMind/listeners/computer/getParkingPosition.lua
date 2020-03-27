os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.items)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

function Listener(id, data)
	local Scanner = scanner.New(utils.FindManipulator("plethora:scanner"))
	Scanner:Scan()

	local blocks = Scanner:FindBlocks(items.peripheralsPlusOne.rfCharger, items.ae2.interface, items.computerCraft.computer)
	local chargers = blocks[items.peripheralsPlusOne.rfCharger]
	local interface = blocks[items.ae2.interface][1]
	local computerPosition
	for _, computer in pairs(blocks[items.computerCraft.computer]) do
		if Scanner:GetBlockMeta(computer).computer.id == os.computerID() then
			computerPosition = computer
		end
	end

	-- Find empty spaces arround chargers
	local chargerPosition
	for _, charger in pairs(chargers) do
		chargerPosition = utils.FindEmptySpacesArround(charger, Scanner)[1]
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
		local interfacePosition = utils.FindEmptySpacesArround(interface, Scanner)[1]
		-- Transform local position to world position
		if interfacePosition ~= nil then
			messageData.interface.facing = googleMaps.VectorToDirection(interface - interfacePosition)
			interfacePosition = googleMaps.Locate() + interfacePosition - computerPosition
		end
		messageData.interface.position = interfacePosition
	end

	rednet.send(config.serverId, messageData, data.answerProtocol)
end
