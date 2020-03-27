-- Sent by turtle
taskFinished = "Task Finished"
ping = "Ping"	-- { position }

-- Sent by computer
emptyBatteryDetected = "Empty Battery Detected"
batteryChargingSpaceDetected = "Battery Charging Space Detected"

-- Sent by both
init = "Init"	-- { label, type }
register = "Register"	-- { label, type }

-- Sent by server
chargeBattery = "Charge Battery"	-- { itemsNeeded, interface, position }
free = "Free"	-- { chargerPosition }
getBatteryPosition = "Get Battery Position" -- { answerProtocol }
getParkingPosition = "Get Parking Position"	-- { answerProtocol }
notRegistered = "Not Registered"
replaceBattery = "Replace Battery"	-- { interface, itemsNeeded, batteryToPickup, batteryToReplace }
update = "Update"	-- { files = { file1 = content, file2 = content, ... } }
