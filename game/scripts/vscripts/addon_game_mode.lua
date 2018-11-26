
if _G.STOP == nil then
	_G.STOP = false
end

if _G.STOP == false then
	_G.STOP = true
else
	return
end

-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')
require('addon_init')
require("statcollection/init")

function Precache( context )
--[[
	This function is used to precache resources/units/items/abilities that will be needed
	for sure in your game and that will not be precached by hero selection.   When a hero
	is selected from the hero selection screen, the game will precache that hero's assets,
	any equipped cosmetics, and perform the data-driven precaching defined in that hero's
	precache{} block, as well as the precache{} block for any equipped abilities.

	See GameMode:PostLoadPrecache() in gamemode.lua for more information
	]]

	DebugPrint("[BAREBONES] Performing pre-load precache")

	-- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
	-- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
	--[[PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
	PrecacheUnitByNameSync("npc_dota_hero_enigma", context)]]

	-- Common Modifier
	LinkLuaModifier("modifier_multicast_attack_range", "hero/hero_ogre_magi", LUA_MODIFIER_MOTION_NONE) -- don't miss for to far
	LinkLuaModifier("modifier_imba_talent_modifier_adder", "modifier/modifier_imba_talent_modifier_adder", LUA_MODIFIER_MOTION_NONE)
	PrecacheResource("particle", "particles/basic_ambient/generic_confuse.vpcf", context)
	LinkLuaModifier("modifier_confuse", "modifier/modifier_confuse.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_imba_unlimited_level_powerup", "modifier/modifier_imba_unlimited_level_powerup.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_dummy_thinker", "modifier/modifier_dummy_thinker.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_imba_base_protect", "modifier/modifier_dummy_thinker.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_imba_stunned", "modifier/modifier_imba_stunned.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_imba_bashed", "modifier/modifier_imba_stunned.lua", LUA_MODIFIER_MOTION_NONE )
	PrecacheResource("particle", "particles/basic_ambient/generic_paralyzed.vpcf", context)
	LinkLuaModifier("modifier_paralyzed", "modifier/modifier_paralyzed.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_imba_courier_marker", "modifier/modifier_imba_courier_marker.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_imba_courier_prevent", "modifier/modifier_imba_courier_marker.lua", LUA_MODIFIER_MOTION_NONE )

	-- Items
	PrecacheResource("particle", "particles/econ/items/effigies/status_fx_effigies/gold_effigy_ambient_dire_lvl2.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_mirana.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ember_spirit.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/imba_soundevents.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/imba_item_soundevents.vsndevts", context)

	-- Roshan
	PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf", context)
	PrecacheResource("particle", "particles/neutral_fx/roshan_slam.vpcf", context)

	-- Fountain
	PrecacheResource("particle", "particles/units/heroes/hero_ursa/ursa_fury_swipes.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", context)
	PrecacheResource("particle", "particles/ambient/fountain_danger_circle.vpcf", context)

	-- Towers
	PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_base_attack.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_centaur/centaur_return.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_pudge/pudge_rot_radius.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_livingarmor.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ui.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_nyx_assassin.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context)

	-- Ancients
	PrecacheResource("particle", "particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_overgrowth_cast.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace_hit.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_nyx_assassin.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_beserkers_call.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tidehunter.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", context)

	-- Stuff
	PrecacheResource("particle_folder", "particles/hero", context)
	PrecacheResource("particle_folder", "particles/ambient", context)
	PrecacheResource("particle_folder", "particles/generic_gameplay", context)
	PrecacheResource("particle_folder", "particles/status_fx/", context)
	PrecacheResource("particle_folder", "particles/item", context)
	PrecacheResource("particle_folder", "particles/items_fx", context)
	PrecacheResource("particle_folder", "particles/items2_fx", context)
	PrecacheResource("particle_folder", "particles/items3_fx", context)
	PrecacheResource("particle_folder", "particles/creeps/lane_creeps/", context)
	PrecacheResource("particle_folder", "particles/customgames/capturepoints/", context)
	PrecacheResource("particle", "particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", context)

	-- Models can also be precached by folder or individually
	PrecacheResource("model_folder", "models/development", context)
	PrecacheResource("model_folder", "models/creeps", context)
	PrecacheResource("model_folder", "models/props_gameplay", context)

  	-- Sounds can precached here like anything else
  	PrecacheResource("soundfile", "sounds/weapons/creep/roshan/slam.vsnd", context)
  	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_items.vsndevts", context)
  	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
  	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_lancer.vsndevts", context)
  	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context)
  	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context)
  	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_roshan_halloween.vsndevts", context)

  	-- IMBA Runes
	LinkLuaModifier("modifier_imba_rune_doubledamage", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_doubledamage_ally", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_haste", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_haste_ally", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_invisibility", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_regeneration", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_regeneration_ally", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_arcane", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_arcane_ally", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_bounty", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_rune_illusion", "modifier/modifier_runes", LUA_MODIFIER_MOTION_NONE)

	-- Roshan's shit
	LinkLuaModifier("modifier_imba_aegis", "modifier/modifier_imba_aegis", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_roshan_upgrade", "modifier/modifier_imba_aegis", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_imba_storm_bolt_caster", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE) -- To hide the mama Roshan
	PrecacheResource("particle", "particles/items_fx/aegis_timer.vpcf", context)
	PrecacheResource("particle", "particles/items_fx/aegis_respawn.vpcf", context)

end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:_InitGameMode()
end