function Listener(id, data)
	for _, file in ipairs(fs.list("/")) do
		if not fs.isReadOnly(file) then
			fs.delete(file)
		end
	end

	for file, content in pairs(data.files) do
		local h = fs.open(file, "w")
		if h == nil then error("Can't open file "..file) end
		h.write(content)
		h.close()
	end

	os.reboot()
end
