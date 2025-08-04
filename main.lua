_G.WOMBPLUS = RegisterMod("Womb+", 1)

StageAPI.UnregisterCallbacks("WombPlus") -- Unregister callbacks for luamod compat

EntityType.COMMON = 612 -- refer to entities2.xml for the constant

_G.EffectID = 1000 -- Effects are all ID 1000 for some reason
_G.variant = {}
variant.PARABRUTE = Isaac.GetEntityVariantByName("Parabrute")
variant.CYST = Isaac.GetEntityVariantByName("Cyst")
variant.SCARRED_BABY = Isaac.GetEntityVariantByName("Scarred Baby")
variant.PUSTULE = Isaac.GetEntityVariantByName("Pustule")
variant.PUSY = Isaac.GetEntityVariantByName("Pusy")
variant.OVERBOIL = Isaac.GetEntityVariantByName("Overboil")
variant.SEESPOT = Isaac.GetEntityVariantByName("Seespot")
variant.CLOTWORM = Isaac.GetEntityVariantByName("Clot Worm")
variant.SEESPOTVISUAL = Isaac.GetEntityVariantByName("Seespot Visual")
variant.NERVEENDING = Isaac.GetEntityVariantByName("Exposed Nerves")
variant.NERVEENDINGVISUAL = Isaac.GetEntityVariantByName("Exposed Nerves Visual")

WOMBPLUS.Grid = { }

WOMBPLUS.Grid.SeespotGrid = StageAPI.CustomGrid("Seespot", {
    BaseType = GridEntityType.GRID_DECORATION,
    NoOverrideGridSprite = true,
    SpawnerEntity = { Type = 612, Variant = 87 },
    Anm2 = "gfx/grid/seespot.anm2",
    Animation = "Empty"
})

WOMBPLUS.Grid.NerveEndingGrid = StageAPI.CustomGrid("ExposedNerves", {
    BaseType = GridEntityType.GRID_DECORATION,
    NoOverrideGridSprite = true,
    SpawnerEntity = { Type = 612, Variant = 89 },
    Anm2 = "gfx/grid/nerveendings.anm2",
    Animation = "Idle"
})

-- Grid
include("scripts.grid.seespot")
include("scripts.grid.nerveending")

-- Enemy
include("scripts.enemies.pusypus")
include("scripts.enemies.parabrute")
include("scripts.enemies.overboil")
include("scripts.enemies.scarredbaby")
include("scripts.enemies.cyst")
include("scripts.enemies.clotworm")

-- Misc
include("scripts.misc.roomname")

WOMBPLUS.LoadScripts = LoadScripts

function WOMBPLUS:Creep(variant, subtype, pos, parent) --Simple creep spawn function, much easier to use
    local npc = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, subtype, pos, Vector(0, 0), parent)
    npc:Update()
    return npc
end

function WOMBPLUS:ProjectileUpdate(pro)
	if pro.SpawnerType == EntityType.COMMON and pro.SpawnerVariant == variant.SCARRED_BABY then
		if pro:IsDead() then
			for i = -4, 4 do
				local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pro.Position, RandomVector() * math.random(6), pro):ToProjectile()
				proj.FallingSpeed = -6
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
	if entity.Type == EntityType.COMMON and entity.Variant == variant.CYST then
		local par = ProjectileParams()
		par.VelocityMulti = 1
		par.FallingSpeedModifier = 0
		par.FallingAccelModifier = 0
		par.HeightModifier = 0

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
	elseif entity.Type == EntityType.COMMON and entity.Variant == variant.PUSTULE then
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
	elseif entity.Variant == variant.OVERBOIL then
		WOMBPLUS:OverboilUpdate(entity)
	elseif entity.Variant == variant.CLOTWORM then
		WOMBPLUS:ClotwormUpdate(entity)
	end
end

--ENEMY UPDATES
WOMBPLUS:AddCallback(ModCallbacks.MC_NPC_UPDATE, WOMBPLUS.CheckVariantForAI, EntityType.COMMON)

function WOMBPLUS:EntityInit(entity)
	if entity.Variant == variant.PARABRUTE or entity.Variant == variant.OVERBOIL or entity.Variant == variant.CLOTWORM or entity.Variant == variant.PUSY or entity.Variant == variant.SEESPOTVISUAL or entity.Variant == variant.NERVEENDINGVISUAL then
		entity:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end

	if entity.Variant == variant.SEESPOTVISUAL or entity.Variant == variant.NERVEENDINGVISUAL then
		entity:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_NO_REMOVE_ON_TEX_RENDER)
	end
end

-- SPAWN FLAGS
WOMBPLUS:AddCallback(ModCallbacks.MC_POST_NPC_INIT, WOMBPLUS.EntityInit, EntityType.COMMON)

function string.starts(str, start)
   return string.sub(str, 1, string.len(start)) == start
end