--      Entity structure
-- {
--		type = "turtle" or "computer"
-- 		id = 0,
-- 		label = "Natacha",
-- 		task = nil,				-- Only for turtle
--		hasPinged = true,
--		position = { ... }
-- }

local entities = {}

function Add(type, id, label, position)
	table.insert(entities, { type = type, id = id, label = label, hasPinged = true, position = position })
end

function Remove(entityToBeRemoved)
	if entityToBeRemoved == nil then return end

	for key, entity in pairs(entities) do
		if entity == entityToBeRemoved then
			entities[key] = nil
			return
		end
	end

	error("Entity is not registered", 1)
end

function Get(type, id, label)
	if type ~= nil and type ~= "computer" and type ~= "turtle" then
		error("Invalid type specified: " .. type, 1)
	end

	local filteredEntities = {}
	for _, entity in pairs(entities) do
		if (type == nil or entity.type == type) and (id == nil or entity.id == id) and (label == nil or entity.label == label) then
			table.insert(filteredEntities, entity)
		end
	end

	if id ~= nil and #filteredEntities > 1 then
		error("There are more than 1 entity with id " .. tostring(id))
	end

	if id ~= nil then return filteredEntities[1] end
	return filteredEntities
end
