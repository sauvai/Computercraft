os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

local Scanner

local function FindBatteriesToReplace() 
	Scanner:Scan()

	local blocks = Scanner:FindBlocks(items.thermalExpansion.energyCell, items.computerCraft.computer)
	local batteries = blocks[items.thermalExpansion.energyCell]
	local computerPosition
	for _, computer in pairs(blocks[items.computerCraft.computer]) do
		if Scanner:GetBlockMeta(computer).computer.id == os.computerID() then
			computerPosition = computer
		end
	end

	local batteriesToReplace = {}
	for _, battery in pairs(batteries) do
		local rfData = Scanner:GetBlockMeta(battery).rf
		if (rfData.stored / rfData.capacity * 100 < config.batteryReplaceThreshold) then
			table.insert(batteriesToReplace, config.ownPosition + battery - computerPosition)
		end
	end

	return batteriesToReplace
end

function Manager()
	Scanner = scanner.New(utils.FindManipulator("plethora:scanner"))

	while true do
		sleep(5)
		for _, position in pairs(FindBatteriesToReplace()) do
			rednet.send(config.serverId, { position = position }, protocols.emptyBatteryDetected)
		end
	end
end
