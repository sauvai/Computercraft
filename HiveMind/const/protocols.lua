-- Sent by turtle
taskFinished = "Task Finished"
ping = "Ping"	-- { position }

-- Sent by computer
emptyBatteryDetected = "Empty Battery Detected"
batteryChargingSpaceDetected = "Battery Charging Space Detected"

-- Sent by both
init = "Init"	-- { label, type }
register = "Register"	-- { label, type, position }

-- Sent by server
chargeBattery = "Charge Battery"	-- { itemsNeeded, interface, position }
free = "Free"	-- { chargerPosition, interface }
getBatteryPosition = "Get Battery Position" -- { answerProtocol }
getChargerPosition = "Get Charger Position"	-- { answerProtocol }
getInterfacePosition = "Get Interface Position"	-- { answerProtocol }
notRegistered = "Not Registered"
replaceBattery = "Replace Battery"	-- { interface, itemsNeeded, batteryToPickup, batteryToReplace }
update = "Update"	-- { files = { file1 = content, file2 = content, ... } }
