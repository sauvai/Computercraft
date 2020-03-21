os.loadAPI("api/utils/files.lua")
os.loadAPI(files.config)

function Listener(id, data)
	-- TODO get parking position
	local answerData = { position = vector.new(7, 7, 7) }
	rednet.send(config.serverId, answerData, data.answerProtocol)
end
