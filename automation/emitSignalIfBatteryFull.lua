local scan = peripheral.wrap("left")

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function getBatteryEnergy(x, z, y)
    local battery = scan.getBlockMeta(x, z, y)
    local energy = battery.energy
    return energy
end

function isBatteryFull(energy)
    if energy ~= nil and energy.stored >= energy.capacity * 0.95 then
        return true
    else
        return false
    end
end

function batteryPercent(energy)
    if energy ~= nil then
        percent = (energy.stored / energy.capacity) * 100
        write("[")
        for i = 1, round(percent / 10, 0) do write("|") end
        for i = 1, round(10 - (percent / 10), 0) do write(".") end
        write("] ")
        write(round(percent, 2))
        write("%")
        write("\n")
    else
        write("No battery to detect\n")
    end
end

while true do
    shell.run("clear")
    energy = getBatteryEnergy(0, -1, 0)
    batteryPercent(energy)
    if isBatteryFull(energy) then
        redstone.setOutput("front", false)
    else
        redstone.setOutput("front", true)
    end
    os.sleep(2)

end
