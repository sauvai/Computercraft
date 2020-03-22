os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.utils)

function Manager()
	while true do
		sleep(10)
		for key, entity in pairs(entities.Get()) do
			if entity.hasPinged ~= true then
				print(entity.label, "have gone missing, last known position was", utils.VectorToString(entity.position))
				entities.Remove(entity)
			end
			entity.hasPinged = false
		end
	end
end
