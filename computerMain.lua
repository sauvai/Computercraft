os.loadAPI("api/data/protocols.lua")
os.loadAPI("api/data/labels.lua")
os.loadAPI("api/multitasks.lua")

local serverId = nil

-- EVENTS HANDLERS

local function GetParkingPosition(answerProtocol)
	-- TODO get parking position
	local answerData = { position = vector.new(7, 7, 7) }
	rednet.send(serverId, answerData, answerProtocol)s
end

---------- REDNET MANAGER ----------

local function HandleMessage(id, data, protocol)
	if protocols.ShouldIgnore(protocol) then return end

	if	protocol == protocols.getParkingPosition then	multitasks.CreateTask(GetParkingPosition, data.answerProtocol)

	else print("Unknown protocol: " .. protocol) end
end

local function RednetManager()
	while true do
		local _, id, message, protocol = os.pullEvent("rednet_message")
		HandleMessage(id, message, protocol)
	end
end

------------------------------------

local function Main()
	local label = os.computerLabel()
	if not label then
		error("No label set")
	end

	rednet.open("top")
	while not serverId do
		serverId = rednet.lookup("Hive Mind", "server")
		sleep(1)
	end

	print("Found server, registering...")
	rednet.send(serverId, { label = label }, protocols.computerRegister)

	multitasks.CreateTask(RednetManager)
	multitasks.Run()
end

Main()
