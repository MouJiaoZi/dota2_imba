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
	npc:RemoveAllModifiers()
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
	npc:RemoveAllModifiers()
end

function IMBAEvents:GiveAKAbility(npc)
	if npc:HasAbility("generic_hidden") and not npc:HasAbility("imba_ogre_magi_multicast") and not npc:HasAbility("imba_storm_spirit_ball_lightning") then
		GameRules:SetSafeToLeave(true)
		local ak = nil
		local ak_name = GetRandomAKAbility()
		while npc:HasAbility(ak_name[2]) do
			ak_name = GetRandomAKAbility()
		end
		PrecacheUnitByNameAsync(ak_name[1], function() npc:AddNewModifier(npc, nil, "modifier_imba_ak_ability_adder", {duration = RandomFloat(0.2, 6.0), ability_owner = ak_name[1], ability_name = ak_name[2]}) end, npc:GetPlayerOwnerID())
	else
		local buff = npc:AddNewModifier(npc, nil, "modifier_imba_unlimited_powerup_ak", {})
	end
end