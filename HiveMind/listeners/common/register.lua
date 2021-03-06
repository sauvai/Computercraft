os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.protocols)

function Listener()
	config.serverId = rednet.lookup("Hive Mind", "server")
	while not config.serverId do
		config.serverId = rednet.lookup("Hive Mind", "server")
		sleep(config.serverLookupIntervalS)
	end

	print("Found server, registering...")
	googleMaps.Locate()
	local data = { label = os.computerLabel(), position = ownPosition }
	if turtle then
		data.type = "turtle"
	else
		data.type = "computer"
	end
	rednet.send(config.serverId, data, protocols.register)
end