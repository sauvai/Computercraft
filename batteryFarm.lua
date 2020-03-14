term.clear()
term.setCursorPos(1, 1)
write("Edit farm length in the program\n")
local farmLength = 3


local scan = peripheral.wrap("left")
local fullBatteryStartingSlot = 1
local fullBatteryEndSlot = farmLength * 2
local emptyBatteryStartingSlot = fullBatteryEndSlot + 1
local maxEmptyBatteryStored = 16 - fullBatteryEndSlot

function countEmptyBattery()
    local batteryFound = 0
    for i = emptyBatteryStartingSlot, 16, 1 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            batteryFound = batteryFound + 1
        end
    end
    return batteryFound
end

function countFullBattery()
    local batteryFound = 0
    for i = fullBatteryStartingSlot, fullBatteryEndSlot, 1 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            batteryFound = batteryFound + 1
        end
    end
    turtle.select(emptyBatteryStartingSlot)
    return batteryFound
end

function getBatteryEnergy(x, z, y)
    local battery = scan.getBlockMeta(x, z, y)
    local energy = battery.energy
    if battery.displayName == "Turtle Charger (RF)" then
        energy = nil
    end
    return energy
end

function isBatteryFull(energy)
    if energy ~= nil and energy.stored >= energy.capacity * 0.95 then
        return true
    else
        return false
    end
end

function checkForEmptyBatteries()
    count = countEmptyBattery()
    turtle.select(emptyBatteryStartingSlot)
    while count == 0 do
        while count < maxEmptyBatteryStored and turtle.suck() do
            count = count + 1
        end
    end
end

function harvestBattery()
    turtle.select(fullBatteryStartingSlot)
    if isBatteryFull(getBatteryEnergy(0, 1, 0)) then
        turtle.digUp()
    end
    if isBatteryFull(getBatteryEnergy(0, -1, 0)) then
        turtle.digDown()
    end
end

function selectEmptyBatterySlot()
    for i = emptyBatteryStartingSlot, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            return true
        end
    end
    return false
end

function forwardHarvestPlace()
    while turtle.forward() do
        harvestBattery()
        if selectEmptyBatterySlot() then
            turtle.placeUp() 
        end
        if selectEmptyBatterySlot()  then
            turtle.placeDown()
        end
    end
end

function farmBatteries()
    forwardHarvestPlace()
    turtle.turnLeft()
    turtle.turnLeft()
    forwardHarvestPlace()
    turtle.turnLeft()
    turtle.turnLeft()
end

function putFullBatteryInChest()
    for i = fullBatteryStartingSlot, fullBatteryEndSlot, 1 do
        turtle.select(i)
        turtle.drop()
    end
end

function turtleIsOnCharger()
    local block = scan.getBlockMeta(0, -1, 0)
    if block.displayName == "Turtle Charger (RF)" then
        return true
    else
        return false
    end
end

function start()
    while not turtleIsOnCharger() do
        while turtle.forward() do
        end
        while turtle.detect() do
            turtle.turnLeft()
        end
    end
    while turtle.detect() do
            turtle.turnLeft()
    end
end

start()

while true do
    if countFullBattery() > 0 then
        turtle.turnLeft()
        putFullBatteryInChest()
        turtle.turnRight()
    end
    turtle.turnRight()
    checkForEmptyBatteries()
    turtle.turnLeft()
    farmBatteries()
end