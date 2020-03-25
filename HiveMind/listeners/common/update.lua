function Listener(id, data)
	for _, file in ipairs(fs.list("/")) do
		if not fs.isReadOnly(file) then
			fs.delete(file)
		end
	end

	for file, content in pairs(data.files) do
		local h = fs.open(file, "w")
		h.write(content)
		h.close()
	end

	os.reboot()
end
