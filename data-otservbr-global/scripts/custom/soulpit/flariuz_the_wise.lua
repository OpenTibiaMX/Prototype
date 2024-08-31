local internalNpcName = "Flariuz The Wise"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}
local soulpitCost = 5000
local storageKey = 345541

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
    lookType = 130,  -- Ajusta estos valores según tu preferencia
    lookHead = 57,
    lookBody = 116,
    lookLegs = 97,
    lookFeet = 114,
    lookAddons = 0,
}

npcConfig.flags = {
    floorchange = false,
}
npcConfig.shop = {
    { itemName = "basket", clientId = 2855, buy = 6 },
    { itemName = "bottle", clientId = 2875, sell = 3 },
}

-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
    npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
    player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end

-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
    npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
    npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
    npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
    npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
    npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
    npcHandler:onCloseChannel(npc, creature)
end

local function creatureSayCallback(npc, creature, type, message)
    local player = Player(creature)

    if not npcHandler:checkInteraction(npc, creature) then
        return false
    end

    if message:lower():find("soulpit") then
        npcHandler:say({
            "Welcome to the Soulpit! Here you can face various challenges, each with its own series of waves of enemies.",
            "The Soulpit types include 'Bloated Man-Maggot', 'Converter', 'Darklight Construct', and many more. Each type has five waves of enemies.",
            "To participate, you must be in the designated area. If the Soulpit is not currently active and you are in the correct position, you can start it.",
            "To begin the Soulpit, you need a 'Soul Core' from a creature. Use it at the starting tower, and the Soulpit will commence with waves of enemies.",
            "Completing the Soulpit will reward you with a confirmation message and a permanent experience boost of 3% for the event's monster type.",
            "During each wave, enemies will spawn randomly within the area. Once all waves are completed, the event will restart automatically for new participants.",
            "If you want to {start} the Soulpit."
        }, npc, creature)
    elseif message:lower():find("start") then
        npcHandler:say("Access to the Soulpit costs 5,000 gold coins. Are you still interested?", npc, creature)
    elseif message:lower():find("yes") then
        local storageValue = player:getStorageValue(storageKey)

        if storageValue == 1 then
            npcHandler:say("You already have access to the Soulpit.", npc, creature)
        elseif player:getBankBalance() >= soulpitCost then
            player:removeMoneyBank(soulpitCost)
            player:setStorageValue(storageKey, 1)
            npcHandler:say("Congratulations, now you can access the Soulpit!", npc, creature)
        else
            npcHandler:say("Sorry, you do not have enough gold to start the Soulpit.", npc, creature)
        end
    end

    return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, |PLAYERNAME|! I am Flariuz The Wise. Ask me about the {soulpit} for more information.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
