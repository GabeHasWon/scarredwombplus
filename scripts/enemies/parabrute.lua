do
local stages = 0
local nextStage = 8
local toPos = Vector(0, 0)

function WOMBPLUS:ParabruteInit(entity)
	if entity.Variant == variant.PARABRUTE then
		entity:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end
end

WOMBPLUS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, WOMBPLUS.ParabruteInit, EntityType.PARABRUTE)

function WOMBPLUS:ParabruteUpdate(entity)
	local data = entity:GetData()
	if data.State == nil then data.State = 0 end
	if data.StateFrame == nil then data.StateFrame = 0 end
	if data.HasSpeed == nil then data.HasSpeed = false end
	if data.GridCountdown == nil then data.GridCountdown = 0 end
	local target = entity:GetPlayerTarget()

	data.StateFrame = data.StateFrame + 1

	if data.State == 0 then

		data.State = 1
		data.StateFrame = 0
		entity:GetSprite():Play("Idle", true)

	elseif data.State == 1 then

		if entity:CollidesWithGrid() or data.GridCountdown > 0 then
			entity.Pathfinder:FindGridPath(target.Position, 1, 1, false)
			if data.GridCountdown <= 0 then
				data.GridCountdown = 30
			else
				data.GridCountdown = data.GridCountdown - 1
			end
		else
			entity.Velocity = (target.Position - entity.Position):Normalized():Resized(4.5)
		end

		if (math.random(3) == 2) then
			WOMBPLUS:Creep(EffectVariant.CREEP_RED, 0, entity.Position, entity) 
		end

		if entity:GetSprite():IsFinished("Idle") then
			stages = stages + 1
			data.State = 1
			data.StateFrame = 0

			if stages == nextStage then
				data.State = 2
				stages = 0
				nextStage = math.random(10, 18)
				entity:GetSprite():Play("Dig", true)
			else 	
				entity:GetSprite():Play("Idle", true)
			end
		elseif not entity:GetSprite():IsPlaying("Idle") then
			entity:GetSprite():Play("Idle", true)
		end

	elseif data.State == 2 then

		entity.Velocity = entity.Velocity * 0.7

		if not entity:GetSprite():IsPlaying("Dig") then
			entity:GetSprite():Play("Dig", true)
		end

		if entity:GetSprite():IsEventTriggered("Action") then
			local targetPosition = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 10)

			while entity.Position:Distance(targetPosition) < 160 do
				targetPosition = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 10)
			end
			
			entity.Position = targetPosition
			stages = stages + 1
			data.State = 3
			data.StateFrame = 0
			entity:GetSprite():Play("Appear", true)
		end

	elseif data.State == 3 then
		entity.Velocity = entity.Velocity * 0.7
		
		if entity:GetSprite():IsFinished("Appear") then
			data.State = 4
			data.StateFrame = 0
			entity:GetSprite():Play("Splat", true)
		end

	elseif data.State == 4 then
		if entity:GetSprite():IsEventTriggered("Action") then
			for i = 0, 18 do 
				WOMBPLUS:Creep(EffectVariant.CREEP_RED, 0, entity.Position + Vector(math.random(-60, 60), math.random(-60, 60)), entity) 
			end
		elseif entity:GetSprite():IsFinished("Splat") then
			data.State = 0
			data.StateFrame = 0
			entity:GetSprite():Play("Idle", true)
		end
	
	end
end
end