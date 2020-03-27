os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.items)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

function Listener(id, data)
	local Scanner = scanner.New(utils.FindManipulator("plethora:scanner"))
	Scanner:Scan()

	local blocks = Scanner:FindBlocks(items.peripheralsPlusOne.rfCharger, items.computerCraft.computer)
	local chargers = blocks[items.peripheralsPlusOne.rfCharger]
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
		position = chargerPosition
	}

	rednet.send(config.serverId, messageData, data.answerProtocol)
end
