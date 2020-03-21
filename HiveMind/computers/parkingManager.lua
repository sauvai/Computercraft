os.loadAPI("api/utils/files.lua")
os.loadAPI(files.brain)
os.loadAPI(files.protocols)
os.loadAPI(files.getParkingPosition)
os.loadAPI(files.register)
os.loadAPI(files.pingServer)

local function Main()
	rednet.open("top")
	register.Listener()

	brain.AddListener(protocols.getParkingPosition, getParkingPosition.Listener)
	brain.AddListener(protocols.notRegistered, register.Listener)

	brain.CreateManager(pingServer.Manager)
	brain.Start()
end

Main()
