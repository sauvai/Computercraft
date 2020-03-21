os.loadAPI("api/tools/scanner.lua")
os.loadAPI("api/utils/items.lua")

-- PRIVATE
local function Equip(tool)
	local currentTool = peripheral.getType("left")
	
	-- Equip tool if not already equiped
	if tool ~= currentTool then
		local slot = Find(tool)
		if slot == nil then
			print("ERROR: Turtle don't have " .. tool)
			return nil
		end
		turtle.select(slot)
		turtle.equipLeft() -- Always equip tools on the left side
	end
end


-- PUBLIC
function EquipScanner()
	Equip(items.tools.scanner)
	return scanner.New(peripheral.wrap("left"))
end

function EquipPickaxe()
	Equip(items.tools.pickaxe)
end

function Find(item)
	for i = 1, 16 do
		local itemInSlot = turtle.getItemDetail(i)
		
		if itemInSlot then
			if itemInSlot.name == items.tools.plethoraModule then
				itemInSlot.name = items.plethoraModules[itemInSlot.damage]
			end
			if item == itemInSlot.name then
				return i
			end
		end
	end
	return nil
end
