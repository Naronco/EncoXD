info = {
	name = "network-test",
	version = "1.0.0"
}

local function main()
	print("Starting " .. info["name"] .. " version " .. info["version"])

	-- TODO: Replace Array with single values (LuaD dev needs to accept my PR)
	on("customEvent",
	function(e)
		print("Custom Events ", e[1], " ", e[2])
	end)

	emit("customEvent", "are awesome", "not")
end

main()
