os.loadAPI("const/files.lua")
os.loadAPI(files.entities)
os.loadAPI(files.filesNeeded)
os.loadAPI(files.labels)
os.loadAPI(files.multitasks)
os.loadAPI(files.protocols)
os.loadAPI(files.utils)

local chat
local listeners = {}

-------------- PRIVATE -------------

local function Say(message)
	chat.say(message, -1, true, os.computerLabel())
end

local function Tell(message, player)
	chat.tell(player, message, -1, true, os.computerLabel())
end

local function AddListener(command, callback)
	listeners[command] = callback
end

-------------- UPDATE --------------

local function DownloadRepository()
	for _, file in ipairs(fs.list("/")) do
		if file ~= "git" and file ~= "startup" and not fs.isReadOnly(file) then
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

function SendUpdateMessage(entity, filesList)
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

	for file, _ in pairs(filesNeeded.commonFiles) do
		local h = fs.open(file, "r")
		if h == nil then error("Can't open file "..file) end
		filesList[file] = h.readAll()
		h.close()
	end

	rednet.send(entity.id, { files = filesList }, protocols.update)
end

local function Update()
	Say("Downloading repository")
	DownloadRepository()

	for _, entity in pairs(entities.Get()) do
		Say("Updating "..entity.label)
		if entity.type == "turtle" then
			SendUpdateMessage(entity, filesNeeded.turtlesFiles)
		else
			SendUpdateMessage(entity, filesNeeded.computersFiles[entity.label])
		end
	end

	os.reboot()
end

-------------- PUBLIC --------------

function Manager()
	chat = utils.FindPeripheral("chatBox")
	
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
