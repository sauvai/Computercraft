os.loadAPI("const/files.lua")
os.loadAPI(files.events)
os.loadAPI(files.entities)
os.loadAPI(files.labels)
os.loadAPI(files.multitasks)

--      Task structure
-- {
--		
-- 		data = {  }
-- 		protocol = "Free"
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

local function GetParkingPosition() -- TODO get all parking manager to get the closest parking
	local parkingManager = entities.Get("computer", nil, labels.parkingManager)[1]
	local answerProtocol = tostring(os.clock())

	if parkingManager == nil then
		parkingManager = WaitForComputerToConnect(labels.parkingManager)
	end

	rednet.send(parkingManager.id, { answerProtocol = answerProtocol }, protocols.getParkingPosition)
	local _, data = rednet.receive(answerProtocol)

	return data
end

local function FreeTurtle(id) -- TODO if no parking position found wait for a new parking Manager to connect
	rednet.send(id, GetParkingPosition(), protocols.free)
	local turtle = entities.Get("turtle", id)
	turtle.task = nil

	print("Freed turtle " .. turtle.label)
end

local function AssignTask(id, task)
	rednet.send(id, task.data, task.protocol)
	local turtle = entities.Get("turtle", id)
	turtle.task = task

	print("Assigned task " .. task.protocol .. " to turtle " .. turtle.label)
end

-- local function UpdateTasks()
-- 	for _, turtle in pairs(turtles) do
-- 		if #tasks == 0 then break end

-- 		if turtle.task == nil then
-- 			AssignTask(id, table.remove(tasks, 1))
-- 		end
-- 	end
-- end

function Manager()
	while true do
		local event, id = os.pullEvent(events.turtleRegistered)

		if event == events.turtleRegistered then
			if #tasks == 0 then
				multitasks.CreateTask(FreeTurtle, id)
			else
				multitasks.CreateTask(AssignTask, id, table.remove(tasks, 1))
			end
		end
	end
end
