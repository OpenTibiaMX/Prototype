local config = {
    itemIdLevel = 47367,
    minLevel = 100, -- Nivel mínimo requerido para participar
    maxLevelDifference = 5000, -- Diferencia máxima de nivel permitida entre los jugadores
    playerPositions = {
        Position(32375, 31163, 8), -- Player 1
        Position(32375, 31164, 8),
        Position(32375, 31165, 8),
        Position(32375, 31166, 8),
        Position(32375, 31167, 8)
    },
    arenas = {
        {
            enterPos = Position(32376, 31148, 8),
            centerArena = Position(32376, 31141, 8),
            fromPos = Position(32370, 31135, 8),
            toPos = Position(32382, 31147, 8)
        },
        {
            enterPos = Position(32413, 31148, 8),
            centerArena = Position(32413, 31141, 8),
            fromPos = Position(32407, 31135, 8),
            toPos = Position(32419, 31147, 8)
        },
        {
            enterPos = Position(32339, 31148, 8),
            centerArena = Position(32339, 31141, 8),
            fromPos = Position(32333, 31135, 8),
            toPos = Position(32345, 31147, 8)
        }
    },
    waves = {
        {levelRange = {1, 5}, delay = 5000}, -- Wave 1: max level random 1-5
        {levelRange = {1, 10}, delay = 5000}, -- Wave 2: max level random 1-10
        {levelRange = {1, 15}, delay = 5000}, -- Wave 3: max level random 1-15
        {levelRange = {1, 20}, delay = 5000}, -- Wave 4: max level random 1-20
        {levelRange = {1, 25}, delay = 5000} -- Final Boss max level random 1-25
    },
    monstersPerWave = {min = 5, max = 8}
}

local soulpitLever = Action()

local function isArenaClear(arena)
    print("Checking arena for monsters...")
    for x = arena.fromPos.x, arena.toPos.x do
        for y = arena.fromPos.y, arena.toPos.y do
            local tile = Tile(Position(x, y, arena.fromPos.z))
            if tile then
                local creatures = tile:getCreatures() or {}
                for _, creature in ipairs(creatures) do
                    print("Detected creature:", creature:getName(), "at position:", x, y)
                    if creature:isMonster() then
                        print("Found a monster:", creature:getName(), "at position:", x, y)
                        return false
                    end
                end
            else
                print("No tile found at position:", x, y)
            end
        end
    end
    print("No monsters found in the arena.")
    return true
end




-- Función para invocar una oleada
local function summonWave(arena, monsterName, waveConfig, waveIndex)
    local monstersRemaining = math.random(config.monstersPerWave.min, config.monstersPerWave.max)
    local levelRange = waveConfig.levelRange
    local randomLevel = math.random(levelRange[1], levelRange[2])

    for i = 1, monstersRemaining do
        local spawnPos = Position(
            math.random(arena.fromPos.x, arena.toPos.x),
            math.random(arena.fromPos.y, arena.toPos.y),
            arena.fromPos.z
        )

        local monster = Game.createMonster(monsterName, spawnPos)
        if monster then
            monster:setName(monsterName .. " Lvl " .. randomLevel)
        end
    end
end

-- Función para invocar el boss final
local function summonFinalBoss(arena, monsterName)
    local boss = Game.createMonster(monsterName, arena.centerArena)
    if boss then
        boss:setName("Boss " .. monsterName)
    end
end

local function handleWaves(arena, monsterName, waveIndex)
    -- Verificar si ya se han terminado todas las oleadas
    if waveIndex > #config.waves then
        Game.sendAnimatedText("Arena Cleared!", arena.centerArena, TEXTCOLOR_GREEN)
        return
    end

    -- Verificar si la arena está vacía antes de iniciar la siguiente oleada
    if isArenaClear(arena) then
        -- Mostrar contador de 30 segundos antes de la próxima oleada
        local countdown = 5
        local function countdownFunc()
            if countdown > 0 then
                Game.sendAnimatedText("Next Wave in: " .. countdown, arena.centerArena, TEXTCOLOR_RED)
                countdown = countdown - 1
                addEvent(countdownFunc, 1000)
            else
                -- Iniciar la siguiente oleada
                if waveIndex == #config.waves then
                    -- Invocar el Boss final
                    summonFinalBoss(arena, monsterName)
                else
                    -- Invocar la oleada regular
                    local waveConfig = config.waves[waveIndex]
                    summonWave(arena, monsterName, waveConfig, waveIndex)
                end

                -- Configurar la siguiente verificación de oleada
                addEvent(handleWaves, 1000, arena, monsterName, waveIndex + 1)
            end
        end
        countdownFunc()
    else
        -- Si la arena no está vacía, revisar de nuevo en 1 segundo
        addEvent(function() handleWaves(arena, monsterName, waveIndex) end, 1000)
    end
