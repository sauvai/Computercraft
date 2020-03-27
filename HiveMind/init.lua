if os.computerLabel() == nil then
	error("You must set a label on this computer first")
end

if turtle then
	rednet.open("right")
else
	rednet.open("top")
end

local serverId
while not serverId do
	serverId = rednet.lookup("Hive Mind", "server")
	sleep(1)
end

local data = { label = os.computerLabel() }
if turtle then
	data.type = "turtle"
else
	data.type = "computer"
end

rednet.send(serverId, data, "Init")
while true do
	local event, id, data, protocol = os.pullEvent("rednet_message")
	if protocol == "Update" then
		for _, file in ipairs(fs.list("/")) do
			if not fs.isReadOnly(file) then
				fs.delete(file)
			end
		end
	
		for file, content in pairs(data.files) do
			local h = fs.open(file, "w")
			if h == nil then error("Can't open file "..file) end
			h.write(content)
			h.close()
		end
	
		os.reboot()	
	end
end
