os.loadAPI("const/files.lua")
os.loadAPI(files.interface)
os.loadAPI(files.inventory)
os.loadAPI(files.googleMaps)
os.loadAPI(files.utils)

function Listener(id, data)
	-- Go to interface
	googleMaps.MoveTo(data.interfacePosition)
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
	-- Go to battery to pickup
	googleMaps.MoveTo(data.batteryToPickup)
	-- Pickup battery
	inventory.EquipPickaxe()
	local newBatterySlot = inventory.FindEmptySlot()
	turtle.select(newBatterySlot)
	local direction = googleMaps.VectorToDirection(data.batteryToPickup - googleMaps.Locate())
	if direction == "up" then turtle.digUp()
	elseif direction == "down" then turtle.digDown()
	else turtle.dig() end
	-- Go to battery to replaces
	googleMaps.MoveTo(data.batteryToReplace)
	-- Pickup battery
	inventory.EquipPickaxe()
	direction = googleMaps.VectorToDirection(data.batteryToReplace - googleMaps.Locate())
	if direction == "up" then turtle.digUp()
	elseif direction == "down" then turtle.digDown()
	else turtle.dig() end
	-- Place new battery
	turtle.select(newBatterySlot)
	if direction == "up" then turtle.placeUp()
	elseif direction == "down" then turtle.placeDown()
	else turtle.place() end
	-- Sleep to prevent race condition between task finished and battery monitor saying the battery is still empty (dunno if necessary, but well)
	sleep(1)
	-- Say to server that the task is done
	rednet.send(config.serverId, nil, protocols.taskFinished)
end
