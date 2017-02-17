local autoSuicide = {}

autoSuicide.optionEnabled = Menu.AddOption({"Utility","Auto Suicide"},"Enable", "on/off")
autoSuicide.optionEnabledSR = Menu.AddOption({"Utility","Auto Suicide"},"Use Soul Ring?", "on/off")

function autoSuicide.OnUpdate()
	if not Menu.IsEnabled(autoSuicide.optionEnabled) then return end
	local myHero = Heroes.GetLocal()
	if myHero == nil then return end
	local myMana = NPC.GetMana(myHero)
	local myHp = Entity.GetHealth(myHero)
	if myHp <= 0 then return end
	
	if NPC.GetUnitName(myHero) == "npc_dota_hero_abaddon" then
		local suicide_skill = NPC.GetAbilityByIndex(myHero, 0)
		local soul_ring = NPC.GetItem(myHero, "item_soul_ring", true)
		if suicide_skill == nil then return end
		local suicide_range = 800
		local unitsEnemyAround = NPC.GetUnitsInRadius(myHero, suicide_range, Enum.TeamType.TEAM_ENEMY)
		local heroEnemyAround = NPC.GetHeroesInRadius(myHero, 1400, Enum.TeamType.TEAM_ENEMY)
		if heroEnemyAround == nil then return end
		if unitsEnemyAround == nil then return end
		local self_damage = Ability.GetLevelSpecialValueFor(suicide_skill, "self_damage")
		local suicide = false
		if Ability.IsCastable(suicide_skill, myMana) and myHp <= self_damage then
			for key,value in ipairs(NPC.GetModifiers(myHero)) do
				if Modifier.GetName(value) ~= "modifier_abaddon_aphotic_shield" or Modifier.GetName(value) ~= "modifier_abaddon_borrowed_time" then
					for number, enemy in ipairs(unitsEnemyAround) do
						if not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and suicide == false then
							Ability.CastTarget(suicide_skill, enemy, true)
							suicide = true
						end
					end
				end
			end
		end
	end
	if NPC.GetUnitName(myHero) == "npc_dota_hero_pudge" then
		local suicide_skill = NPC.GetAbilityByIndex(myHero, 1)
		local soul_ring = NPC.GetItem(myHero, "item_soul_ring", true)
		if suicide_skill == nil then return end
		local self_damage = Ability.GetLevelSpecialValueFor(suicide_skill, "rot_damage") - Ability.GetLevelSpecialValueFor(suicide_skill, "rot_damage") * NPC.GetMagicalArmorValue(myHero)
		if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return end
		if Menu.IsEnabled(autoSuicide.optionEnabledSR) and soul_ring ~= nil then
			if Ability.IsCastable(soul_ring, myMana) then
				if myHp <= self_damage + 149 then
					Ability.CastNoTarget(soul_ring, true)
				end
			end
		end
		if myHp <= self_damage then
			Ability.CastNoTarget(suicide_skill, true)
		end
	end
end

return autoSuicide