os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.discord)
os.loadAPI(files.entities)
os.loadAPI(files.utils)

function Manager()
	while true do
		for key, entity in pairs(entities.Get()) do
			if entity.hasPinged ~= true then
				discord.Send(entity.label, "have gone missing, last known position was", utils.VectorToString(entity.position))
				entities.Remove(entity)
			end
			entity.hasPinged = false
		end
		sleep(config.checkMissingEntitiesIntervalS)
	end
end
