os.loadAPI("const/files.lua")
os.loadAPI(files.entities)

function Manager()
	while true do
		local h = fs.open("data/entitiesLog", "w")
		print("test1")
		h.write(textutils.serialize(entities.Get()))
		print("test2")
		h.close()
		sleep(30)
	end
end
