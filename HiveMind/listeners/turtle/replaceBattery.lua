os.loadAPI("const/files.lua")
os.loadAPI(files.interface)
os.loadAPI(files.inventory)
os.loadAPI(files.googleMaps)
os.loadAPI(files.utils)

function Listener(id, data)
	-- Go to ME Bridge position
	googleMaps.MoveTo(data.meBridgePosition)
	-- Get items needed
	local p, side = utils.FindPeripheral("meBridge")
	side = googleMaps.SideToDirection(side)
	local MeBridge = meBridge.New(p, side)
	for _, item in pairs(data.itemsNeeded) do
		local total = 0
		local attempt = 0
		while total < item.count do
			if MeBridge:ItemCount(item.name) > 0 then
				total = total + MeBridge:GetItem(item.name, item.count - total)
			else
				if attempt == 0 then
					if not MeBridge:CraftItem(item.name, item.count - total) then
						os.reboot()
						error("Can't craft "..tostring(item.count).." "..item.name)
					end
					attempt = 60
				else
					attempt = attempt - 1
				end
			end

			if total < item.count then
				sleep(1)
			end
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
