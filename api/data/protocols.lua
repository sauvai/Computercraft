-- Sent by turtle
turtleRegister = "TurtleRegister"	-- { label }
workFinished = "WorkFinished"
pong = "Pong"

-- Sent by computer
computerRegister = "ComputerRegister"	-- { label }

-- Sent by server
ping = "Ping"
free = "Free"	-- { chargerPosition }
getParkingPosition = "GetParkingPosition"	-- { answerProtocol }

function ShouldIgnore(protocol)
	local ignoredList = {
		"dns"
	}

	for i = 1, #ignoredList do
		if protocol == ignoredList[i] then return true end
	end
	return protocol == nil
end
