WOMBPLUS:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if (FiendFolio) then
		return;
	end

	local room = Game():GetLevel():GetCurrentRoomDesc().Data.Name

	if string.match(room, "^ScarredWomb+ -") and not Game():GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD) then
		local tabHeld = Input.IsActionPressed(ButtonAction.ACTION_MAP, Isaac.GetPlayer(0).ControllerIndex)
		local scale = 1

		if not tabHeld then
			scale = 0.5
		end

		local x = Isaac.GetScreenWidth() / 2 - Isaac.GetTextWidth(room) * 0.5 * scale
		Isaac.RenderScaledText(room, x, Isaac.GetScreenHeight() - 16 * scale, scale, scale, 240, 240, 240, 0.6)
	end
end)