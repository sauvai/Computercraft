os.loadAPI("const/files.lua")
os.loadAPI(files.googleMaps)
os.loadAPI(files.interface)
os.loadAPI(files.items)
os.loadAPI(files.utils)

function Listener(id, data)
	-- Go to interface
	googleMaps.MoveTo(vector.new(data.interface.position.x, data.interface.position.y, data.interface.position.z))
	googleMaps.FaceDirection(data.interface.facing)
	-- Dump inventory
	local p, side = utils.FindPeripheral(items.ae2.interface)
	side = googleMaps.SideToDirection(side)
	local Interface = interface.New(p, side)
	Interface:DumpInventory()
	-- Go to charger
	googleMaps.MoveTo(vector.new(data.chargerPosition.x, data.chargerPosition.y, data.chargerPosition.z))
	-- Say to server that the task is done
	rednet.send(config.serverId, nil, protocols.taskFinished)
end
