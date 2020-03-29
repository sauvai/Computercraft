os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.items)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

function Listener(id, data)
	local Scanner = scanner.New(utils.FindManipulator("plethora:scanner"))
	Scanner:Scan()

	local blocks = Scanner:FindBlocks(items.peripheralsPlusOne.meBridge, items.computerCraft.computer)
	local meBridges = blocks[items.peripheralsPlusOne.meBridge]
	local computerPosition
	for _, computer in pairs(blocks[items.computerCraft.computer]) do
		if Scanner:GetBlockMeta(computer).computer.id == os.computerID() then
			computerPosition = computer
		end
	end
	
	local meBridgePosition

	for _, meBridge in pairs(meBridges) do
		if #(utils.FindEmptySpacesArround(meBridge, Scanner)) > 0 then
			meBridgePosition = googleMaps.Locate() + meBridge - computerPosition
		end
	end

	rednet.send(config.serverId, { position = meBridgePosition }, data.answerProtocol)
end
