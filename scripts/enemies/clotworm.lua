function WOMBPLUS:ClotwormUpdate(entity)
	local data = entity:GetData()
	local sprite = entity:GetSprite()
	local target = entity:GetPlayerTarget()

	if data.init == nil then 
		data.init = true
		data.timer = 0
		data.deathThroes = false
		sprite:Play("Idle", true)

	end

	if not data.deathThroes then 
		data.timer = data.timer + 1

		if data.timer > 20 then
			if data.timer == 21 then
				if Game():GetRoom():CheckLine(entity.Position, target.Position, 3, 3, true, false) then
					sprite:Play("Shoot", true)

				else
					data.timer = 0

				end
			end

			if sprite:IsEventTriggered("Shoot") then
				local vel = (target.Position - entity.Position):Normalized()

				if entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
					vel = vel * 0.8
					vel = vel:Rotated(math.random(-20, 20))
				end

				local par = ProjectileParams()
				par.VelocityMulti = 8
				par.Scale = 1.6
				par.FallingSpeedModifier = 0.6
				par.HeightModifier = -24
				entity:FireProjectiles(entity.Position, vel, 0, par)

			end

			if not sprite:IsPlaying("Shoot") then
				data.timer = 0	

			end
		end

		if not sprite:IsPlaying("Idle") and data.timer <= 20 then
				sprite:Play("Idle", true)

		end

	else 
		if data.timer == 0 then
			if sprite:IsFinished("Hide") then
				data.timer = 1
				sprite:Play("HideShoot", true)
			end

		else if data.timer == 1 then
			if sprite:IsFinished("HideShoot") and not sprite:IsPlaying("Death") then
				sprite:Play("HideShoot", true)

			end

			if sprite:IsEventTriggered("Shoot") then
				for i = 0, 8 do
					local vel = Vector(0, math.random(50, 100) * 0.01):Normalized():Rotated(math.random(0, 360)):Resized(math.random(50, 100) * 0.01)

					local par = ProjectileParams()
					par.VelocityMulti = 8
					par.FallingAccelModifier = 1.5
					par.CurvingStrength = 0.02
					par.Scale = 1
					par.FallingSpeedModifier = math.random(-20, -5) * 0.1
					par.HeightModifier = -12
					entity:FireProjectiles(entity.Position, vel, 0, par)
				end
			end

			if not sprite:IsPlaying("Death") then
				local count = Game():GetRoom():GetAliveEnemiesCount()
				print(tostring(count - Isaac.CountEntities(nil, EntityType.COMMON, variant.CLOTWORM)))

				if (count - Isaac.CountEntities(nil, EntityType.COMMON, variant.CLOTWORM)) <= 0 then
					sprite:Play("Death")

				end
			
			end

			if sprite:IsEventTriggered("Die") then
				entity:Kill()

			end

		end

	end
end
end 

function WOMBPLUS:ClotwormHurt(entity, damage, flag, source)
	if entity.Variant == variant.CLOTWORM then
		local data = entity:GetData()
		
		if data.deathThroes then
			return false

		else if entity.HitPoints <= damage then
			data.deathThroes = true
			data.timer = 0
			entity:GetSprite():Play("Hide", true)
			return false
		end
	end

	return nil
end
end

WOMBPLUS:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, WOMBPLUS.ClotwormHurt, EntityType.COMMON)
