local GPS = {}

local x
local y
local z

local orientIndex = 0

local orientations = {} -- {x, y}

for i = 0, 3 do orientations[i] = {} end
-- create a new row
orientations[0][0] = 0
orientations[0][1] = 1

orientations[1][0] = -1
orientations[1][1] = 0

orientations[2][0] = 0
orientations[2][1] = -1

orientations[3][0] = 1
orientations[3][1] = 0

function GPS.init()
    if fs.exists("gpsLog") then
        gpsLog = fs.open("gpsLog", "r")
        x = tonumber(gpsLog.readLine())
        y = tonumber(gpsLog.readLine())
        z = tonumber(gpsLog.readLine())
        orientIndex = tonumber(gpsLog.readLine())

        if x == nil then error("GPS file is incomplete") end
        if y == nil then error("GPS file is incomplete") end
        if z == nil then error("GPS file is incomplete") end
        if orientIndex == nil then error("GPS file is incomplete") end

        gpsLog.close("gpsLog")
    else
        error(
            "Missing GPS file !\nWrite one with the turtle's default position and orientation")
    end
    print("x: " .. x)
    print("y: " .. y)
    print("z: " .. z)
end

function writeLog()
    if fs.exists("gpsLog") then
        gpsLog = fs.open("gpsLog", "w")
        gpsLog.flush()
        gpsLog.writeLine(tostring(x))
        gpsLog.writeLine(tostring(y))
        gpsLog.writeLine(tostring(z))
        gpsLog.writeLine(tostring(orientIndex))
        gpsLog.close("gpsLog")
    else
        error(
            "Missing GPS file !\nWrite one named \"gpsLog\" with the turtle's default position and orientation")
    end
end

function GPS.pathLength(destX, destY, destZ)
    local xDist = destX - x
    local yDist = destY - y
    local zDist = destZ - z

    if xDist < 0 then xDist = xDist * -1 end
    if yDist < 0 then yDist = yDist * -1 end
    if zDist < 0 then zDist = zDist * -1 end
    return xDist + yDist + zDist
end

function forwardFor(length, force)
    force = force or false
    for i = 1, length do if not GPS.forward(force) then return false end end
    return true
end

function turnUntil(orX, orY)
    local xCond = orX > 0
    local yCond = orY > 0

    print(xCond)
    while orX ~= 0 and (xCond ~= (orientations[orientIndex][0] > 0) or orientations[orientIndex][0] == 0) do GPS.turnRight() end
    while orY ~= 0 and (yCond ~= (orientations[orientIndex][1] > 0) or orientations[orientIndex][1] == 0) do GPS.turnLeft() end
end

function GPS.goTo(destX, destY, destZ, force) -- return true if success
    force = force or false
    if GPS.pathLength(destX, destY, destZ) < turtle.getFuelLevel() then
        xDist = destX - x
        yDist = destY - y
        zDist = destZ - z

        -- moving x axe
        print("x: " .. x)
        print("destX: " .. destX)
        print("xDist: " .. xDist)
        if xDist ~= 0 then
            turnUntil(xDist, 0)
            if xDist < 0 then xDist = xDist * -1 end
            if not forwardFor(xDist, force) then return false end
        end

        -- moving y axe
        print("y: " .. y)
        print("destY: " .. destY)
        print("yDist: " .. yDist)
        if yDist ~= 0 then
            turnUntil(0, yDist)
            if yDist < 0 then yDist = yDist * -1 end
            if not forwardFor(yDist, force) then return false end
        end

        -- moving z axe
        print("z: " .. z)
        print("destZ: " .. destZ)
        print("zDist: " .. zDist)
        if zDist ~= 0 then
            if zDist < 0 then
                zDist = zDist * -1

                for i = 1, zDist do GPS.down(force) end
            else
                for i = 1, zDist do GPS.up(force) end
            end
        end
        return true
    else
        print("I don\'t have enough fuel to go here !")
        return false
    end
end

function GPS.getCoord() return x, y, z end

function GPS.getOrientation() return orientations[orientIndex] end

function oriented(dir) -- 1 or -1
    if dir ~= -1 and dir ~= 1 then
        error("invalid value for GPS.oriented, -1 or 1 only")
    end
    orientIndex = orientIndex + dir
    if orientIndex < 0 then orientIndex = 3 end
    if orientIndex >= 4 then orientIndex = 0 end
    writeLog()
end

function GPS.turnRight()
    if turtle.turnRight() then
        oriented(1)
        return true
    else
        return false
    end
end

function GPS.turnLeft()
    if turtle.turnLeft() then
        oriented(-1)
        return true
    else
        return false
    end
end

function GPS.forward(force)
    force = force or false
    if not turtle.forward() and not force then
        return false
    elseif force then
        while not turtle.forward() do turtle.dig() end
    end
    x = x + orientations[orientIndex][0]
    y = y + orientations[orientIndex][1]
    writeLog()
    return true
end

function GPS.up(force)
    force = force or false
    if not turtle.up() and not force then
        return false
    elseif force then
        while not turtle.up() do turtle.digUp() end
    end
    z = z + 1
    writeLog()
    return true
end

function GPS.down(force)
    force = force or false
    if not turtle.down() and not force then
        return false
    elseif force then
        while not turtle.down() do turtle.digDown() end
    end
    z = z - 1
    writeLog()
    return true
end

return GPS