os.loadAPI("const/files.lua")
os.loadAPI(files.googleMaps)

function Listener(id, data)
	-- dump inventory
	googleMaps.MoveTo(vector.new(data.chargerPosition.x, data.chargerPosition.y, data.chargerPosition.z))
end
