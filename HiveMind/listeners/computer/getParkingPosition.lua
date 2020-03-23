os.loadAPI("const/files.lua")
os.loadAPI(files.config)
os.loadAPI(files.googleMaps)
os.loadAPI(files.items)
os.loadAPI(files.scanner)
os.loadAPI(files.utils)

function Listener(id, data)
	local s = scanner.New(utils.FindManipulator("plethora:scanner"))
	s:Scan()

	local minDistance = s:GetRadius() * -1
	local maxDistance = s:GetRadius()

	local computerPosition
	local chargers = {}

	for x = minDistance, maxDistance do
		for y = minDistance, maxDistance do
			for z = minDistance, maxDistance do
				if s:GetBlock(x, y, z).name == items.peripheralsPlusOne.rfCharger then
					table.insert(chargers, vector.new(x, y, z))
				end
				if s:GetBlock(x, y, z).name == items.computerCraft.computer and s:GetBlockMeta(x, y, z).computer.id == os.computerID() then
					computerPosition = vector.new(x, y, z)
				end
			end
		end
	end

	local position
	for _, charger in pairs(chargers) do
		if s:IsEmptyBlock(charger.x + 1, charger.y, charger.z) then position = vector.new(charger.x + 1, charger.y, charger.z) break end
		if s:IsEmptyBlock(charger.x - 1, charger.y, charger.z) then position = vector.new(charger.x - 1, charger.y, charger.z) break end
		if s:IsEmptyBlock(charger.x, charger.y + 1, charger.z) then position = vector.new(charger.x, charger.y + 1, charger.z) break end
		if s:IsEmptyBlock(charger.x, charger.y - 1, charger.z) then position = vector.new(charger.x, charger.y - 1, charger.z) break end
		if s:IsEmptyBlock(charger.x, charger.y, charger.z + 1) then position = vector.new(charger.x, charger.y, charger.z + 1) break end
		if s:IsEmptyBlock(charger.x, charger.y, charger.z - 1) then position = vector.new(charger.x, charger.y, charger.z - 1) break end
	end

	if position ~= nil then
		position = googleMaps.Locate() + position - computerPosition
	end

	rednet.send(config.serverId, { position = position }, data.answerProtocol)
end
