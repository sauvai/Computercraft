os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.events)

function Listener(id, data)
	local entity = entities.Get(nil, id, nil)
	if entity == nil then
		print("Registered", data.type, data.label)
		entities.Add(data.type, id, data.label)
		
		if data.type == "computer" then
			os.queueEvent(events.computerRegistered, id)
		else
			os.queueEvent(events.turtleRegistered, id)
		end

	end
end