end


-- Función para verificar si el item se usó en un "Soul Core"
local function isUsingOnSoulCore(target)
    local itemName = getItemName(target.itemid)
    local monsterName = itemName:gsub("[Ss][Oo][Uu][Ll] [Cc][Oo][Rr][Ee]", ""):trim():lower()

    if itemName:lower():find("soul core") == nil then
        return false, nil
    end

    return true, monsterName
end

-- Función para verificar si un jugador está en la posición correcta
local function isPlayerInFirstPosition(player)
    return player:getPosition() == config.playerPositions[1]
end

-- Función para verificar si todos los jugadores cumplen con los requisitos de nivel
local function validatePlayerLevels(players)
    local minLevel, maxLevel = players[1]:getLevel(), players[1]:getLevel()

    for _, player in ipairs(players) do
        if player:getLevel() < config.minLevel then
            return false, "All players must be at least level " .. config.minLevel .. " to enter the arena."
        end

        minLevel = math.min(minLevel, player:getLevel())
        maxLevel = math.max(maxLevel, player:getLevel())
    end

    if (maxLevel - minLevel) > config.maxLevelDifference then
        return false, "The level difference between players cannot exceed " .. config.maxLevelDifference .. "."
    end

    return true, nil
end

-- Función para obtener la lista de jugadores en las posiciones especificadas
local function getPlayersInPositions()
    local players = {}

    for _, pos in ipairs(config.playerPositions) do
        local tile = Tile(pos)
        if tile then
            local creature = tile:getTopCreature()
            if creature and creature:isPlayer() then
                table.insert(players, creature)
            end
        end
    end

    return players
end

local function mobIsValidSoulpit(monsterName)
    local monsterType = MonsterType(monsterName)
    if not monsterType then
        print("MonsterType not found for: " .. monsterName)
        return false
    end
    return true
end

local function isSoulpitArenaOccupied(fromPos, toPos)
    local spectators = Game.getSpectators(Position(fromPos), false, false, 20, 20, 20, 20)
    for _, spec in ipairs(spectators) do
        if spec:isPlayer() then
            return true
        end
    end
    return false
end

local function sendPlayersToSoulpitArena(players, arenaConfig)
    for _, player in ipairs(players) do
        player:teleportTo(arenaConfig.enterPos)
        player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    end
    players[1]:sendTextMessage(MESSAGE_INFO_DESCR, "You and your team have been sent to the arena.")
end

-- Función principal de uso del lever
function soulpitLever.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Verificar si el item se usó en un "Soul Core"
    local isSoulCore, monsterName = isUsingOnSoulCore(target)
    if not isSoulCore then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "This item can only be used on a Soul Core.")
        return false
    end

    -- Verificar si el nombre del monstruo es válido
    if not mobIsValidSoulpit(monsterName) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Invalid monster name: " .. monsterName .. ". Please use a valid monster name.")
        return false
    end

    -- Verificar si el jugador está en la primera posición
    if not isPlayerInFirstPosition(player) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You must be in the first position to start the arena challenge.")
        return false
    end

    -- Obtener y validar a los jugadores en las posiciones especificadas
    local players = getPlayersInPositions()
    local isValid, errorMsg = validatePlayerLevels(players)
    if not isValid then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, errorMsg)
        return false
    end

    -- Verificar disponibilidad de las arenas y enviar a los jugadores
    for _, arena in ipairs(config.arenas) do
        if not isSoulpitArenaOccupied(arena.fromPos, arena.toPos) then
            sendPlayersToSoulpitArena(players, arena)

            -- Iniciar la primera wave
            Game.sendAnimatedText("Wave 1 starts in 30 seconds", arena.centerArena, TEXTCOLOR_RED)
            addEvent(handleWaves, 3000, arena, monsterName, 1)
            return true
        end
    end

    player:sendTextMessage(MESSAGE_INFO_DESCR, "All arenas are currently occupied.")
    return true
end

soulpitLever:id(config.itemIdLevel)
soulpitLever:register()
