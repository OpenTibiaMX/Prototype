local config = {
    -- Eliminar la moneda, ya que no se requiere
    -- currency = 60018,  -- Currency item ID

    -- La clave es el ID del item recargable y el valor tiene los detalles del costo.
    rechargeables = {
        [48079] = {cost = 1},
        [48069] = {cost = 1},
        [48068] = {cost = 1},
        [48072] = {cost = 1},
        [48070] = {cost = 1},
        [48085] = {cost = 1},
        [48086] = {cost = 1},
        [48066] = {cost = 1},
        [48065] = {cost = 1},
        [48067] = {cost = 1},
        [48071] = {cost = 1},
        [48080] = {cost = 1},
        [48083] = {cost = 1},
        [48084] = {cost = 1},
        [48081] = {cost = 1},
        [48082] = {cost = 1},
        [47952] = {cost = 1},
        [47956] = {cost = 1},
        [47957] = {cost = 1},
        [47958] = {cost = 1},
        [47954] = {cost = 1},
        [47964] = {cost = 1},
        [47973] = {cost = 1},
        [47966] = {cost = 1},
        [47961] = {cost = 1},
        [47959] = {cost = 1},
        [47967] = {cost = 1},
        [47965] = {cost = 1},
        [47968] = {cost = 1},
        [47962] = {cost = 1},
        [47969] = {cost = 1},
        [47963] = {cost = 1},
        [47953] = {cost = 1},
        [47955] = {cost = 1}
    }
}

-- Lista de IDs de items aleatorios
local itemList = {
    48079, 48069, 48068, 48072, 48070, 48085, 48086, 48066, 48065, 48067,
    48071, 48080, 48083, 48084, 48081, 48082, 47952, 47956, 47957, 47958,
    47954, 47964, 47973, 47966, 47961, 47959, 47967, 47965, 47968,
    47962, 47969, 47963, 47953, 47955
}

-- Función para seleccionar un item aleatorio de la lista
local function getRandomItem()
    return itemList[math.random(#itemList)]
end

local function rechargeExerciseWeapon(player, itemId)
    local info = config.rechargeables[itemId]
    if not info then
        return false
    end

    -- Eliminar verificación de moneda
    -- if player:getItemCount(config.currency) < info.cost then
    --     player:sendCancelMessage("You need " .. info.cost .. " " .. ItemType(config.currency):getPluralName():lower() .. " to repair this item.")
    --     player:getPosition():sendMagicEffect(CONST_ME_POFF)
    --     return false
    -- end

    -- Eliminar el ítem sin costo
    -- player:removeItem(config.currency, info.cost)
    player:removeItem(itemId, 1)
    local newItem = getRandomItem()
    player:addItem(newItem, 1)
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your item has been replaced with a new item.")
    return true
end

local rechargingAction = Action()

function rechargingAction.onUse(player, item)
    local menu = ModalWindow{
        title = "Soul Core System",
        message = "Select the soul core you want to change"
    }

    local found = false

    for i, info in pairs(config.rechargeables) do
        if player:getItemCount(i) > 0 then
            found = true
            menu:addChoice(string.format("%s", ItemType(i):getName()), function (player, button, choice)
                if button.name ~= "Change" then
                    return
                end

                rechargeExerciseWeapon(player, i)
            end)
        end
    end

    menu:addButton("Change")
    menu:addButton("Close")

    if not found then
        player:sendCancelMessage("You do not have any items to replace.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    menu:sendToPlayer(player)
    return true
end

rechargingAction:aid(47368) -- Actualiza el Action ID si es necesario
rechargingAction:register()
