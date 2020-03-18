Git = assert(loadfile("git/git.lua")())
Git:showOutput(false)
Git:setProvider("github")
Git:setRepository("sauvai", "Computercraft", "master")
 
Git:cloneTo("temp")
 
local files = {
  "api",
  "batteryFarm.lua",
  "GPS.lua",
  "replaceBattery.lua",
  "treeFarm.lua",
  "turtleQuarry.lua",
  "updateScripts.lua"
}
 
for i = 1, #files do
  shell.run("rm", files[i])
end
 
shell.run("mv temp/* .")
shell.run("rm temp")
