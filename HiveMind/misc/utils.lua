function VectorToString(vector)
	local positionString
	if vector == nil then
		positionString = "nil"
	else
		positionString = tostring(vector.x) .. ", " .. tostring(vector.y) .. ", " .. tostring(vector.z)
	end
	return positionString
end

function FindManipulator(module)
	for _, side in pairs(peripheral.getNames()) do
		if peripheral.getType(side) == "manipulator" and peripheral.call(side, "hasModule", module) then
			return peripheral.wrap(side)
		end
	end
	error("Manipulator with "..module.." not found", 2)
end
