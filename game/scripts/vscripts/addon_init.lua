if IsClient() then	-- Load clientside utility lib
	require("/libraries/client_util")

	--Load ability KVs
	AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
	Hero_Items_KV = LoadKeyValues("scripts/npc/kv/hero_items.kv")
	Hero_Icons_KV = LoadKeyValues("scripts/npc/kv/hero_ability_icon.kv")
end
