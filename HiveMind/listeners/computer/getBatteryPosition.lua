os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.items)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

function Listener(id, data)
	local Scanner = scanner.New(utils.FindManipulator("plethora:scanner"))
	Scanner:Scan()

	local blocks = Scanner:FindBlocks(items.thermalExpansion.energyCell, items.computerCraft.computer)
	local batteries = blocks[items.thermalExpansion.energyCell]
	local computerPosition
	for _, computer in pairs(blocks[items.computerCraft.computer]) do
		if Scanner:GetBlockMeta(computer).computer.id == os.computerID() then
			computerPosition = computer
		end
	end

	local maxRF = 0
	local maxFilledBattery = batteries[1]
	for _, battery in pairs(batteries) do
		local rfData = Scanner:GetBlockMeta(battery).rf
		if rfData.stored > maxRF then
			maxRF = rfData.stored
			maxFilledBattery = battery
		end
	end

	-- Transform local position to world position
	if maxFilledBattery ~= nil then
		maxFilledBattery = config.ownPosition + maxFilledBattery - computerPosition
	end
	
	rednet.send(config.serverId, { position = maxFilledBattery }, data.answerProtocol)
end
