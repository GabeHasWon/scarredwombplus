do
local hasSetSpeed = false
local cystSpeed = 6.5

function WOMBPLUS:CystUpdate(entity)
	local data = entity:GetData()
	if data.State == nil then data.State = 0 end
	if data.HasSpeed == nil then data.HasSpeed = false end
	if data.IdleAnim == nil then data.IdleAnim = math.floor(math.random(3)+0.5) end

	local target = entity:GetPlayerTarget()

	if data.State == 0 then
		local rand = math.random(4)
		if rand == 1 then entity.Velocity = Vector(-cystSpeed, -cystSpeed)
		elseif rand == 2 then entity.Velocity = Vector(-cystSpeed, cystSpeed)
		elseif rand == 3 then entity.Velocity = Vector(cystSpeed, -cystSpeed)
		elseif rand == 4 then entity.Velocity = Vector(cystSpeed, cystSpeed) end
		data.State = 1
		entity:GetSprite():Play("Idle_" .. tostring(data.IdleAnim), true)

	elseif data.State == 1 then
		entity.Velocity = entity.Velocity:Normalized():Resized(cystSpeed):Rotated(math.random(-1, 1) * 3)

		if entity:GetSprite():IsFinished("Idle_" .. tostring(data.IdleAnim)) then
			data.State = 1
			data.IdleAnim = math.floor(math.random(3)+0.5)
			entity:GetSprite():Play("Idle_" .. tostring(data.IdleAnim), true)
		end

		if entity.Velocity.X <= entity.Velocity:Normalized().X and entity.Velocity.Y <= entity.Velocity:Normalized().Y and not data.HasSpeed then
			local rand = math.random(4)
			entity.Velocity = Vector(-cystSpeed, -cystSpeed)
			if rand == 2 then entity.Velocity = Vector(-cystSpeed, cystSpeed)
			elseif rand == 3 then entity.Velocity = Vector(cystSpeed, -cystSpeed)
			elseif rand == 4 then entity.Velocity = Vector(cystSpeed, cystSpeed) end
			data.HasSpeed = true
		end
	end
end
end