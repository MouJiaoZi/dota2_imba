IMBALevelRewards = class({})

CustomGameEventManager:RegisterListener("IMBALevelReward_HeroEffect", function(...) return IMBALevelRewards:ChangeHeroEffect(...) end)
CustomGameEventManager:RegisterListener("IMBALevelReward_CourierEffect", function(...) return IMBALevelRewards:ChangeCourierEffect(...) end)
CustomGameEventManager:RegisterListener("IMBALevelReward_WardEffect", function(...) return IMBALevelRewards:ChangeWardEffect(...) end)

function IMBALevelRewards:LoadAllPlayersLevel()
	for i=0, 23 do
		if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) then
			local function SetLevel(res)
				local result = res.Body
				local player_table = {}
				for str in string.gmatch(result, "%S+") do
					player_table[#player_table + 1] = str
				end
				player_table2 = {['imba_level'] = player_table[1], ['is_vip'] = player_table[2], ['hero_pfx'] = player_table[3], ['courier_pfx'] = player_table[4], ['ward_pfx'] = player_table[5], ['maelstrom_pfx'] = player_table[6], ['shiva_pfx'] = player_table[7], ['sheep_pfx'] = player_table[8], ['radiance_pfx'] = player_table[9], ['blink_pfx'] = player_table[10]}
				CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(i), player_table2)
			end
			IMBA:SendHTTPRequest("imba_get_player_level.php", {["steamid_64"] = tostring(PlayerResource:GetSteamID(i))}, nil, SetLevel)
		end
	end
end

function IMBALevelRewards:ChangeHeroEffect(unused, kv)
	local pfxType = kv.type
	local pfxID = kv.id
	local pID = kv.PlayerID
	local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[pID + 1]
	if hero then
		local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
		player_table['hero_pfx'] = pfxID
		CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
		if pfxType == "disable" then
			if hero.imba_level_pfx then
				ParticleManager:DestroyParticle(hero.imba_level_pfx, true)
				ParticleManager:ReleaseParticleIndex(hero.imba_level_pfx)
				hero.imba_level_pfx = nil
			end
		else
			local color = HEXConvertToRGB(pfxType)
			color = Vector(color[1], color[2], color[3])
			if hero.imba_level_pfx then
				ParticleManager:SetParticleControl(hero.imba_level_pfx, 15, color)
			else
				hero.imba_level_pfx = ParticleManager:CreateParticle("particles/imba_level_particle/ti8_hero_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
				ParticleManager:SetParticleControl(hero.imba_level_pfx, 15, color)
			end
		end
	end
end

function IMBALevelRewards:ChangeCourierEffect(unused, kv)
	local pfxType = kv.type
	local pfxID = kv.id
	local pID = kv.PlayerID
	local courier = CDOTA_PlayerResource.IMBA_PLAYER_COURIER[pID + 1]
	if courier then
		local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
		player_table['courier_pfx'] = pfxID
		CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
		if pfxType == "disable" then
			if courier.imba_level_pfx then
				ParticleManager:DestroyParticle(courier.imba_level_pfx, true)
				ParticleManager:ReleaseParticleIndex(courier.imba_level_pfx)
				courier.imba_level_pfx = nil
			end
		else
			if courier.imba_level_pfx then
				ParticleManager:DestroyParticle(courier.imba_level_pfx, true)
				ParticleManager:ReleaseParticleIndex(courier.imba_level_pfx)
				courier.imba_level_pfx = ParticleManager:CreateParticle(pfxType, PATTACH_ABSORIGIN_FOLLOW, courier)
			else
				courier.imba_level_pfx = ParticleManager:CreateParticle(pfxType, PATTACH_ABSORIGIN_FOLLOW, courier)
			end
		end
	end
end

function IMBALevelRewards:ChangeWardEffect(unused, kv)
	local pfxID = kv.id
	local pID = kv.PlayerID
	local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
	player_table['ward_pfx'] = pfxID
	CustomNetTables:SetTableValue("imba_level_rewards", "player_state_"..tostring(pID), player_table)
	if pfxID == 0 then

	else

	end
end