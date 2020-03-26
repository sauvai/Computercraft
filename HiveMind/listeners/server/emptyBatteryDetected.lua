os.loadAPI("const/files.lua")
os.loadAPI(files.events)

function Listener(id, data)
	os.queueEvent(events.emptyBatteryDetected, data.position)
end
