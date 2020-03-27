os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

local Scanner

local function FindBatteryChargingSpacesAvailable()
	Scanner:Scan()

	local blocks = Scanner:FindBlocks(items.thermalDynamics.fluxDuct, items.computerCraft.computer)
	local fluxDucts = blocks[items.thermalDynamics.fluxDuct]
	local computerPosition
	for _, computer in pairs(blocks[items.computerCraft.computer]) do
		if Scanner:GetBlockMeta(computer.x, computer.y, computer.z).computer.id == os.computerID() then
			computerPosition = computer
		end
	end

	local batteriesToPlace = {}
	for _, fluxDuct in pairs(fluxDucts) do
		if Scanner:IsEmptyBlock(fluxDuct.x, fluxDuct.y - 1, fluxDuct.z) then
			table.insert(batteriesToPlace, googleMaps.Locate() + fluxDuct - vector.new(0, 1, 0) - computerPosition)
		end
	end
	
	return batteriesToPlace
end

function Manager()
	Scanner = scanner.New(utils.FindManipulator("plethora:scanner"))

	while true do
		sleep(5)
		for _, position in pairs(FindBatteryChargingSpacesAvailable()) do
			rednet.send(config.serverId, { position = position }, protocols.batteryChargingSpaceDetected)
		end
	end
end
