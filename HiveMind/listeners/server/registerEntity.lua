os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.events)

function Listener(id, data)
	entities.Remove(entities.Get(nil, id))

	entities.Add(data.type, id, data.label)
	
	if data.type == "computer" then
		os.queueEvent(events.computerRegistered, id)
	else
		os.queueEvent(events.turtleRegistered, id)
	end

	print("Registered", data.type, data.label)
end
