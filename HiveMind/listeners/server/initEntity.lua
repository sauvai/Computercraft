os.loadAPI("const/files.lua")
os.loadAPI(files.chat)
os.loadAPI(files.entities)
os.loadAPI(files.events)
os.loadAPI(files.filesNeeded)

function Listener(id, data)
	local entity = { id = id, label = data.label }
	if data.type == "turtle" then
		chat.SendUpdateMessage(entity, filesNeeded.turtlesFiles)
	else
		chat.SendUpdateMessage(entity, filesNeeded.computersFiles[entity.label])
	end
end
