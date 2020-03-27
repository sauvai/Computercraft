os.loadAPI("const/files.lua")
os.loadAPI(files.labels)

 commonFiles = {
	-- Const
	[files.config] = "",
	[files.items] = "",
	[files.files] = "",
	[files.protocols] = "",
	-- Core
	[files.brain] = "",
	[files.multitasks] = "",
	-- Listeners
	[files.register] = "",
	[files.update] = "",
	-- Managers
	[files.pingServer] = "",
	-- Misc
	[files.googleMaps] = "",
	[files.inventory] = "",
	[files.scanner] = "",
	[files.utils] = "",
}

turtlesFiles = {
	-- Startup
	["startup"] = "shell.run(\""..files.turtle.."\")",
	-- Computers
	[files.turtle] = "",
	-- Listeners
	[files.free] = "",
	[files.chargeBattery] = "",
	[files.replaceBattery] = "",
	-- Misc
	[files.interface] = "",
}

computersFiles = {
	[labels.parkingManager] = {
		-- Startup
		["startup"] = "shell.run(\""..files.parkingManager.."\")",
		-- Computers
		[files.parkingManager] = "",
		-- Listeners
		[files.getChargerPosition] = "",
		[files.getInterfacePosition] = "",
	},
	[labels.batteryMonitor] = {
		-- Startup
		["startup"] = "shell.run(\""..files.batteryMonitor.."\")",
		-- Computers
		[files.batteryMonitor] = "",
		-- Managers
		[files.monitorBattery] = "",
	},
	[labels.batteryFarmer] = {
		-- Startup
		["startup"] = "shell.run(\""..files.batteryFarmer.."\")",
		-- Computers
		[files.batteryFarmer] = "",
		-- Listeners
		[files.getBatteryPosition] = "",
		-- Managers
		[files.checkBatteryChargingSpaces] = "",
		[files.monitorBattery] = "",
	}
}