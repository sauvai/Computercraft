os.loadAPI("const/files.lua")
os.loadAPI(files.events)
os.loadAPI(files.entities)
os.loadAPI(files.items)
os.loadAPI(files.labels)
os.loadAPI(files.multitasks)
os.loadAPI(files.utils)

--      Task structure
-- {
--		
-- 		protocol = "Free",
--		id = ...,
-- 		data = {  }
-- }

local tasks = {}

local function WaitForComputerToConnect(label)
	print("Waiting for", label, "to connect...")
	
	local computer

	while computer == nil do
		local _, id = os.pullEvent(events.computerRegistered)
		computer = entities.Get("computer", id, label)
	end

	return computer
end

local function GetChargerPosition() -- TODO get all parking manager to get the closest charger
	local parkingManager = entities.Get("computer", nil, labels.parkingManager)[1]
	local answerProtocol = tostring(os.clock())

	if parkingManager == nil then
		parkingManager = WaitForComputerToConnect(labels.parkingManager)
	end

	rednet.send(parkingManager.id, { answerProtocol = answerProtocol }, protocols.getChargerPosition)
	local _, data = rednet.receive(answerProtocol)

	return data.position
end

local function GetInterfacePosition() -- TODO get all parking manager to get the closest interface
	local parkingManager = entities.Get("computer", nil, labels.parkingManager)[1]
	local answerProtocol = tostring(os.clock())

	if parkingManager == nil then
		parkingManager = WaitForComputerToConnect(labels.parkingManager)
	end

	rednet.send(parkingManager.id, { answerProtocol = answerProtocol }, protocols.getInterfacePosition)
	local _, data = rednet.receive(answerProtocol)

	return data.interface
end

local function GetChargedBatteryPosition() -- TODO get all battery farmer to get the fullest and closest battery
	local batteryFarmer = entities.Get("computer", nil, labels.batteryFarmer)[1]
	local answerProtocol = tostring(os.clock())

	if batteryFarmer == nil then
		batteryFarmer = WaitForComputerToConnect(labels.batteryFarmer)
	end

	rednet.send(batteryFarmer.id, { answerProtocol = answerProtocol }, protocols.getBatteryPosition)
	local _, data = rednet.receive(answerProtocol)

	return data.position
end

local function AssignTask(turtle)
	if turtle.task.protocol == protocols.free then
		turtle.task.data = { chargerPosition = GetChargerPosition(), interface = GetInterfacePosition() }
	end
	
	if turtle.task.protocol == protocols.replaceBattery then
		turtle.task.data.batteryToPickup = GetChargedBatteryPosition()
		turtle.task.data.interface = GetInterfacePosition()
	end

	if turtle.task.protocol == protocols.chargeBattery then
		turtle.task.data.interface = GetInterfacePosition()
	end

	rednet.send(turtle.id, turtle.task.data, turtle.task.protocol)
	print("Assigned task " .. turtle.task.protocol .. " to turtle " .. turtle.label)
end

local function UpdateTasks()
	for _, turtle in pairs(entities.Get("turtle")) do
		if #tasks == 0 then return end

		if turtle.task == nil then
			turtle.task = table.remove(tasks, 1)
			multitasks.CreateTask(AssignTask, turtle)
		end
	end
end

local function IsDuplicate(protocol, id)
	for _, task in pairs(tasks) do
		if task.protocol == protocol and task.id == id then return true end
	end
	for _, turtle in pairs(entities.Get("turtle")) do
		if turtle.task and turtle.task.protocol == protocol and turtle.task.id == id then return true end
	end
	return false
end

function Manager()
	while true do
		local event, param1 = os.pullEvent()

		if event == events.turtleRegistered then
			local turtle = entities.Get("turtle", param1)
			turtle.task = { protocol = protocols.free, id = turtle.id }
			multitasks.CreateTask(AssignTask, turtle)
		end
		
		if event == events.taskFinished then
			local turtle = entities.Get("turtle", param1)
			if turtle.task.protocol == protocols.free then
				turtle.task = nil
				UpdateTasks()
			else
				turtle.task = { protocol = protocols.free, id = turtle.id }
				multitasks.CreateTask(AssignTask, turtle)	
			end
		end

		if event == events.emptyBatteryDetected and not IsDuplicate(protocols.replaceBattery, utils.VectorToString(param1)) then
			local data = {
				itemsNeeded = {
					{ count = 1, item = { name = items.tools.pickaxe, damage = 0 }, allowCraft = true }
				},
				batteryToReplace = param1
			}
			table.insert(tasks, { protocol = protocols.replaceBattery, id = utils.VectorToString(param1), data = data })
			UpdateTasks()
		end

		if event == events.batteryChargingSpaceDetected and not IsDuplicate(protocols.batteryChargingSpaceDetected, utils.VectorToString(param1)) then
			local data = {
				itemsNeeded = {
					{ count = 1, item = items.thermalExpansion.energyCell, allowCraft = true }
				},
				position = param1
			}
			table.insert(tasks, { protocol = protocols.chargeBattery, id = utils.VectorToString(param1), data = data })
			UpdateTasks()
		end
	end
end
