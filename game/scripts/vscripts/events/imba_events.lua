IMBAEvents = class({})

function IMBAEvents:DeathMatchRandomOMG(npc)
	npc:SetAbilityPoints(0)
	local abilityName = {}
	for i=0, 23 do
		local ability = npc:GetAbilityByIndex(i)
		if ability then
			abilityName[#abilityName + 1] = ability:GetName()
		end
	end
	for i=1, #abilityName do
		print(abilityName[i])
		npc:RemoveAbility(abilityName[i])
	end
	local buffs = npc:FindAllModifiers()
	for i=1, #buffs do
		if string.find(buffs[i]:GetName(), "modifier_imba_talent_modifier_adder") or string.find(buffs[i]:GetName(), "modifier_imba_movespeed_controller") then
			--
		else
			print(buffs[i]:GetName())
			npc:RemoveModifierByName(buffs[i]:GetName())
		end
	end
	npc:SetAbilityPoints(npc:GetLevel())
	local normalAbility = math.min(4, npc:GetLevel())
	local ultiAbility = math.min(2, math.floor(npc:GetLevel() / 6))
	for i=1, normalAbility do
		while true do
			local abilityNameRandom = RandomFromTable(IMBA_RANDOM_ABILITIES)
			if not npc:HasAbility(abilityNameRandom) then
				print(npc:GetName(), abilityNameRandom, GameRules:GetDOTATime(true, true))
				npc:AddAbility(abilityNameRandom)
				break
			end
		end
	end
	for i=1, ultiAbility do
		while true do
			local abilityNameRandom = RandomFromTable(IMBA_RANDOM_ABILITIES_ULTI)
			if not npc:HasAbility(abilityNameRandom) then
				print(npc:GetName(), abilityNameRandom, GameRules:GetDOTATime(true, true))
				npc:AddAbility(abilityNameRandom)
				break
			end
		end
	end
	buffs = npc:FindAllModifiers()
	for i=1, #buffs do
		if string.find(buffs[i]:GetName(), "modifier_imba_talent_modifier_adder") or string.find(buffs[i]:GetName(), "modifier_imba_movespeed_controller") then
			--
		else
			npc:RemoveModifierByName(buffs[i]:GetName())
		end
	end
end

function IMBAEvents:GiveAKAbility(npc)
	if ((npc:GetAbilityByIndex(3) and npc:GetAbilityByIndex(3):GetAbilityName() == "generic_hidden") or (npc:GetAbilityByIndex(4) and npc:GetAbilityByIndex(4):GetAbilityName() == "generic_hidden")) and not npc:HasAbility("imba_ogre_magi_multicast") and not npc:HasAbility("imba_storm_spirit_ball_lightning") then
		local ak = nil
		local ak_name = GetRandomAKAbility()
		while npc:HasAbility(ak_name[2]) do
			ak_name = GetRandomAKAbility()
		end
		PrecacheUnitWithQueue(ak_name[1])
		ak = npc:AddAbility(ak_name[2])
		if ak then
			npc:SwapAbilities("generic_hidden", ak:GetAbilityName(), false, true)
			npc:AddNewModifier(npc, ak, "modifier_imba_ak_ability_controller", {})
			ak.ak = true
		end
	else
		local buff = npc:AddNewModifier(npc, nil, "modifier_imba_unlimited_powerup_ak", {})
	end
end