os.loadAPI("const/files.lua")
os.loadAPI(files.batteryChargingSpaceDetected)
os.loadAPI(files.brain)
os.loadAPI(files.chat)
os.loadAPI(files.checkMissingEntities)
os.loadAPI(files.emptyBatteryDetected)
os.loadAPI(files.initEntity)
os.loadAPI(files.logEntities)
os.loadAPI(files.protocols)
os.loadAPI(files.registerEntity)
os.loadAPI(files.registerPing)
os.loadAPI(files.taskFinished)
os.loadAPI(files.tasks)

local function Main()
	math.randomseed(os.time())
	
	local h = fs.open("startup", "w")
	h.write("shell.run(\"computers/server.lua\")")
	h.close()

	rednet.open("top")
	rednet.host("Hive Mind", "server")

	brain.AddListener(protocols.register, registerEntity.Listener)
	brain.AddListener(protocols.ping, registerPing.Listener)
	brain.AddListener(protocols.taskFinished, taskFinished.Listener)
	brain.AddListener(protocols.emptyBatteryDetected, emptyBatteryDetected.Listener)
	brain.AddListener(protocols.batteryChargingSpaceDetected, batteryChargingSpaceDetected.Listener)
	brain.AddListener(protocols.init, initEntity.Listener)

	brain.CreateManager(checkMissingEntities.Manager)
	brain.CreateManager(tasks.Manager)
	brain.CreateManager(chat.Manager)
	brain.CreateManager(logEntities.Manager)

	brain.Start()
end

Main()
