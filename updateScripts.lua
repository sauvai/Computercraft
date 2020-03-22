Git = assert(loadfile("git/git.lua")())
Git:showOutput(false)
Git:setProvider("github")
Git:setRepository("sauvai", "Computercraft", "master")
 
Git:cloneTo("temp")
 
local files = {
  "HiveMind",
  "*.lua",
}
 
for _, file in pairs(files) do
  shell.run("rm", file)
end
 
shell.run("mv temp/* .")
shell.run("rm temp")
