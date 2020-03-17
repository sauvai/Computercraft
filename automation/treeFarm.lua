local fuelChest = 1
local storeChest = 2
local saplingStart = 3
local sapling = 5

function emptyInChest()
    turtle.select(storeChest)
    while not turtle.placeUp() do turtle.digUp() end
    for i = sapling + 1, 16 do
        turtle.select(i)
        local c = turtle.getItemCount()

        if c > 1 then turtle.dropUp(c - 1) end
    end
    turtle.select(storeChest)
    turtle.digUp()
end

function refuelFromChest()
    turtle.select(fuelChest)
    while not turtle.placeUp() do turtle.digUp() end
    turtle.suckUp(64)
    turtle.refuel(64)
    turtle.dropUp(64)
    turtle.select(fuelChest)
    turtle.digUp()
end

function turtleIsFull()
    empty = 0
    for i = sapling + 1, 16, 1 do
        turtle.select(i)
        if turtle.getItemCount() < 50 then empty = empty + 1 end
    end
    return empty <= 4
end

function plant()
    for i = saplingStart, sapling do
        turtle.select(i)
        if turtle.getItemCount() > 1 then
            if turtle.placeDown() then break end
        end
    end
end

function cutTree()
    local h = 0
    turtle.digDown()
    while turtle.detectUp() do
        if h > 0 then
            for i = 1, 4 do
                turtle.turnLeft()
                local s, d = turtle.inspect()
                if d.name == "minecraft:leaves" then turtle.dig() end
            end
        end
        while not turtle.up() do turtle.digUp() end
        h = h + 1
    end
    for i = 1, h do while not turtle.down() do turtle.digDown() end end
end

function forward() -- go forward (dig wood and leaves)
    local s, d = turtle.inspect()
    if d.name == nil or s == false or d.name == "minecraft:leaves" or d.name ==
        "minecraft:log" or d.name == "minecraft:log2" then
        while not turtle.forward() do turtle.dig() end
        return true
    end
    return false
end

local turnFct = turtle.turnLeft

function switchTurnFct()
    if turnFct == turtle.turnLeft then
        turnFct = turtle.turnRight
    else
        turnFct = turtle.turnLeft
    end
end
function turn()
    turnFct()
    if not forward() then
        switchTurnFct()
        turnFct()
        turnFct()
        switchTurnFct()
    end
    turnFct()
    switchTurnFct()
end

function treeFarm()
    while true do
        if turtle.getFuelLevel() < 5000 then refuelFromChest() end

        local s, d = turtle.inspectUp()
        local s, dd = turtle.inspectDown()

        if d.name == "minecraft:log" or d.name == "minecraft:log2" or dd.name ==
            "minecraft:log" or dd.name == "minecraft:log2" then cutTree() end
        if not turtle.detectDown() then plant() end

        turtle.suckDown()

        if not forward() then
            if turtleIsFull() then emptyInChest() end
            turn()
            -- os.sleep(5)
        end
    end
end

function start()
    if turtle.getFuelLevel() < 5000 then refuelFromChest() end
    if turtle.getItemCount(fuelChest) == 0 then
        turtle.select(fuelChest)
        turtle.digUp()
    end

    if turtle.getItemCount(storeChest) == 0 then
        turtle.select(storeChest)
        turtle.digUp()
    end

    while true do
        local s, d = turtle.inspectDown()
        if d.name == "minecraft:sapling" or d.name == "minecraft:dirt" or d.name ==
            "minecraft:grass" or d.name == "minecraft:stained_hardened_clay" or
            d.name == "minecraft:torch" then
            break
        else
            while not turtle.down() do turtle.digDown() end
        end
    end

    local s, d = turtle.inspectDown()
    if d.name == "minecraft:dirt" or d.name == "minecraft:grass" or d.name ==
        "minecraft:stained_hardened_clay" then
        while not turtle.up() do turtle.digUp() end
    end
end

start()
treeFarm()
