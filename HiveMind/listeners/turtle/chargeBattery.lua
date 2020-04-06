os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.discord)
os.loadAPI(files.inventory)
os.loadAPI(files.items)
os.loadAPI(files.googleMaps)
os.loadAPI(files.meBridge)
os.loadAPI(files.utils)

function Listener(id, data)
	print(textutils.serialize(data))
	-- Go to ME bridge
	googleMaps.MoveTo(data.meBridgePosition)
	-- Get items needed
	local p, side = utils.FindPeripheral("meBridge")
	side = googleMaps.SideToDirection(side)
	local MeBridge = meBridge.New(p, side)
	for _, item in pairs(data.itemsNeeded) do
		local total = 0
		local attempt = 0
		local hasWarned = false

		while total < item.count do
			if MeBridge:ItemCount(item.name) > 0 then
				total = total + MeBridge:GetItem(item.name, item.count - total)
			else
				if attempt == 0 then
					if not MeBridge:CraftItem(item.name, item.count - total) then
						if not hasWarned then
							discord.Send("Can't craft", item.count, item.name)
							hasWarned = true
						end
						sleep(config.itemCraftWaitTimeS)
					end
					attempt = config.itemCraftWaitTimeS
				else
					attempt = attempt - 1
				end
			end

			if total < item.count then
				sleep(1)
			end
		end
	end
	-- Go to battery position
	local arrival = data.position - vector.new(0, 1, 0)
	while config.ownPosition:tostring() ~= arrival:tostring() do
		googleMaps.MoveTo(arrival)
		sleep(20)
	end
	-- Place new battery
	turtle.select(inventory.Find(items.thermalExpansion.energyCell))
	turtle.placeUp()
	-- Sleep to prevent race condition between task finished and battery monitor (dunno if necessary, but well)
	sleep(1)
	-- Say to server that the task is done
	rednet.send(config.serverId, nil, protocols.taskFinished)
end
