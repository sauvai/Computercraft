os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.entities)

function Manager()
	while true do
		local h = fs.open("data/entitiesLog", "w")
		h.write(textutils.serialize(entities.Get()))
		h.close()
		sleep(config.logEntitiesIntervalS)
	end
end
