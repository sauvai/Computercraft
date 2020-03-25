os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.protocols)
os.loadAPI(files.googleMaps)
os.loadAPI(files.utils)

function Listener(id, data)
	local entity = entities.Get(nil, id, nil)
	if entity == nil then
		rednet.send(id, nil, protocols.notRegistered)
		print("Pinging entity is not registered, position:", utils.VectorToString(data.position))
		return
	end

	entity.hasPinged = true
	entity.position = data.position
end
