os.loadAPI("api/data/protocols.lua")
os.loadAPI("api/googleMaps.lua")
os.loadAPI("api/multitasks.lua")

local serverId = nil
local pingIntervalS = 5

-------------- TASKS ---------------

local function Free(id, data)
	-- dump inventory
	print(textutils.serialize(data.chargerPosition))
end

----------- PING MANAGER -----------

local function PingManager()
	while true do
		sleep(pingIntervalS)
		rednet.send(serverId, { position = googleMaps.Locate() }, protocols.ping)
	end
end

---------- REDNET MANAGER ----------

local function HandleMessage(id, data, protocol)
	if protocols.ShouldIgnore(protocol) then return end

	if	protocol == protocols.free	then multitasks.CreateTask(Free, id, data)

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

	rednet.open("right")
	while not serverId do
		serverId = rednet.lookup("Hive Mind", "server")
		sleep(1)
	end

	print("Found server, registering...")
	rednet.send(serverId, { label = label }, protocols.turtleRegister)

	multitasks.CreateTask(PingManager)
	multitasks.CreateTask(RednetManager)
	multitasks.Run()
end

Main()
