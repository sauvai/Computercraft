os.loadAPI("api/data/protocols.lua")
os.loadAPI("api/data/labels.lua")
os.loadAPI("api/data/events.lua")
os.loadAPI("api/multitasks.lua")

--      Turtle structure
-- {
-- 		id = 0,
-- 		label = "Natacha",
-- 		task = nil
-- }
--------------------------------------
--      Task structure
-- {
--		
-- 		data = {  }
-- 		protocol = "Free"
-- }
--------------------------------------

local turtles = {}
local computers = {}
local tasks = {}

local function GetById(id, list)
	for i = 1, #list do
		if list[i].id == id then return list[i] end
	end
	return nil
end

local function GetByLabel(label, list)
	for i = 1, #list do
		if list[i].label == label then return list[i] end
	end
	return nil
end

local function WaitForComputerToConnect(label)
	print("Waiting for", label, "to connect...")
	
	local computer = GetByLabel(label, computers)

	while computer == nil do
		os.pullEvent(events.computerRegistered)
		computer = GetByLabel(label, computers)
	end

	return computer
end

local function GetParkingPosition()
	local parkingManager = GetByLabel(labels.parkingManager, computers)
	local answerProtocol = tostring(os.clock())

	if parkingManager == nil then
		parkingManager = WaitForComputerToConnect(labels.parkingManager)
	end

	rednet.send(parkingManager.id, { answerProtocol = answerProtocol }, protocols.getParkingPosition)
	local _, data = rednet.receive(answerProtocol)

	return data.position
end

local function FreeTurtle(id)
	rednet.send(id, { chargerPosition = GetParkingPosition() }, protocols.free)
	local turtle = GetById(id, turtles)
	turtle.task = nil

	print("Freed turtle " .. turtle.label)
end

local function AssignTask(id, task)
	rednet.send(id, task.data, task.protocol)
	local turtle = GetTurtleById(id)
	turtle.task = task

	print("Assigned task " .. task.protocol .. " to turtle " .. turtle.label)
end

local function UpdateTasks()
	for _, turtle in pairs(turtles) do
		if #tasks == 0 then break end

		if turtle.task == nil then
			AssignTask(id, table.remove(tasks, 1))
		end
	end
end

local function RegisterTurtle(id, data)
	if GetById(id, turtles) == nil then
		table.insert(turtles, { id = id, label = data.label })
		print("Registered turtle " .. data.label)
		if #tasks == 0 then
			FreeTurtle(id)
		else
			AssignTask(id, table.remove(tasks, 1))
		end
	end
end

local function RegisterComputer(id, data)

	if GetById(id, computers) == nil then
		table.insert(computers, { id = id, label = data.label })
	end

	os.queueEvent(events.computerRegistered, id)

	print("Registered computer " .. data.label)
end

----------- PING MANAGER -----------

-- local function PingManager()
-- 	while true do

-- 	end
-- end

---------- REDNET MANAGER ----------

local function HandleMessage(id, data, protocol)
	if protocols.ShouldIgnore(protocol) then return end

	if		protocol == protocols.turtleRegister	then multitasks.CreateTask(RegisterTurtle, id, data)
	elseif	protocol == protocols.computerRegister	then multitasks.CreateTask(RegisterComputer, id, data)

	else print("Unknown protocol: ", protocol) end
end

local function RednetManager()
	while true do
		local event, id, message, protocol = os.pullEvent("rednet_message")
		HandleMessage(id, message, protocol)
	end
end

------------------------------------

local function Main()
	print("Initializing")
	rednet.open("top")
	rednet.host("Hive Mind", "server")

	multitasks.CreateTask(RednetManager)
	multitasks.Run()
end

Main()
