-- shell.run("pastebin run GFVEwzSn")

local scan = peripheral.wrap("left")
term.clear()
term.setCursorPos(1, 1)

local x = 0
local y = 0

print("\nEmpty batteries chest on the top, full batteries one on the left\n")


function getBatteryEnergy(x, z, y)
    local battery = scan.getBlockMeta(x, z, y)
    local energy = battery.energy
    if battery.displayName == "Turtle Charger (RF)" then
        energy = nil
    end
    return energy
end

function isBatteryEmpty(energy)
    if energy ~= nil and energy.stored <= energy.capacity * 0.05 then
        return true
    else
        return false
    end
end

function throwEmptyBattery()
    turtle.dig()
    turtle.dropUp()
end

function putNewBattery()
    turtle.turnLeft()
    while not turtle.suck() do
    end
    turtle.turnRight()
    while not turtle.place() do
    end
end

function setDirection()
    local data = scan.getBlockMeta(0, 0, 0)
    local chestDirection = data.state.facing
    if chestDirection == "west" then
        x = -1
    elseif chestDirection == "east" then
        x = 1
    elseif chestDirection == "north" then
        y = -1
    elseif chestDirection == "south" then
        y = 1
    end
end

function start()
    local _, data  = turtle.inspect()
    while data.displayName ~= "tile.ender_storage.name" do
        turtle.turnLeft() 
        _, data = turtle.inspect()
    end
    turtle.turnRight()
    setDirection()
end

start()

while true do
    if not turtle.detect() or isBatteryEmpty(getBatteryEnergy(x, 0, y)) then
        if turtle.detect() then
            throwEmptyBattery()
        end
        putNewBattery()
    end
end