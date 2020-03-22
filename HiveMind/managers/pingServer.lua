os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.protocols)

function Manager()
	while true do
		sleep(config.pingIntervalS)
		rednet.send(config.serverId, { position = googleMaps.Locate() }, protocols.ping)
	end
end
