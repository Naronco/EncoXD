registerBlock(0, 0, 0, 0, function() end, function() end, function() end) -- Regular Block

donutStates = {}

registerBlock(0, 32, 0, 1, function(x, y)
	donutStates[makeUniqueFromXY(x, y)] = false
end, function(x, y)
	if donutStates[makeUniqueFromXY(x, y)] then
		setBlockEnabled(x, y, false)
	end
	if player.getX() == x and player.getY() == y then
		donutStates[makeUniqueFromXY(x, y)] = true
	end
	if player.getState() == 1 and player.getX() + 1 == x and player.getY() == y then
		donutStates[makeUniqueFromXY(x, y)] = true
	end
	if player.getState() == 2 and player.getX() - 1 == x and player.getY() == y then
		donutStates[makeUniqueFromXY(x, y)] = true
	end
	if player.getState() == 3 and player.getX() == x and player.getY() + 1 == y then
		donutStates[makeUniqueFromXY(x, y)] = true
	end
	if player.getState() == 4 and player.getX() == x and player.getY() - 1 == y then
		donutStates[makeUniqueFromXY(x, y)] = true
	end
end, function(x, y)
	donutStates[makeUniqueFromXY(x, y)] = false
	setBlockEnabled(x, y, true)
end) -- Donut Block

registerBlock(96, 0, 0, 1, function(x, y) -- Start
	player.setRespawnX(x)
	player.setRespawnY(y)
end, function() end, function() end)

registerBlock(96, 0, 127, 3, function() end, function(x, y) -- Checkpoint
	if player.getX() == x and player.getY() == y and player.getState() == 0 then
		player.setRespawnX(x)
		player.setRespawnY(y)
	end
end, function() end)

registerBlock(96, 0, 255, 2, function(x, y) -- Finish
	player.setFinishX(x)
	player.setFinishY(y)
end, function(x, y)
	if player.getX() == x and player.getY() == y and player.getState() == 0 then
		win()
	end
end, function() end)

switches = {}

for i=0,127 do
	switches[i] = false

	registerBlockImportant(32, 0, 128 + i, 4, function() end, function(x, y)
		if player.getX() == x and player.getY() == y then
			switches[i] = true
		end
		if player.getState() == 1 and player.getX() + 1 == x and player.getY() == y then
			switches[i] = true
		end
		if player.getState() == 2 and player.getX() - 1 == x and player.getY() == y then
			switches[i] = true
		end
		if player.getState() == 3 and player.getX() == x and player.getY() + 1 == y then
			switches[i] = true
		end
		if player.getState() == 4 and player.getX() == x and player.getY() - 1 == y then
			switches[i] = true
		end
	end, function(x, y)
		switches[i] = false
	end)

	registerBlockImportant(32, 32, 128 + i, 4, function() end, function(x, y)
		if player.getX() == x and player.getY() == y then
			switches[i] = not switches[i]
		end
		if player.getState() == 1 and player.getX() + 1 == x and player.getY() == y then
			switches[i] = not switches[i]
		end
		if player.getState() == 2 and player.getX() - 1 == x and player.getY() == y then
			switches[i] = not switches[i]
		end
		if player.getState() == 3 and player.getX() == x and player.getY() + 1 == y then
			switches[i] = not switches[i]
		end
		if player.getState() == 4 and player.getX() == x and player.getY() - 1 == y then
			switches[i] = not switches[i]
		end
	end, function(x, y)
		switches[i] = false
	end)

	registerBlockImportant(32, 64, 128 + i, 5, function() end, function(x, y)
		if player.getX() == x and player.getY() == y and player.getState() == 0 then
			switches[i] = true
		end
	end, function(x, y)
		switches[i] = false
	end)

	registerBlockImportant(32, 96, 128 + i, 5, function() end, function(x, y)
		if player.getX() == x and player.getY() == y and player.getState() == 0 then
			switches[i] = not switches[i]
		end
	end, function(x, y)
		switches[i] = false
	end)

	registerBlock(32, 0, i, 6, function(x, y)
		setBlockEnabled(x, y, false)
	end, function(x, y)
		setBlockEnabled(x, y, switches[i])
	end, function(x, y)
		setBlockEnabled(x, y, false)
	end)

	registerBlock(32, 255, i, 6, function(x, y)
		setBlockEnabled(x, y, true)
	end, function(x, y)
		setBlockEnabled(x, y, not switches[i])
	end, function(x, y)
		setBlockEnabled(x, y, true)
	end)
end
