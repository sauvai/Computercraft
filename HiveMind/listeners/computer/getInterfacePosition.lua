os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.items)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

function Listener(id, data)
	local Scanner = scanner.New(utils.FindManipulator("plethora:scanner"))
	Scanner:Scan()

	local blocks = Scanner:FindBlocks(items.ae2.interface, items.computerCraft.computer)
	local interfaces = blocks[items.ae2.interface]
	local computerPosition
	for _, computer in pairs(blocks[items.computerCraft.computer]) do
		if Scanner:GetBlockMeta(computer).computer.id == os.computerID() then
			computerPosition = computer
		end
	end
	
	local interfacePosition

	for _, interface in pairs(interfaces) do
		if #(utils.FindEmptySpacesArround(interface, Scanner)) > 0 then
			interfacePosition = googleMaps.Locate() + interface - computerPosition
		end
	end

	rednet.send(config.serverId, { position = interfacePosition }, data.answerProtocol)
end
