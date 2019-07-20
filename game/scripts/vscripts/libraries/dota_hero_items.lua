HeroItems = class({})

LinkLuaModifier("modifier_imba_heroitems_arcana", "libraries/dota_hero_items.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_heroitems_arcana = class({})

function modifier_imba_heroitems_arcana:IsDebuff()			return false end
function modifier_imba_heroitems_arcana:IsHidden() 			return true end
function modifier_imba_heroitems_arcana:IsPurgable() 		return false end
function modifier_imba_heroitems_arcana:IsPurgeException() 	return false end
function modifier_imba_heroitems_arcana:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_heroitems_arcana:DeclareFunctions() return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_imba_heroitems_arcana:GetActivityTranslationModifiers() return "arcana" end

Hero_Items_KV = LoadKeyValues("scripts/npc/kv/hero_items.kv")

local HeroItems_steamid_64 = {}
HeroItems_steamid_64[76561198097609945] = true
HeroItems_steamid_64[76561198100269546] = true
HeroItems_steamid_64[76561198111357621] = true
HeroItems_steamid_64[76561198319625131] = true
HeroItems_steamid_64[76561198115082141] = true
HeroItems_steamid_64[76561198077798616] = true
HeroItems_steamid_64[76561198236042082] = true
HeroItems_steamid_64[76561198049598958] = true

local hero_item_table = {}
for i=0, 23 do
	hero_item_table[i] = {}
end

function HeroItems:SetHeroItemTable(hUnit)
	local hero_name = hUnit:GetUnitName()
	local pID = hUnit:GetPlayerOwnerID()
	local items_info = Hero_Items_KV['ability_particle'][hero_name]
	if not items_info then
		return
	end
	local steamid = tonumber(tostring(PlayerResource:GetSteamID(pID)))
	if HeroItems_steamid_64[steamid] then
		for k, v in pairs(items_info) do
			if hero_item_table[pID][k] == nil then
				hero_item_table[pID][k] = true
			end
			if k == "earthshaker_arcana" then
				hUnit:SetOriginalModel("models/items/earthshaker/earthshaker_arcana/earthshaker_arcana.vmdl")
				hUnit:SetModel("models/items/earthshaker/earthshaker_arcana/earthshaker_arcana.vmdl")
				hUnit:SetSkin(1)
				local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/earthshaker_arcana/earthshaker_arcana_head.vmdl"})
				head:SetParent(hUnit, nil)
				head:FollowEntity(hUnit, true)
				head:SetSkin(1)
				local pfx = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_head_ambient_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, head)
			end
			if k == "pa_arcana" then
				hUnit:SetOriginalModel("models/heroes/phantom_assassin/pa_arcana.vmdl")
				hUnit:SetModel("models/heroes/phantom_assassin/pa_arcana.vmdl")
				local weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/phantom_assassin/pa_arcana_weapons.vmdl"})
				weapon:SetParent(hUnit, nil)
				weapon:FollowEntity(hUnit, true)
				local weapon_pfx1 = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_blade_ambient_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, hUnit)
				ParticleManager:SetParticleControlEnt(weapon_pfx1, 0, hUnit, PATTACH_POINT_FOLLOW, "attach_attack1", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(weapon_pfx1, 9, Vector(-100, 0, 0))
				ParticleManager:SetParticleControl(weapon_pfx1, 26, Vector(100, 0, 0))
				local weapon_pfx2 = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_blade_ambient_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, hUnit)
				ParticleManager:SetParticleControlEnt(weapon_pfx2, 0, hUnit, PATTACH_POINT_FOLLOW, "attach_attack2", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(weapon_pfx2, 9, Vector(-100, 0, 0))
				ParticleManager:SetParticleControl(weapon_pfx2, 26, Vector(100, 0, 0))
				local temp = hUnit:GetChildren()
				local items = {}
				for i=1, #temp do
					if temp[i]:GetClassname() == "dota_item_wearable" then
						items[#items + 1] = temp[i]:GetModelName()
					end
				end
				for i=1, #items do
					if not string.find(items[i], "weapon") and items[i] ~= "" and not string.find(items[i], "head") then
						local item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = items[i]})
						item:SetParent(hUnit, nil)
						item:FollowEntity(hUnit, true)
					end
				end
				local pfx = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_elder_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hUnit)
				ParticleManager:SetParticleControlEnt(pfx, 0, hUnit, PATTACH_POINT_FOLLOW, "attach_leg_r", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, hUnit, PATTACH_POINT_FOLLOW, "attach_leg_l", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 2, hUnit, PATTACH_POINT_FOLLOW, "attach_hand_r", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 3, hUnit, PATTACH_POINT_FOLLOW, "attach_hand_l", hUnit:GetAbsOrigin(), true)
				local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_head.vmdl"})
				head:SetParent(hUnit, nil)
				head:FollowEntity(hUnit, true)
				local pfx_head = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_head_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hUnit)
				ParticleManager:SetParticleControlEnt(pfx_head, 0, head, PATTACH_POINT_FOLLOW, "attach_tail_1", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_head, 1, head, PATTACH_POINT_FOLLOW, "attach_tail_2", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_head, 2, head, PATTACH_POINT_FOLLOW, "attach_tail_3", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_head, 3, head, PATTACH_POINT_FOLLOW, "attach_tail_4", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_head, 4, head, PATTACH_POINT_FOLLOW, "attach_tail_sml_4", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_head, 5, head, PATTACH_POINT_FOLLOW, "attach_core", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_head, 7, head, PATTACH_POINT_FOLLOW, "attach_front", hUnit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(pfx_head, 11, Vector(1000, 0, 0))
			end
			if k == "invoker_kid" then
				hUnit:SetOriginalModel("models/heroes/invoker_kid/invoker_kid.vmdl")
				hUnit:SetModel("models/heroes/invoker_kid/invoker_kid.vmdl")
				local hair = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_hair.vmdl"})
				hair:SetParent(hUnit, nil)
				hair:FollowEntity(hUnit, true)
				local cloth = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_cape.vmdl"})
				cloth:SetParent(hUnit, nil)
				cloth:FollowEntity(hUnit, true)
			end
		end
		hUnit:AddNewModifier(hUnit, nil, "modifier_imba_heroitems_arcana", {})
	else
		local temp = hUnit:GetChildren()
		local items = {}
		for i=1, #temp do
			if temp[i]:GetClassname() == "dota_item_wearable" then
				items[#items + 1] = temp[i]:GetModelName()
			end
		end
		for k, v in pairs(items_info) do
			for i=1, #items do
				if string.find(items[i], k) then
					hero_item_table[pID][k] = true
				end
			end
			if hero_item_table[pID][k] == nil then
				if IsInTable(v, items) then
					hero_item_table[pID][k] = true
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
HeroItems_ParticleAttachType['PATTACH_CENTER_FOLLOW'] = PATTACH_CENTER_FOLLOW
HeroItems_ParticleAttachType['PATTACH_CUSTOM_GAME_STATE_1'] = PATTACH_CUSTOM_GAME_STATE_1
HeroItems_ParticleAttachType['MAX_PATTACH_TYPES'] = MAX_PATTACH_TYPES

function HeroItems:ApplyWardsParticle(fGameTime)
	Timers:CreateTimer(FrameTime(), function()
			local hWard = IMBA_WARD_TABLE[fGameTime]["ward"]
			local pID = IMBA_WARD_TABLE[fGameTime]["player_id"]
			if not hWard or not pID then
				return nil
			end
			IMBAEvents:PlayerSpawnsWard(hWard)
			local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(pID))
			if not player_table['ward_pfx'] then
				return nil
			end
			local pfx_id = player_table['ward_pfx']
			if pfx_id == "0" then
				return
			end
			local buff = hWard:AddNewModifier(hWard, nil, "modifier_imba_ability_layout_contoroller", {})
			local pfx_detail = Hero_Items_KV['ward_particle'][tostring(pfx_id)]
			local pfx_name = pfx_detail['name']
			local pfx_operator = {}
			for k, v in pairs(pfx_detail) do
				if tonumber(k) then
					pfx_operator[tonumber(k)] = v
				end
			end
			local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, hWard)
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
			IMBA_WARD_TABLE[fGameTime] = nil
			return nil
		end
	)
end
