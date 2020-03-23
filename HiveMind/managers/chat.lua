os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.labels)
os.loadAPI(files.multitasks)
os.loadAPI(files.protocols)

local chat
local listeners = {}

-------------- UPDATE --------------

local turtlesFiles = {
	-- Startup
	["startup"] = "shell.run(\""..files.turtle.."\")",
	-- Computers
	[files.turtle] = "",
	-- Const
	[files.config] = "",
	[files.files] = "",
	[files.items] = "",
	[files.protocols] = "",
	-- Core
	[files.brain] = "",
	[files.multitasks] = "",
	-- Listeners
	[files.register] = "",
	[files.update] = "",
	[files.free] = "",
	-- Managers
	[files.pingServer] = "",
	-- Misc
	[files.googleMaps] = "",
	[files.inventory] = "",
	[files.scanner] = "",
}

local computersFiles = {
	[labels.parkingManager] = {
		-- Startup
		["startup"] = "shell.run(\""..files.parkingManager.."\")",
		-- Computers
		[files.parkingManager] = "",
		-- Const
		[files.config] = "",
		[files.items] = "",
		[files.files] = "",
		[files.protocols] = "",
		-- Core
		[files.brain] = "",
		[files.multitasks] = "",
		-- Listeners
		[files.register] = "",
		[files.update] = "",
		[files.getParkingPosition] = "",
		-- Managers
		[files.pingServer] = "",
		-- Misc
		[files.googleMaps] = "",
		[files.inventory] = "",
		[files.scanner] = "",
	}
}

local function DownloadRepository()
	for _, file in ipairs(fs.list("/")) do
		if file ~= "git" and not fs.isReadOnly(file) then
			fs.delete(file)
		end
	end
	
	Git = assert(loadfile("git/git.lua")())
	Git:showOutput(false)
	Git:setProvider("github")
	Git:setRepository("sauvai", "Computercraft", "master")

	Git:cloneTo("temp")
	
	for _, file in ipairs(fs.list("temp/HiveMind/")) do
		fs.move("temp/HiveMind/" .. file, file)
	end
	fs.delete("temp")
end

local function SendUpdateMessage(entity, filesList)
	if filesList == nil then
		error("Empty file list given for " ..entity.label .. " (id #" .. entity.id .. ")", 2)
	end

	for file, content in pairs(filesList) do
		if content == "" then
			local h = fs.open(file, "r")
			filesList[file] = h.readAll()
			h.close()
		end
	end

	rednet.send(entity.id, { files = filesList }, protocols.update)
end

local function Update()
	DownloadRepository()

	for _, entity in pairs(entities.Get()) do
		if entity.type == "turtle" then
			SendUpdateMessage(entity, turtlesFiles)
		else
			SendUpdateMessage(entity, computersFiles[entity.label])
		end
	end

	os.reboot()
end

-------------- PRIVATE -------------

local function Say(message)
	chat.say(message, -1, true, os.computerLabel())
end

local function Tell(message, player)
	chat.tell(player, message, -1, true, os.computerLabel())
end

local function FindChatBox()
	for _, side in pairs(peripheral.getNames()) do
		if peripheral.getType(side) == "chatBox" then
			return peripheral.wrap(side)
		end
	end
	error("ChatBox not found", 2)
end

local function AddListener(command, callback)
	listeners[command] = callback
end

-------------- PUBLIC --------------

function Manager()
	chat = FindChatBox()
	
	AddListener("update", Update)

	while true do
		local _, player, args = os.pullEvent("command")

		local found = false
		for command, callback in pairs(listeners) do
			if args[1] == command then
				multitasks.CreateTask(callback, table.unpack(args))
				found = true
			end
		end

		if not found then Tell("Unknown command", player) end
	end
end
