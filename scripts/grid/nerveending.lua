local function CheckNervesSteppedOn(pos, index, doExtraChecks)
    local steppedOn = false
    local smushed = false
    local players = Isaac.FindByType(EntityType.ENTITY_PLAYER, -1, -1, false, false)
    local room = Game():GetRoom()

    for _, player in ipairs(players) do
        local canFly = player:ToPlayer().CanFly
        if (room:GetGridIndex(player.Position) == index or (doExtraChecks and player.Position:DistanceSquared(pos) <= (14 + player.Size) ^ 2)) then
            if canFly then
                steppedOn = true
            else 
                smushed = true
            end
        end
    end

    if not steppedOn and doExtraChecks then
        local ents = Isaac.FindInRadius(pos, 16, EntityPartition.ENEMY)
        for _, ent in ipairs(ents) do
            if ent.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then
                steppedOn = true
                break
            end
        end
    end

    local stepType = 0

    if smushed then
        stepType = 2
    elseif steppedOn then
        stepType = 1
    end

    return stepType
end

function WOMBPLUS.NerveEndingAI(customGrid)
    local data = customGrid.Data
    local persistentData = customGrid.PersistentData
    local grid = customGrid.GridEntity
    local index = customGrid.GridIndex
    local room = Game():GetRoom()
    local sprite = customGrid.PersistentData.Effect:GetSprite()

    if not data.Timer then 
        data.Timer = 0
        data.StepType = false
    end

    if not customGrid.PersistentData.Effect then
        customGrid.PersistentData.Effect = Isaac.Spawn(EffectID, variant.NERVEENDINGVISUAL, 0, customGrid.Position, Vector.Zero, nil)
    end

    data.Timer = data.Timer - 1

    if room:GetGridPath(index) == 3000 then
        room:SetGridPath(index, 0)
    end

    grid.CollisionClass = GridCollisionClass.COLLISION_NONE

    local stepType = CheckNervesSteppedOn(grid.Position, index, data.Timer <= 0)
    
    if stepType ~= 0 or data.Timer <= 0 then
        data.StepType = stepType
    end

    if stepType == 1 or stepType == 2 then 
        data.Timer = 20
    end

    if data.Timer > 0 and stepType == 0 and data.StepType ~= 2 then
        if not sprite:IsPlaying("Shooting") then
            sprite:Play("Shooting", true)
        end   

    else
        if data.StepType ~= 2 then
            if not sprite:IsPlaying("Up") then
                sprite:Play("Up", true)
            end

        else 
            if not sprite:IsPlaying("Down") then
                sprite:Play("Down", true)
            end

        end

    end

    if data.Timer > 5 and data.Timer < 18 and data.Timer % 3 == 0 and data.StepType ~= 2 then
        local offset = Vector(math.random(-16, 16), math.random(-16, 16))
        local velocity = Vector(math.random(-1600, 1600), math.random(-1600, 1600))
		local p = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, customGrid.Position + offset, Vector(0, 0) + offset * 0.004, nil):ToProjectile()
		p.Height = 0
		p.FallingSpeed = -math.random(1200, 3000) * 0.01
		p.FallingAccel = 1.5
		p.Scale = 0.7
    end
end

function WOMBPLUS.NerveEndingSpawn(customGrid)
    local persistData = customGrid.PersistentData
    local data = customGrid.Data
    persistData.Effect = Isaac.Spawn(EffectID, variant.NERVEENDINGVISUAL, 0, customGrid.Position, Vector.Zero, nil)
end

StageAPI.AddCallback("WombPlus", "POST_CUSTOM_GRID_UPDATE", 1, WOMBPLUS.NerveEndingAI, WOMBPLUS.Grid.NerveEndingGrid.Name)
StageAPI.AddCallback("WombPlus", "POST_SPAWN_CUSTOM_GRID", 1, WOMBPLUS.NerveEndingSpawn, WOMBPLUS.Grid.NerveEndingGrid.Name)

function WOMBPLUS:NerveEndingVisualUpdate(entity)
    local data = entity:GetData()

    if not data.Init then
        data.Init = true
        entity.DepthOffset = -1000
        entity:GetSprite():Play("Up", true)
    end
end

WOMBPLUS:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WOMBPLUS.NerveEndingVisualUpdate, variant.NERVEENDINGVISUAL)
