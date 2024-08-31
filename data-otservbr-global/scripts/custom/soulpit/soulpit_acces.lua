local config = {
    { x = 32375, y = 31163, z = 8 },
    { x = 32375, y = 31164, z = 8 },
    { x = 32375, y = 31165, z = 8 },
    { x = 32375, y = 31166, z = 8 },
    { x = 32375, y = 31167, z = 8 },
}

local requiredStorage = 345541

local accessTile = MoveEvent()

function accessTile.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()

    if not player then
        return false
    end

    for _, pos in ipairs(config) do
        if Position(pos) == player:getPosition() then
            if player:getStorageValue(requiredStorage) ~= -1 then
                return true
            end
            
            player:teleportTo(fromPosition)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need to have access to do Soulpit talk to Flariuz The Wise to request access.")
            
            return true
        end
    end
end

for _, pos in ipairs(config) do
    accessTile:position(pos)
end

accessTile:register()
