os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.protocols)

function Listener() -- TODO also send position of the computer, in case it crash on startup before any ping
	while not config.serverId do
		config.serverId = rednet.lookup("Hive Mind", "server")
		sleep(1)
	end

	print("Found server, registering...")
	local data = { label = os.computerLabel() }
	if turtle then
		data.type = "turtle"
	else
		data.type = "computer"
	end
	rednet.send(config.serverId, data, protocols.register)
end