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