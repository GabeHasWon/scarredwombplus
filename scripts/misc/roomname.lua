WOMBPLUS:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	local room = Game():GetLevel():GetCurrentRoomDesc().Data.Name

	if string.match(room, "^ScarredWomb+ -") and not Game():GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD) then
		local x = Isaac.GetScreenWidth() / 2 - Isaac.GetTextWidth(room) / 2
		Isaac.RenderText(room, x, Isaac.GetScreenHeight() - 16, 255, 255, 255, 0.8)
	end
end)