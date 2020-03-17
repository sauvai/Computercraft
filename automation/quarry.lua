discord = require("DiscordApi")

username = os.getComputerLabel()
avatar = "https://i.imgur.com/H4vqsCs.jpg"
webhookUrl =
    "https://discordapp.com/api/webhooks/678438044663021588/qMc7WdDkptGk3zr9Y5VQIRcM_Z2h8sgbaV9OtfMzlIX7faWSDrmedXoMZVQBKixV6cjD"

function sendDisc(content) discord.send(webhookUrl, content, username, avatar) end

fuelChest = 1
chest = 2

function fuel()
    for i = 1, 16 do
        turtle.select(i)
        if turtle.refuel() then
            sendDisc("I got some fuel ! (" .. turtle.getFuelLevel() .. ")")
        end
    end
end

function refuelFromChest()
    turtle.select(fuelChest)
    while not turtle.place() do turtle.dig() end
    turtle.suck(64)
    turtle.refuel(64)
    turtle.drop(64)
    turtle.select(fuelChest)
    turtle.dig()
end

function dropInventoryInChest()
    turtle.select(chest)
    while not turtle.place() do turtle.dig() end
    for i = chest + 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(chest)
    turtle.dig()
    sendDisc("I dropped my inventory in the chest")
end

function goForward()
    while not turtle.forward() do turtle.dig() end
    turtle.digDown()
    turtle.digUp()
end

function goDown() while not turtle.down() do turtle.digDown() end end

function goUp() while not turtle.up() do turtle.digUp() end end

write("Longeur: ")
local lng = tonumber(read())

write("Largeur: ")
local lrg = tonumber(read())

write("Profondeur: ")
local depth = tonumber(read())

sendDisc("I will dig a quarry of " .. lng .. "x" .. lrg .. "x" .. depth ..
             " cubes")

local forwardCnt = 0
local rightCnt = 0
local height = 0
local orientation = 1 -- -1 front, 1 back

function turtleIsFull()
    empty = 0
    for i = chest + 1, 16, 1 do
        turtle.select(i)
        if turtle.getItemCount() == 0 then empty = empty + 1 end
    end
    return empty <= 4
end

function backToStartCorner()
    if orientation == 1 then
        turtle.turnRight()
        turtle.turnRight()
    end
    for i = forwardCnt, 1, -1 do goForward() end
    turtle.turnRight()
    for i = rightCnt, 1, -1 do goForward() end
    turtle.turnRight()
    forwardCnt = 0
    rightCnt = 0
    orientation = -1
end

function backToStart()
    backToStartCorner()
    for i = 1, height, 1 do goUp() end
    -- for i = 1, 16, 1 do
    --     turtle.select(i)
    --     turtle.drop()
    -- end
    -- suckCoal()
    turtle.turnRight()
    turtle.turnRight()
end

-- function suckCoal()
--     goUp()
--     turtle.suck(64)
--     while turtle.refuel(64) and turtle.getFuelLevel() < turtle.getFuelLimit() do
--         sendDisc("I got some fuel ! (" .. turtle.getFuelLevel() .. ")")
--         turtle.suck(64)
--     end
--     for i = 1, 16, 1 do
--         turtle.select(i)
--         turtle.drop()
--     end
--     goDown()
-- end

-- function storeToChest()
--     backToStart()
--     for i = 1, height, 1 do goDown() end
-- end

-- turtle.turnRight()
-- turtle.turnRight()
-- suckCoal()
-- turtle.turnRight()
-- turtle.turnRight()

while height < depth do
    for i = 1, lrg, 1 do
        if turtle.getFuelLevel() < 5000 then refuelFromChest() end
        if turtle.getFuelLevel() < 500 then
            sendDisc("I dont have a lot of energy left(" ..
                         turtle.getFuelLevel() .. ")")
        end
        for j = 2, lng, 1 do
            goForward()
            forwardCnt = forwardCnt + orientation
        end
        if turtleIsFull() then dropInventoryInChest() end
        if i % 2 ~= 0 and i < lrg then
            orientation = -1
            forwardCnt = lng - 1
            rightCnt = rightCnt + 1
            turtle.turnRight()
            goForward()
            turtle.turnRight()
        end
        if i % 2 == 0 and i < lrg then
            orientation = 1
            forwardCnt = 0
            rightCnt = rightCnt + 1
            turtle.turnLeft()
            goForward()
            turtle.turnLeft()
        end
    end
    backToStartCorner()

    if height + 3 < depth then
        for i = 1, 3 do goDown() end
        height = height + 3
    else
        for i = 1, depth - height do goDown() end
        height = height + (depth - height)
    end
end

backToStart()
dropInventoryInChest()
print("")
print("Done !")
sendDisc("Done !")
