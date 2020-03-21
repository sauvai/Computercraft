function VectorToString(vector)
	local positionString
	if vector == nil then
		positionString = "nil"
	else
		positionString = tostring(vector.x) .. ", " .. tostring(vector.y) .. ", " .. tostring(vector.z)
	end
	return positionString
end
