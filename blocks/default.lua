registerBlock(0, 0, 0, 0, function() end, function() end, function() end) -- Regular Block

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

	registerBlock(32, 0, i, 1, function(x, y)
		setBlockEnabled(x, y, false)
	end, function(x, y)
		setBlockEnabled(x, y, switches[i])
	end, function(x, y)
		setBlockEnabled(x, y, false)
	end)

	registerBlock(32, 255, i, 1, function(x, y)
		setBlockEnabled(x, y, true)
	end, function(x, y)
		setBlockEnabled(x, y, not switches[i])
	end, function(x, y)
		setBlockEnabled(x, y, true)
	end)

	registerBlock(32, 0, 128 + i, 1, function() end, function(x, y)
		if player.getX() == x and player.getY() == y then
			switches[i] = true
		end
		if player.getState() == 1 and player.getX() + 1 == x and player.getY() == y then
			switches[i] = true
		end
		if player.getState() == 2 and player.getX() - 1 == x and player.getY() == y then
			switches[i] = true
		end
		if player.getState() == 3 and player.getX() == x and player.getY() == y + 1 then
			switches[i] = true
		end
		if player.getState() == 4 and player.getX() == x and player.getY() == y - 1 then
			switches[i] = true
		end
	end, function(x, y)
		switches[i] = false
	end)

	registerBlock(32, 32, 128 + i, 1, function() end, function(x, y)
		if player.getX() == x and player.getY() == y then
			switches[i] = not switches[i]
		end
		if player.getState() == 1 and player.getX() + 1 == x and player.getY() == y then
			switches[i] = not switches[i]
		end
		if player.getState() == 2 and player.getX() - 1 == x and player.getY() == y then
			switches[i] = not switches[i]
		end
		if player.getState() == 3 and player.getX() == x and player.getY() == y + 1 then
			switches[i] = not switches[i]
		end
		if player.getState() == 4 and player.getX() == x and player.getY() == y - 1 then
			switches[i] = not switches[i]
		end
	end, function(x, y)
		switches[i] = false
	end)

	registerBlock(32, 64, 128 + i, 1, function() end, function(x, y)
		if player.getX() == x and player.getY() == y and player.getState() == 0 then
			switches[i] = true
		end
	end, function(x, y)
		switches[i] = false
	end)

	registerBlock(32, 96, 128 + i, 1, function() end, function(x, y)
		if player.getX() == x and player.getY() == y and player.getState() == 0 then
			switches[i] = not switches[i]
		end
	end, function(x, y)
		switches[i] = false
	end)
end
