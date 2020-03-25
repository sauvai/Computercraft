os.loadAPI("const/files.lua")
os.loadAPI(files.items)

local scannerRadius = 8
local scannerWidth = scannerRadius * 2 + 1

local Scanner = {}

-- Constructeur
function Scanner.__init__(baseClass, peripheral)
	self = {}
	setmetatable(self, { __index = Scanner })

	self.peripheral = peripheral
	self.scannedData = {}
	return self
end

--Makes Scanner(...) act like Scanner.__init__ (Scanner, ...)
setmetatable(Scanner, { __call = Scanner.__init__ })


-- PUBLIC
function Scanner:Scan()
	self.scannedData = self.peripheral.scan()
end

function New(peripheral)
	return Scanner(peripheral)
end

function Scanner:IsBlockInRange(x, y, z)
	return math.abs(x) <= scannerRadius and math.abs(y) <= scannerRadius and math.abs(z) <= scannerRadius
end

function Scanner:GetBlock(x, y, z)
	if not self:IsBlockInRange(x, y, z) then return nil end
	return self.scannedData[scannerWidth ^ 2 * (x + scannerRadius) + scannerWidth * (y + scannerRadius) + (z + scannerRadius) + 1]
end

function Scanner:GetBlockMeta(x, y, z)
	if not self:IsBlockInRange(x, y, z) then return nil end
	return self.peripheral.getBlockMeta(x, y, z)
end

function Scanner:GetRadius()
	return scannerRadius
end

function Scanner:GetOwnDirection()
	return self:GetBlock(0, 0, 0).state.facing
end

function Scanner:IsEmptyBlock(x, y, z)
	local block = self:GetBlock(x, y, z)
	return block == nil or block.name == items.minecraft.air or block.name == items.minecraft.water or block.name == items.minecraft.lava
end
