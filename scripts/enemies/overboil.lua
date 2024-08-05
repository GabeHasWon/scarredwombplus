function WOMBPLUS:OverboilUpdate(entity)
	local data = entity:GetData()
	local sprite = entity:GetSprite()
	local target = entity:GetPlayerTarget()

	if data.init == nil then 
		data.init = true
		data.timer = 0 
		data.orientation = "Hori"
		data.shooting = false

	end

	data.timer = data.timer + 1

	local factor = entity.HitPoints / entity.MaxHitPoints
	local animId = tostring(math.floor(5 - (factor * 5)))

	if animId == "-1" then
		animId = "0"
	end

	if entity.HitPoints < entity.MaxHitPoints and data.timer % 10 == 0 then
		entity.HitPoints = entity.HitPoints + 1
	end

	if data.shooting == false then
		local idle = data.orientation .. "_" .. animId

		if not sprite:IsPlaying(idle) or sprite:IsFinished(idle) then
			sprite:Play(idle, true)
		end

		if data.timer > 80 then 
			data.shooting = true
			data.timer = 0
			sprite:Play(idle .. "_Shoot")
		end

	else 
		if sprite:IsEventTriggered("Shoot") then
			for i = 0, 15 do
				local par = ProjectileParams()
				par.VelocityMulti = 2
				par.CurvingStrength = 0.02
				par.Scale = 1
				par.FallingAccelModifier = 1.1

				local randomMinorOffset = math.random(100) * 0.001 - 0.05
				local siz = (math.random(200) * 0.1 - 10) * (factor)
				local vel = Vector(randomMinorOffset, 1):Resized(siz)

				if data.orientation == "Hori" then
					vel = Vector(1, randomMinorOffset):Resized(siz)
				end

				par.FallingSpeedModifier = (math.abs(siz) - 8) * 8 * (math.random(6, 8) * 0.1)

				entity:FireProjectiles(entity.Position, vel, 0, par) 
			end

		end

		local idle = data.orientation .. "_" .. animId
		 
		if sprite:IsFinished(idle .. "_Shoot") or not sprite:IsPlaying(idle .. "_Shoot") then
			sprite:Play(idle, true)
			data.shooting = false
			data.timer = 0
			sprite:Play(idle .. "_Shoot")
		end

	end

end