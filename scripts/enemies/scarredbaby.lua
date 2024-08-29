do
local counter = 0
local offset = 0

function WOMBPLUS:ScarredBabyUpdate(entity)
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
			if counter > 20 + offset then
				data.State = 2
				counter = 0
				offset = math.random(0, 10)
				entity:GetSprite():Play("Spit", true)
			end
			data.StateFrame = 0
		end

	elseif data.State == 2 then
		entity.Velocity = entity.Velocity * 0.80
		
		if entity:GetSprite():IsEventTriggered("Spit") then
			if not entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) or math.random(0, 10) > 2 then
				local vel = (target.Position - entity.Position):Normalized()

				if entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
					vel = vel * math.random(60, 80) * 0.01
					vel = vel:Rotated(math.random(-60, 60))
				end

				local par = ProjectileParams()
				par.VelocityMulti = 8
				par.Scale = 2
				par.FallingSpeedModifier = 0.5
				par.FallingAccelModifier = 0.2
				par.HeightModifier = -10
				entity:FireProjectiles(entity.Position, vel, 0, par)
			end
		elseif entity:GetSprite():IsFinished("Spit") then
			data.State = 3

			if math.random(0, 10) < 5 then
				data.State = 1
			end

			data.StateFrame = 0
			local anim = "Teleport"

			if data.State == 1 then
				anim = "Idle"
			end

			entity:GetSprite():Play(anim, true)
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