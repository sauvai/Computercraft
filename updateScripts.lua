Git = assert(loadfile("git/git.lua")())
Git:showOutput(false)
Git:setProvider("github")
Git:setRepository("sauvai", "Computercraft", "master")
 
Git:cloneTo("temp")
 
local files = {
  "api",
  "GPS.lua",
  "batteryFarm.lua",
  "replaceBattery.lua",
  "treeFarm.lua",
  "turtleQuarry.lua"
}
 
for i = 1, #files do
  shell.run("rm", files[i])
end
 
shell.run("mv temp/* .")
shell.run("rm temp")
