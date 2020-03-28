os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.protocols)
os.loadAPI(files.googleMaps)
os.loadAPI(files.utils)

function Listener(id, data)
	local entity = entities.Get(nil, id, nil)
	if entity == nil then
		rednet.send(id, nil, protocols.notRegistered)
		return
	end

	entity.hasPinged = true
	entity.position = data.position
end
