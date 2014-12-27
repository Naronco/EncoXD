info = {
	name = "network-test",
	version = "1.0.0"
}

local function main()
	print("Starting " .. info["name"] .. " version " .. info["version"])

	-- TODO: Replace Array with single values (LuaD dev needs to accept my PR)
	on("join",
	function(send, recv, sleep)
		print("Sending...")
		send("Hello World")
		send("This is networking!")
	end)
end

main()
