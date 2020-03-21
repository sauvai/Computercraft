os.loadAPI("api/utils/protocols.lua")
os.loadAPI("api/utils/labels.lua")
os.loadAPI("api/utils/events.lua")
os.loadAPI("api/multitasks.lua")

local function RegisterPing(id, data)
	local entity = GetById(id, computers)
	if entity == nil then
		entity = GetById(id, turtles)
	end
	if entity == nil then
		AskToRegister(id)
		print("Pinging entity is not registered, position:", VectorToString(data.position))
		return
	end

	entity.hasPinged = true
	entity.position = data.position
end

---------- REDNET MANAGER ----------

local function ShouldIgnore(protocol)
	for i = 1, #config.ignoredProtocols do
		if protocol == config.ignoredProtocols[i] then return true end
	end
	return protocol == nil
end

local function HandleMessage(id, data, protocol)
	if ShouldIgnore(protocol) then return end

	if		protocol == protocols.turtleRegister	then multitasks.CreateTask(RegisterTurtle, id, data)
	elseif	protocol == protocols.computerRegister	then multitasks.CreateTask(RegisterComputer, id, data)
	elseif	protocol == protocols.ping				then multitasks.CreateTask(RegisterPing, id, data)

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
	multitasks.CreateTask(PingManager)
	multitasks.Run()
end

Main()
