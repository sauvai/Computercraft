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

function New(peripheral)
    return Scanner(peripheral)
end

function Scanner:Scan()
    self.scannedData = self.peripheral.scan()
end

function Scanner:GetBlock(x, y, z)
    return self.scannedData[scannerWidth ^ 2 * (x + scannerRadius) + scannerWidth * (y + scannerRadius) + (z + scannerRadius) + 1]
end

function Scanner:GetBlockMeta(x, y, z)
    return self.peripheral.getBlockMeta(x, y, z)
end

function Scanner:GetRadius()
    return scannerRadius
end

function Scanner:GetOwnDirection()
    return self:GetBlock(0, 0, 0).state.facing
end
