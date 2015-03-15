registerBlock(0, 0, 0, 0, function() end, function() end, function() end)

registerBlock(96, 0, 0, 0, function(x, y)
	player.setRespawnX(x)
	player.setRespawnY(y)
end, function() end, function() end)

registerBlock(96, 0, 127, 0, function() end, function(x, y)
	if player.getX() == x and player.getY() == y and player.getState() == 0 then
		player.setRespawnX(x)
		player.setRespawnY(y)
	end
end, function() end)

registerBlock(96, 0, 255, 0, function(x, y)
	player.setFinishX(x)
	player.setFinishY(y)
end, function(x, y)
	if player.getX() == x and player.getY() == y and player.getState() == 0 then
		win()
	end
end, function() end)