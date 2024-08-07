do
local counter = 0
local offset = 0

function WOMBPLUS:ScarredBabyUpdate(entity) --Scarred Baby AI function
	local data = entity:GetData()
	if data.State == nil then data.State = 0 end
	if data.StateFrame == nil then data.StateFrame = 0 end
	local target = entity:GetPlayerTarget()

	data.StateFrame = data.StateFrame + 1

	if data.State == 0 then
		data.State = 1
		data.StateFrame = 0
		entity:GetSprite():Play("Idle", true)

	elseif data.State == 1 then
		entity.Velocity = (target.Position - entity.Position):Normalized():Resized(3)

		if entity:GetSprite():IsFinished("Idle") then
			counter = counter + 1
			if counter > 15 + offset then
				data.State = 2
				counter = 0
				offset = math.random(10)
				entity:GetSprite():Play("Spit", true)
			end
			data.StateFrame = 0
		end

	elseif data.State == 2 then
		entity.Velocity = entity.Velocity * 0.80
		
		if entity:GetSprite():IsEventTriggered("Spit") then
			local vel = (target.Position - entity.Position):Normalized()
			local par = ProjectileParams()
			par.VelocityMulti = 4
			par.Scale = 2
			par.FallingSpeedModifier = -1
			par.HeightModifier = -10
			entity:FireProjectiles(entity.Position, vel, 0, par)
		elseif entity:GetSprite():IsFinished("Spit") then
			data.State = 3
			data.StateFrame = 0
			entity:GetSprite():Play("Teleport", true)
		end

	elseif data.State == 3 then
		entity.Velocity = entity.Velocity * 0.80

		if entity:GetSprite():IsEventTriggered("Teleport") then
			local targetPosition = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 10)
			while target.Position:Distance(targetPosition) < 200 do
				targetPosition = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 10)
			end
			entity.Position = targetPosition
		elseif entity:GetSprite():IsFinished("Teleport") then
			data.State = 1
			data.StateFrame = 0
			entity:GetSprite():Play("Idle", true)
		end

	end
end
end