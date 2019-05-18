HeroItems = class({})

Hero_Items_KV = LoadKeyValues("scripts/npc/kv/hero_items.kv")

local HeroItems_steamid_64 = {}
HeroItems_steamid_64[76561198097609945] = true
HeroItems_steamid_64[76561198100269546] = true
HeroItems_steamid_64[76561198111357621] = true
HeroItems_steamid_64[76561198319625131] = true
HeroItems_steamid_64[76561198115082141] = true
HeroItems_steamid_64[76561198077798616] = true
HeroItems_steamid_64[76561198236042082] = true

local hero_item_table = {}
for i=0, 23 do
	hero_item_table[i] = {}
end

function HeroItems:SetHeroItemTable(hUnit)
	local hero_name = hUnit:GetUnitName()
	local pID = hUnit:GetPlayerOwnerID()
	local items_info = Hero_Items_KV[hero_name]
	if not items_info then
		return
	end
	local steamid = tonumber(tostring(PlayerResource:GetSteamID(pID)))
	if HeroItems_steamid_64[steamid] then
		for k, v in pairs(items_info) do
			if hero_item_table[pID][k] == nil then
				hero_item_table[pID][k] = true
			end
		end
	else
		local temp = hUnit:GetChildren()
		local items = {}
		for i=1, #temp do
			if temp[i]:GetClassname() == "dota_item_wearable" then
				items[#items + 1] = temp[i]:GetModelName()
			end
		end
		for k, v in pairs(items_info) do
			if hero_item_table[pID][k] == nil then
				if IsInTable(v, items) then
					hero_item_table[pID][k] = true
				else
					hero_item_table[pID][k] = false
				end
			end
		end
	end
end

function HeroItems:UnitHasItem(hUnit, sItemKeyword)
	return hero_item_table[hUnit:GetPlayerOwnerID()][sItemKeyword]
end

local HeroItems_ParticleAttachType = {}
HeroItems_ParticleAttachType['PATTACH_INVALID'] = PATTACH_INVALID
HeroItems_ParticleAttachType['PATTACH_ABSORIGIN'] = PATTACH_ABSORIGIN
HeroItems_ParticleAttachType['PATTACH_ABSORIGIN_FOLLOW'] = PATTACH_ABSORIGIN_FOLLOW
HeroItems_ParticleAttachType['PATTACH_CUSTOMORIGIN'] = PATTACH_CUSTOMORIGIN
HeroItems_ParticleAttachType['PATTACH_CUSTOMORIGIN_FOLLOW'] = PATTACH_CUSTOMORIGIN_FOLLOW
HeroItems_ParticleAttachType['PATTACH_POINT'] = PATTACH_POINT
HeroItems_ParticleAttachType['PATTACH_POINT_FOLLOW'] = PATTACH_POINT_FOLLOW
HeroItems_ParticleAttachType['PATTACH_EYES_FOLLOW'] = PATTACH_EYES_FOLLOW
HeroItems_ParticleAttachType['PATTACH_OVERHEAD_FOLLOW'] = PATTACH_OVERHEAD_FOLLOW
HeroItems_ParticleAttachType['PATTACH_WORLDORIGIN'] = PATTACH_WORLDORIGIN
HeroItems_ParticleAttachType['PATTACH_ROOTBONE_FOLLOW'] = PATTACH_ROOTBONE_FOLLOW
HeroItems_ParticleAttachType['PATTACH_RENDERORIGIN_FOLLOW'] = PATTACH_RENDERORIGIN_FOLLOW
HeroItems_ParticleAttachType['PATTACH_MAIN_VIEW'] = PATTACH_MAIN_VIEW
HeroItems_ParticleAttachType['PATTACH_WATERWAKE'] = PATTACH_WATERWAKE
HeroItems_ParticleAttachType['MAX_PATTACH_TYPES'] = MAX_PATTACH_TYPES

local HeroItems_WardParticle = {}
HeroItems_WardParticle[76561198097609945] = "particles/econ/courier/courier_trail_spirit/courier_trail_spirit.vpcf"

function HeroItems:ApplyWardsParticle(fGameTime)
	Timers:CreateTimer(FrameTime(), function()
			local hWard = IMBA_WARD_TABLE[fGameTime]["ward"]
			local pID = IMBA_WARD_TABLE[fGameTime]["player_id"]
			if not hWard or not pID then
				return nil
			end
			local steamid = tonumber(tostring(PlayerResource:GetSteamID(pID)))
			if not HeroItems_WardParticle[steamid] then
				return nil
			end
			local buff = hWard:AddNewModifier(hWard, nil, "modifier_imba_ability_layout_contoroller", {})
			local pfx_name = HeroItems_WardParticle[steamid]
			local pfx_operator = Hero_Items_KV['ward_particle'][pfx_name]
			local pfx = ParticleManager:CreateParticle(HeroItems_WardParticle[steamid], PATTACH_ABSORIGIN_FOLLOW, hWard)
			if pfx_operator then
				local operator = {}
				for cp, op in pairs(pfx_operator) do
					operator[tonumber(cp)] = {}
					for str in string.gmatch(op, "%S+") do
						operator[tonumber(cp)][#operator[tonumber(cp)] + 1] = str
					end
				end
				for cp, op in pairs(operator) do
					ParticleManager:SetParticleControlEnt(pfx, cp, hWard, HeroItems_ParticleAttachType[ op[1] ], op[2], hWard:GetAbsOrigin(), true)
				end
			end
			buff:AddParticle(pfx, true, false, 15, false, false)
			return nil
		end
	)
end