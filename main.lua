_G.WOMBPLUS = RegisterMod("Womb+", 1)

EntityType.SCARRED_BABY = Isaac.GetEntityTypeByName("Scarred Baby")
EntityType.CYST = Isaac.GetEntityTypeByName("Cyst")
EntityType.PARABRUTE = Isaac.GetEntityTypeByName("Parabrute")
EntityType.COMMON = 612 -- refer to entities2.xml for the constant

local variant = {}
variant.PARABRUTE = Isaac.GetEntityVariantByName("Parabrute")
variant.CYST = Isaac.GetEntityVariantByName("Cyst")
variant.SCARRED_BABY = Isaac.GetEntityVariantByName("Scarred Baby")
variant.PUSTULE = Isaac.GetEntityVariantByName("Pustule")
variant.PUSY = Isaac.GetEntityVariantByName("Pusy")

local function LoadScripts(scripts)
	--load scripts
	for i,v in ipairs(scripts) do
		include(v)
	end
end

WOMBPLUS.LoadScripts = LoadScripts

local function Creep(variant, subtype, pos, parent) --Simple creep spawn function, much easier to use
    local npc = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, subtype, pos, Vector(0, 0), parent)
    npc:Update()
    return npc
end

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

local CystSpeed = 7

do
local hasSetSpeed = false

function WOMBPLUS:CystUpdate(entity)
	local data = entity:GetData()
	if data.State == nil then data.State = 0 end
	if data.HasSpeed == nil then data.HasSpeed = false end
	if data.IdleAnim == nil then data.IdleAnim = math.floor(math.random(3)+0.5) end

	local target = entity:GetPlayerTarget()

	if data.State == 0 then
		local rand = math.random(4)
		if rand == 1 then entity.Velocity = Vector(-CystSpeed, -CystSpeed)
		elseif rand == 2 then entity.Velocity = Vector(-CystSpeed, CystSpeed)
		elseif rand == 3 then entity.Velocity = Vector(CystSpeed, -CystSpeed)
		elseif rand == 4 then entity.Velocity = Vector(CystSpeed, CystSpeed) end
		data.State = 1
		entity:GetSprite():Play("Idle_" .. tostring(data.IdleAnim), true)

	elseif data.State == 1 then
		entity.Velocity = entity.Velocity:Normalized():Resized(CystSpeed):Rotated(math.random(-1, 1) * 3)

		if entity:GetSprite():IsFinished("Idle_" .. tostring(data.IdleAnim)) then
			data.State = 1
			data.IdleAnim = math.floor(math.random(3)+0.5)
			entity:GetSprite():Play("Idle_" .. tostring(data.IdleAnim), true)
		end

		if entity.Velocity.X <= entity.Velocity:Normalized().X and entity.Velocity.Y <= entity.Velocity:Normalized().Y and not data.HasSpeed then
			local rand = math.random(4)
			entity.Velocity = Vector(-CystSpeed, -CystSpeed)
			if rand == 2 then entity.Velocity = Vector(-CystSpeed, CystSpeed)
			elseif rand == 3 then entity.Velocity = Vector(CystSpeed, -CystSpeed)
			elseif rand == 4 then entity.Velocity = Vector(CystSpeed, CystSpeed) end
			data.HasSpeed = true
		end
	end
end
end

do
local stages = 0
local nextStage = 8
local toPos = Vector(0, 0)

function WOMBPLUS:ParabruteInit(entity)
    entity:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
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
			Creep(EffectVariant.CREEP_RED, 0, entity.Position, entity) 
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

			while entity.Position:Distance(targetPosition) < 120 do
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
				Creep(EffectVariant.CREEP_RED, 0, entity.Position + Vector(math.random(-60, 60), math.random(-60, 60)), entity) 
			end
		elseif entity:GetSprite():IsFinished("Splat") then
			data.State = 0
			data.StateFrame = 0
			entity:GetSprite():Play("Idle", true)
		end
	
	end
end
end

function WOMBPLUS:ProjectileUpdate(pro)
	if pro.SpawnerType == EntityType.SCARRED_BABY and pro.SpawnerVariant == variant.SCARRED_BABY then
		if pro:IsDead() then
			for i = -4, 4 do
				local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pro.Position, RandomVector() * math.random(6), pro):ToProjectile()
				proj.FallingSpeed = -10
				proj.FallingAccel = 0.5
			end
		end
	elseif pro.SpawnerType == EntityType.CYST then
		if pro and not pro:IsDead() then
			pro.Velocity = pro.Velocity * 0.97
		end
	end
end

function WOMBPLUS:NPCDeath(entity)
	if entity.Type == EntityType.COMMON and entity.Variant == variant.CYST then-- or entity.Type == EntityType.PUSTULE then
		local par = ProjectileParams()
		par.VelocityMulti = 1
		par.FallingSpeedModifier = -2
		par.FallingAccelModifier = 0
		par.HeightModifier = -10

		if entity.Type == EntityType.PUSTULE then
			par.FallingSpeedModifier = -1
			par.VelocityMulti = 1.5
			par.CurvingStrength = 0.002
		end

		for i = 0, 8 do 
			local siz = math.random(6, 10)
			local vel = RandomVector():Resized(siz)
			par.Scale = 2 - (siz * 0.1)
			entity:FireProjectiles(entity.Position, vel, 0, par) 
		end
	elseif entity.Type == EntityType.COMMON and entity.Variant == variant.PUSTULE then-- or entity.Type == EntityType.PUSTULE then
		for i = 0, 14 do 
			local par = ProjectileParams()
			par.VelocityMulti = 2
			par.FallingSpeedModifier = -20 - (math.random(0, 350) * 0.5)
			par.FallingAccelModifier = 2
			par.HeightModifier = -2
			par.CurvingStrength = 0.004
			par.Variant = 0
			par.Color = Color(1, 1, 0, 1)

			local siz = math.random(20) * 0.1
			local vel = RandomVector():Resized(siz)
			par.Scale = 2 - (siz * 0.1)
			entity:FireProjectiles(entity.Position, vel, 0, par) 
		end
	end
end

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

		if focusing and data.StateFrame % 15 == 0 then
			local pos = target.Position + Vector(math.random(-4, 4), math.random(-4, 4))
			pos = Isaac.GetFreeNearPosition(startPos, 30)
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

--RANDOM HOOKS
WOMBPLUS:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, WOMBPLUS.ProjectileUpdate)
WOMBPLUS:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, WOMBPLUS.NPCDeath)

function WOMBPLUS:CheckVariantForAI(entity)
	if entity.Variant == variant.CYST then
		WOMBPLUS:CystUpdate(entity)
	elseif entity.Variant == variant.SCARRED_BABY then
		WOMBPLUS:ScarredBabyUpdate(entity)
	elseif entity.Variant == variant.PARABRUTE then
		WOMBPLUS:ParabruteUpdate(entity)
	elseif entity.Variant == variant.PUSTULE then
		WOMBPLUS:PustuleUpdate(entity)
	elseif entity.Variant == variant.PUSY then
		WOMBPLUS:PusyUpdate(entity)
	end
end

--ENEMY UPDATES
WOMBPLUS:AddCallback(ModCallbacks.MC_NPC_UPDATE, WOMBPLUS.CheckVariantForAI, EntityType.COMMON)
