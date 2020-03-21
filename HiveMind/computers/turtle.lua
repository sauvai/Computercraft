os.loadAPI("api/utils/files.lua")
os.loadAPI(files.brain)
os.loadAPI(files.free)
os.loadAPI(files.pingServer)
os.loadAPI(files.protocols)
os.loadAPI(files.register)

local function Main()
	rednet.open("right")
	register.Listener()

	brain.AddListener(protocols.free, free.Listener)
	brain.AddListener(protocols.notRegistered, register.Listener)

	brain.CreateManager(pingServer.Manager)
	brain.Start()
end

Main()
