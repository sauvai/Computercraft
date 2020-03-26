os.loadAPI("const/files.lua")
os.loadAPI(files.inventory)
os.loadAPI(files.items)

local interfaceSide = {
    ["top"] = "down",
	["bottom"] = "up",
	["north"] = "south",
	["south"] = "north",
	["east"] = "west",
	["west"] = "east",
}

local Interface = {}

-- Constructeur
function Interface.__init__(baseClass, peripheral, side)
    if not peripheral then
        error("Provided peripheral is nil", 2)
    end
    if not interfaceSide[side] then
        error("Invalid side provided (side:"..tostring(side)..")", 2)
    end

    self = {}
    setmetatable(self, { __index = Interface })

    self.peripheral = peripheral
    self.side = interfaceSide[side]
    return self
end

--Makes Interface(...) act like Interface.__init__ (Interface, ...)
setmetatable(Interface, { __call = Interface.__init__ })

-- PUBLIC
function New(peripheral, side)
    return Interface(peripheral, side)
end

function Interface:DumpInventory()
	for i = 1, 16 do
		self.peripheral.pullItems(self.side, i)
	end
	self.peripheral.pullItems(self.side, inventory.Unequip())
	-- Get back scanner
	self:GetItem({ name = "plethora:module", damage = 2 }, 1, true)
end

function Interface:GetItem(itemName, count, allowCraft) -- TODO separate in multiple simpler "do-task" function and move checks out of this class (so the turtle might change its behavior depending on the error)
    local item = self.peripheral.findItem(itemName)
    if not item then
        print("No items stored nor recipe to craft for", itemName)
        return nil
    end

    if count > item.getMetadata().count then
        if allowCraft then
            local craft = item.craft(count - item.getMetadata().count)
            if craft.status() == "missing" then
                print("Not enought", itemName, "available (needed amount:", count, ") and can't craft enought")
                return nil
            end
            while not craft.isFinished() or craft.isCanceled() do
                sleep(1)
            end
        else
            print("Not enought", itemName, "available (needed amount:", count, ") and crafting is not enabled for this item")
            return nil
        end
    end

    item = self.peripheral.findItem(itemName)
    local exportCount = math.min(item.getMetadata().count, count)
    if exportCount > 0 then
        return item.export(self.side, exportCount)
    end
end
