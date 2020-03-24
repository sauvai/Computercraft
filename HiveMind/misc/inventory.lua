os.loadAPI("const/files.lua")
os.loadAPI(files.items)
os.loadAPI(files.scanner)

-- PRIVATE
local function Equip(tool)
	local currentTool = peripheral.getType("left")
	
	-- Equip tool if not already equiped
	if tool ~= currentTool then
		local slot = Find(tool)
		if slot == nil then
			error("Turtle don't have " .. tool, 2)
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

function Unequip()
	local slot = FindEmptySlot()
	if not slot then
		error("Unable to unequip, no free slot", 2)
	end
	turtle.select(slot)
	turtle.equipLeft()
	return slot
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

function FindEmptySlot()
	for i = 1, 16 do
		local itemInSlot = turtle.getItemDetail(i)
		
		if not itemInSlot then
			return i
		end
	end
	return nil
end
