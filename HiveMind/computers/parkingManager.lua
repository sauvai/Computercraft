os.loadAPI("const/files.lua")
os.loadAPI(files.brain)
os.loadAPI(files.protocols)
os.loadAPI(files.getChargerPosition)
os.loadAPI(files.getInterfacePosition)
os.loadAPI(files.getMeBridgePosition)
os.loadAPI(files.register)
os.loadAPI(files.pingServer)
os.loadAPI(files.update)

local function Main()
	rednet.open("top")
	register.Listener()
	
	brain.AddListener(protocols.notRegistered, os.reboot)
	brain.AddListener(protocols.update, update.Listener)

	brain.AddListener(protocols.getChargerPosition, getChargerPosition.Listener)
	brain.AddListener(protocols.getInterfacePosition, getInterfacePosition.Listener)
	brain.AddListener(protocols.getMeBridgePosition, getMeBridgePosition.Listener)

	brain.CreateManager(pingServer.Manager)
	brain.Start()
end

Main()
