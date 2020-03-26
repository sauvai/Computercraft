os.loadAPI("const/files.lua")
os.loadAPI(files.brain)
os.loadAPI(files.getBatteryPosition)
os.loadAPI(files.monitorBattery)
os.loadAPI(files.pingServer)
os.loadAPI(files.protocols)
os.loadAPI(files.register)
os.loadAPI(files.update)

local function Main()
	rednet.open("top")
	register.Listener()

	brain.AddListener(protocols.notRegistered, register.Listener)
	brain.AddListener(protocols.update, update.Listener)

	brain.AddListener(protocols.getBatteryPosition, getBatteryPosition.Listener)

	brain.CreateManager(pingServer.Manager)
	brain.Start()
end

Main()
