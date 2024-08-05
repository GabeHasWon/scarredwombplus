do
local focusing = false

function WOMBPLUS:PusyUpdate(entity)
	local data = entity:GetData()
	if data.State == nil then data.State = 0 end
	if data.StateFrame == nil then data.StateFrame = 0 end
	if data.StateCount == nil then data.StateCount = 0 end

	data.StateFrame = data.StateFrame + 1

	local sprite = entity:GetSprite()
	local target = entity:GetPlayerTarget()

	if data.State == 0 then
		data.State = 1
		data.StateFrame = 0
		sprite:Play("Idle", true)

	elseif data.State == 1 then
		if sprite:IsFinished("Idle") then
			data.StateCount = data.StateCount + 1

			if data.StateCount == 3 then
				data.State = 2
				sprite:Play("Focus", true)
				data.StateCount = 0
			else
				sprite:Play("Idle", true)
			end

			data.StateFrame = 0

		end

	elseif data.State == 2 then
		if sprite:IsEventTriggered("StartFocus") then
			focusing = true
		end

		if sprite:IsEventTriggered("EndFocus") then
			focusing = false
		end

		if focusing and data.StateFrame % 40 == 0 then
			local pos = target.Position + Vector(math.random(-4, 4), math.random(-4, 4))
			-- pos = Isaac:GetFreeNearPosition(startPos, 30)
			local pustule = Isaac.Spawn(EntityType.COMMON, variant.PUSTULE, 0, pos, Vector.Zero, entity) -- Spawn pustule near player

			pustule:GetData().waitTime = 5
			pustule:GetSprite():Play("Empty", true)
			pustule.CollisionDamage = 0
			pustule.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pustule:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		end

		if sprite:IsFinished("Focus") then
			data.State = 1
			data.StateFrame = 0
			data.StateCount = math.random(-3, 0)
			sprite:Play("Idle", true)
		end

	end

end
end

function WOMBPLUS:PustuleUpdate(entity)
	local data = entity:GetData()
	local sprite = entity:GetSprite()
	local target = entity:GetPlayerTarget()

	if data.timer == nil then 
		data.timer = 0 
	end

	data.timer = data.timer + 1

	if data.waitTime ~= nil and data.waitTime > 0 then
		data.waitTime = data.waitTime - 1

		if data.waitTime == 0 then
			sprite:Play("Emerge", true)
		end	

	else
		if data.waitTime ~= nil and data.waitTime == 0 and sprite:IsFinished("Emerge") then
			data.waitTime = -1
			entity.CollisionDamage = 1
			entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			sprite:Play("Idle", true)

		elseif sprite:IsFinished("Idle") then
			sprite:Play("Idle", true)
		end

		if (not sprite:IsPlaying("Emerge")) and target.Position:Distance(entity.Position) < 80 and data.timer > 20 then
			entity:Kill()
		end

	end

end