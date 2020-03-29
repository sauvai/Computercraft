os.loadAPI("const/files.lua")
os.loadAPI(files.inventory)

local interfaceSide = {
    ["up"] = "down",
	["down"] = "up",
	["north"] = "south",
	["south"] = "north",
	["east"] = "west",
	["west"] = "east",
}

local Interface = {}

-- Constructeur
function Interface.__init__(baseClass, peripheral, direction)
    if not peripheral then
        error("Provided peripheral is nil", 2)
    end
    if not interfaceSide[direction] then
        error("Invalid direction provided (direction:"..tostring(direction)..")", 2)
    end

    self = {}
    setmetatable(self, { __index = Interface })

    self.peripheral = peripheral
    self.side = interfaceSide[direction]
    return self
end

--Makes Interface(...) act like Interface.__init__ (Interface, ...)
setmetatable(Interface, { __call = Interface.__init__ })

-- PUBLIC
function New(peripheral, direction)
    return Interface(peripheral, direction)
end

function Interface:DumpInventory()
    inventory.EquipScanner()
    for i = 1, 16 do
        self.peripheral.pullItems(self.side, i)
    end
end
