local function CheckSeespotSteppedOn(pos, index, doExtraChecks)
    local steppedOn = false
    local players = Isaac.FindByType(EntityType.ENTITY_PLAYER, -1, -1, false, false)
    local room = Game():GetRoom()
    for _, player in ipairs(players) do
        if room:GetGridIndex(player.Position) == index or (doExtraChecks and player.Position:DistanceSquared(pos) <= (14 + player.Size) ^ 2) then
            steppedOn = true
        end
    end

    if not steppedOn and doExtraChecks then
        local ents = Isaac.FindInRadius(pos, 16, EntityPartition.ENEMY)
        for _, ent in ipairs(ents) do
            if ent.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
                steppedOn = true
                break
            end
        end
    end

    return steppedOn
end

function WOMBPLUS.SeespotAI(customGrid)
    local data = customGrid.Data
    local persistentData = customGrid.PersistentData
    local grid = customGrid.GridEntity
    local index = customGrid.GridIndex
    local room = Game():GetRoom()

    if not data.Timer then 
        data.Timer = 0
        data.SteppedOn = false
    end

    data.Timer = data.Timer - 1

    if room:GetGridPath(index) == 3000 then
        room:SetGridPath(index, 0)
    end

    grid.CollisionClass = GridCollisionClass.COLLISION_NONE

    if CheckSeespotSteppedOn(grid.Position, index, data.Timer <= 0) then 
        data.Timer = 20
    end

    if data.Timer > 5 and data.Timer < 15 then
        local offset = Vector(math.random(-16, 16), math.random(-16, 16))
        local velocity = Vector(math.random(-1600, 1600), math.random(-1600, 1600))
		local p = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, customGrid.Position + offset, Vector(0, 0) + offset * 0.004, nil):ToProjectile()
		p.Height = 0
		p.FallingSpeed = -math.random(1200, 3000) * 0.01
		p.FallingAccel = 1.5
		p.Scale = 1
    end
end

function WOMBPLUS.SeespotSpawn(customGrid)
    local persistData = customGrid.PersistentData
    local data = customGrid.Data
end

StageAPI.AddCallback("WombPlus", "POST_CUSTOM_GRID_UPDATE", 1, WOMBPLUS.SeespotAI, WOMBPLUS.Grid.SeespotGrid.Name)
StageAPI.AddCallback("WombPlus", "POST_SPAWN_CUSTOM_GRID", 1, WOMBPLUS.SeespotSpawn, WOMBPLUS.Grid.SeespotGrid.Name)
