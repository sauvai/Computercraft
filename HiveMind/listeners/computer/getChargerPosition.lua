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

	local chargerPosition

	for _, charger in pairs(chargers) do
		if #(utils.FindEmptySpacesArround(charger, Scanner)) > 0 then
			chargerPosition = googleMaps.Locate() + charger - computerPosition
		end
	end
	
	rednet.send(config.serverId, { position = chargerPosition }, data.answerProtocol)
end
