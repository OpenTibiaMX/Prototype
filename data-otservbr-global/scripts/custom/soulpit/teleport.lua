local soulpitEntrance = MoveEvent()

function soulpitEntrance.onStepIn(player, item, position, fromPosition)
	if player:isPlayer() then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		local newPosition = Position(32376, 31172, 8)
		player:teleportTo(newPosition)
		newPosition:sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

soulpitEntrance:type("stepin")
soulpitEntrance:aid(5896)
soulpitEntrance:register()