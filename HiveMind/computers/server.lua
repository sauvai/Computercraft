os.loadAPI("const/files.lua")
os.loadAPI(files.brain)
os.loadAPI(files.checkMissingEntities)
os.loadAPI(files.protocols)
os.loadAPI(files.registerEntity)
os.loadAPI(files.registerPing)
os.loadAPI(files.tasks)

local function Main()
	rednet.open("top")
	rednet.host("Hive Mind", "server")

	brain.AddListener(protocols.register, registerEntity.Listener)
	brain.AddListener(protocols.ping, registerPing.Listener)

	brain.CreateManager(checkMissingEntities.Manager)
	brain.CreateManager(tasks.Manager)
	brain.Start()
end

Main()
