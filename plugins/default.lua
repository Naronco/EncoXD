onStateChange(function()
	if not hasBlock(player.getX(), player.getY()) then
		player.respawn()
	end
	if player.getState() == 1 and not hasBlock(player.getX() + 1, player.getY()) then
		player.respawn()
	end
	if player.getState() == 2 and not hasBlock(player.getX() - 1, player.getY()) then
		player.respawn()
	end
	if player.getState() == 3 and not hasBlock(player.getX(), player.getY() + 1) then
		player.respawn()
	end
	if player.getState() == 4 and not hasBlock(player.getX(), player.getY() - 1) then
		player.respawn()
	end
end)
