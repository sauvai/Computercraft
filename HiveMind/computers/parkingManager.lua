os.loadAPI("const/files.lua")
os.loadAPI(files.brain)
os.loadAPI(files.protocols)
os.loadAPI(files.getParkingPosition)
os.loadAPI(files.register)
os.loadAPI(files.pingServer)
os.loadAPI(files.update)

local function Main()
	rednet.open("top")
	register.Listener()

	brain.AddListener(protocols.getParkingPosition, getParkingPosition.Listener)
	brain.AddListener(protocols.notRegistered, register.Listener)
	brain.AddListener(protocols.update, update.Listener)

	brain.CreateManager(pingServer.Manager)
	brain.Start()
end

Main()
