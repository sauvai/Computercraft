os.loadAPI("const/files.lua")
os.loadAPI(files.brain)
os.loadAPI(files.monitorBattery)
os.loadAPI(files.pingServer)
os.loadAPI(files.protocols)
os.loadAPI(files.register)
os.loadAPI(files.update)

local function Main()
	rednet.open("top")
	register.Listener()

	brain.AddListener(protocols.notRegistered, os.reboot)
	brain.AddListener(protocols.update, update.Listener)

	brain.CreateManager(pingServer.Manager)
	brain.CreateManager(monitorBattery.Manager)
	brain.Start()
end

Main()
