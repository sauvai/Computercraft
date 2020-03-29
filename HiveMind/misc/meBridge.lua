os.loadAPI("const/files.lua")
os.loadAPI(files.inventory)
os.loadAPI(files.items)

local energyCellNbt = "{Recv:1000,RSControl:0b,Facing:3b,Energy:0,SideCache:[B;2B,1B,1B,1B,1B,1B],Level:0b,Send:1000}"

local meBridgeSide = {
    ["up"] = "down",
	["down"] = "up",
	["north"] = "south",
	["south"] = "north",
	["east"] = "west",
	["west"] = "east",
}

local MeBridge = {}

-- Constructeur
function MeBridge.__init__(baseClass, peripheral, direction)
    if not peripheral then
        error("Provided peripheral is nil", 2)
    end
    if not meBridgeSide[direction] then
        error("Invalid direction provided (direction:"..tostring(direction)..")", 2)
    end

    self = {}
    setmetatable(self, { __index = MeBridge })

    self.peripheral = peripheral
    self.side = meBridgeSide[direction]
    return self
end

--Makes MeBridge(...) act like MeBridge.__init__ (MeBridge, ...)
setmetatable(MeBridge, { __call = MeBridge.__init__ })

-- PUBLIC
function New(peripheral, direction)
    return MeBridge(peripheral, direction)
end

function MeBridge:FindItems(itemName)
    local items = {}

    for _, item in pairs(self.peripheral.listItems()) do
        if item.name == itemName then
            table.insert(items, item)
        end
    end

    return items
end

function MeBridge:FindCraft(itemName)
    for _, item in pairs(self.peripheral.listCraft()) do
        if item.name == itemName then
            return item
        end
    end

    return nil
end

function MeBridge:ItemCount(itemName)
    local count = 0
    for _, item in pairs(self:FindItems(itemName)) do
        count = count + item.amount
    end
    return count
end

function MeBridge:GetItem(itemName, count)
    local items = self:FindItems(itemName)
    local totalRetrievedCount = 0

    for _, item in pairs(items) do
        local retrievedCount = self.peripheral.retrieve(item.name, item.meta, count - totalRetrievedCount, self.side, item.nbt)
        totalRetrievedCount = totalRetrievedCount + retrievedCount
        if totalRetrievedCount >= count then
            return totalRetrievedCount
        end
    end

    return totalRetrievedCount
end

function MeBridge:CraftItem(itemName, count)
    local craft = self:FindCraft(itemName)
    if craft == nil then return false end

    if craft.name == items.thermalExpansion.energyCell then
        craft.nbt = energyCellNbt
    end

    self.peripheral.craft(craft.name, craft.meta, count, craft.nbt)

    while true do
        local event, name, amount, bytes, success = os.pullEvent()
        if name == craft.name and amount == count then
            return success
        end
    end
end