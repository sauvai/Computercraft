os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.events)
os.loadAPI(files.protocols)

function Listener(id, data)
	-- Check if entity is registered
	local entity = entities.Get(nil, id, nil)
	if entity == nil then
		rednet.send(id, nil, protocols.notRegistered)
		return
	end

	os.queueEvent(events.emptyBatteryDetected, data.position)
end
