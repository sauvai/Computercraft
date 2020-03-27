os.loadAPI("const/files.lua")
os.loadAPI(files.items)
os.loadAPI(files.utils)

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

function Scanner:IsBlockInRange(...)
	local v = utils.VariadicToVector(arg)
	return math.abs(v.x) <= scannerRadius and math.abs(v.y) <= scannerRadius and math.abs(v.z) <= scannerRadius
end

function Scanner:GetBlock(...)
	local v = utils.VariadicToVector(arg)
	if not self:IsBlockInRange(v) then return nil end
	return self.scannedData[scannerWidth ^ 2 * (v.x + scannerRadius) + scannerWidth * (v.y + scannerRadius) + (v.z + scannerRadius) + 1]
end

function Scanner:GetBlockMeta(...)
	local v = utils.VariadicToVector(arg)
	if not self:IsBlockInRange(v) then return nil end
	return self.peripheral.getBlockMeta(v.x, v.y, v.z)
end

function Scanner:GetRadius()
	return scannerRadius
end

function Scanner:GetOwnDirection()
	return self:GetBlock(0, 0, 0).state.facing
end

function Scanner:IsEmptyBlock(...)
	local v = utils.VariadicToVector(arg)
	local block = self:GetBlock(v)
	return block == nil or block.name == items.minecraft.air or block.name == items.minecraft.water or block.name == items.minecraft.lava
end

function Scanner:FindBlocks(...)
	local blocks = {}
	for _, block in pairs(arg) do
		blocks[block] = {}
	end

	local minDistance = self:GetRadius() * -1
	local maxDistance = self:GetRadius()
	for x = minDistance, maxDistance do
		for y = minDistance, maxDistance do
			for z = minDistance, maxDistance do
				for name, list in pairs(blocks) do
					if self:GetBlock(x, y, z).name == name then
						table.insert(list, vector.new(x, y, z))
					end	
				end
			end
		end
	end

	return blocks
end
