IMBALevelRewards = class({})

CustomGameEventManager:RegisterListener("imbalevelrewardtest", function(...) return IMBALevelRewards:Test(...) end)

local IMBALevelRewards_steamid_64 = {}
IMBALevelRewards_steamid_64[76561198097609945] = true
IMBALevelRewards_steamid_64[76561198100269546] = true
IMBALevelRewards_steamid_64[76561198111357621] = true
IMBALevelRewards_steamid_64[76561198319625131] = true
IMBALevelRewards_steamid_64[76561198115082141] = true
IMBALevelRewards_steamid_64[76561198077798616] = true
IMBALevelRewards_steamid_64[76561198236042082] = true

function IMBALevelRewards:Test(unused, kv)
	local pID = kv.PlayerID
	local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[pID + 1]
	local chicken = CDOTA_PlayerResource.IMBA_PLAYER_COURIER[pID + 1]
	local steamid = tonumber(tostring(PlayerResource:GetSteamID(pID)))
	if hero and (IMBALevelRewards_steamid_64[steamid] or (kv.spawn and RollPercentage(5))) then
		if hero.testpfx then
			ParticleManager:DestroyParticle(hero.testpfx, true)
			hero.testpfx = nil
		else
			hero.testpfx = ParticleManager:CreateParticle("particles/imba_level_particle/ti8_hero_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
			ParticleManager:SetParticleControl(hero.testpfx, 2, Vector(1000, 0, 0))
			ParticleManager:SetParticleControl(hero.testpfx, 6, Vector(1000, 0, 0))
			ParticleManager:SetParticleControl(hero.testpfx, 15, hero.blinkcolor or Vector(PLAYER_COLORS[pID][1], PLAYER_COLORS[pID][2], PLAYER_COLORS[pID][3]))
		end
		if chicken then
			if chicken.testpfx then
			ParticleManager:DestroyParticle(chicken.testpfx, true)
			chicken.testpfx = nil
			else
				chicken.testpfx = ParticleManager:CreateParticle("particles/imba_level_particle/ti8_hero_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, chicken)
				ParticleManager:SetParticleControl(chicken.testpfx, 2, Vector(1000, 0, 0))
				ParticleManager:SetParticleControl(chicken.testpfx, 6, Vector(1000, 0, 0))
				ParticleManager:SetParticleControl(chicken.testpfx, 15, hero.blinkcolor or Vector(PLAYER_COLORS[pID][1], PLAYER_COLORS[pID][2], PLAYER_COLORS[pID][3]))
			end
		end
	end
end
