-- Sent by turtle
turtleRegister = "TurtleRegister"	-- { label }
workFinished = "WorkFinished"
ping = "Ping"	-- { position }

-- Sent by computer
computerRegister = "ComputerRegister"	-- { label }

-- Sent by server
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
