os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.multitasks)
os.loadAPI(files.protocols)

---------- REDNET MANAGER ----------

local listeners = {}

local function ShouldIgnore(protocol)
	for i = 1, #config.ignoredProtocols do
		if protocol == config.ignoredProtocols[i] then return true end
	end
	return protocol == nil
end

local function HandleMessage(id, data, protocolReceived)
	if ShouldIgnore(protocolReceived) then return end

	local found = false
	for protocol, callback in pairs(listeners) do
		if protocol == protocolReceived	then
			multitasks.CreateTask(callback, id, data)
			found = true
		end
	end

	if not found then
		print("Unknown protocol", protocolReceived)
	end
end

local function RednetManager()
	while true do
		local event, id, message, protocol = os.pullEvent("rednet_message")
		HandleMessage(id, message, protocol)
	end
end

-------------- PUBLIC --------------

function AddListener(protocol, callback)
	listeners[protocol] = callback
end

function CreateManager(manager)
	multitasks.CreateTask(manager)
end

function Start()
	multitasks.CreateTask(RednetManager)
	multitasks.Run()
end