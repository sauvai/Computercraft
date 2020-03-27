os.loadAPI("const/files.lua")
os.loadAPI(files.interface)
os.loadAPI(files.inventory)
os.loadAPI(files.items)
os.loadAPI(files.googleMaps)
os.loadAPI(files.utils)

function Listener(id, data)
	-- Go to interface
	googleMaps.MoveTo(data.interface.position)
	googleMaps.FaceDirection(data.interface.facing)
	-- Get items needed
	local p, side = utils.FindPeripheral(items.ae2.interface)
	side = googleMaps.SideToDirection(side)
	local Interface = interface.New(p, side)
	for _, item in pairs(data.itemsNeeded) do
		local total = 0
		local count = 1
		while  count > 0 and total < item.count do
			count = Interface:GetItem(item.item, count, item.allowCraft)
			if not count then error("Can't get item "..textutils.serialize(item.item)) end
			total = total + count
		end
	end
	-- Go to battery to position
	local arrival = data.position - vector.new(0, 1, 0)
	while googleMaps.Locate():tostring() ~= arrival:tostring() do
		googleMaps.MoveTo(arrival)
		sleep(5)
	end
	-- Place new battery
	turtle.select(inventory.Find(items.thermalExpansion.energyCell))
	turtle.placeUp()
	-- Sleep to prevent race condition between task finished and battery monitor (dunno if necessary, but well)
	sleep(1)
	-- Say to server that the task is done
	rednet.send(config.serverId, nil, protocols.taskFinished)
end
