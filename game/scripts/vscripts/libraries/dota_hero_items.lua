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
