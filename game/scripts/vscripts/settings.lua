-- In this file you can set up all the properties and settings for your game mode.



ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
if GameRules:IsCheatMode() then
	UNIVERSAL_SHOP_MODE = true
end
ALLOW_SAME_HERO_SELECTION = false        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 60.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 60.0                   	-- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 30.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 300.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 1                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 0.60                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes
CAMERA_DISTANCE_OVERRIDE = -1           -- How far out should we allow the camera to go?  Use -1 for the default (1134) while still allowing for panorama camera distance changes

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = true                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
											-- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = false        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = true -- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 50                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
	XP_PER_LEVEL_TABLE[i] = (i-1) * 100
end

ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = false               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = nil                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = 30                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = 0       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = 10     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = 10   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 700              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

GAME_END_DELAY = 0                    -- How long should we wait after the game winner is set to display the victory banner and End Screen?  Use -1 to keep the default (about 10 seconds)
VICTORY_MESSAGE_DURATION = 30            -- How long should we wait after the victory message displays to show the End Screen?  Use 

STARTING_GOLD = 0                     -- How much starting gold should we give to each player?

DISABLE_DAY_NIGHT_CYCLE = false         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?
SKIP_TEAM_SETUP = false                 -- Should we skip the team setup entirely?
ENABLE_AUTO_LAUNCH = true               -- Should we automatically have the game complete team setup after AUTO_LAUNCH_DELAY seconds?
AUTO_LAUNCH_DELAY = 10                  -- How long should the default team selection launch timer be?  The default for custom games is 30.  Setting to 0 will skip team selection.
LOCK_TEAM_SETUP = true                 -- Should we lock the teams initially?  Note that the host can still unlock the teams 


-- NOTE: You always need at least 2 non-bounty type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = false
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true
ENABLED_RUNES[DOTA_RUNE_ARCANE] = true


MAX_NUMBER_OF_TEAMS = 2                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = false           -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 0, 255, 0 }  --    Teal
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 255, 0, 0 }   --    Yellow

PLAYER_COLORS = {}															-- Stores individual player colors
PLAYER_COLORS[0] = { 67, 133, 255 }
PLAYER_COLORS[1]  = { 170, 255, 195 }
PLAYER_COLORS[2] = { 130, 0, 150 }
PLAYER_COLORS[3] = { 255, 234, 0 }
PLAYER_COLORS[4] = { 255, 153, 0 }
PLAYER_COLORS[5] = { 190, 255, 0 }
PLAYER_COLORS[6] = { 255, 0, 0 }
PLAYER_COLORS[7] = { 0, 128, 128 }
PLAYER_COLORS[8] = { 255, 250, 200 }
PLAYER_COLORS[9] = { 1, 1, 1 }
PLAYER_COLORS[10] = { 255, 0, 255 }
PLAYER_COLORS[11]  = { 128, 128, 0 }
PLAYER_COLORS[12] = { 100, 255, 255 }
PLAYER_COLORS[13] = { 0, 190, 0 }
PLAYER_COLORS[14] = { 170, 110, 40 }
PLAYER_COLORS[15] = { 0, 0, 128 }
PLAYER_COLORS[16] = { 230, 190, 255 }
PLAYER_COLORS[17] = { 128, 0, 0 }
PLAYER_COLORS[18] = { 128, 128, 128 }
PLAYER_COLORS[19] = { 254, 254, 254 }
PLAYER_COLORS[20] = { 166, 166, 166 }
PLAYER_COLORS[21] = { 255, 89, 255 }
PLAYER_COLORS[22] = { 203, 255, 89 }
PLAYER_COLORS[23] = { 108, 167, 255 }

USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 10
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 10


if GetMapName() == "dbii_5v5" then										-- Standard map defaults
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5
	END_GAME_ON_KILLS = false
	CUSTOM_GOLD_BONUS = 60
	CUSTOM_XP_BONUS = 60
	HERO_RESPAWN_TIME_MULTIPLIER = 75
	IMBA_STARTING_GOLD = 1300
	IMBA_STARTING_GOLD_RANDOM = 1600
	HERO_STARTING_LEVEL = 2
	MAX_LEVEL = 35
	HERO_LEVEL_RESPAWN_MULTIPLY = 3.0
	CUSTOM_ROSHAN_RESPAWN = 60.0
elseif GetMapName() == "dbii_10v10" then									-- 10v10 map defaults
	END_GAME_ON_KILLS = false
	CUSTOM_GOLD_BONUS = 110
	CUSTOM_XP_BONUS = 110
	HERO_RESPAWN_TIME_MULTIPLIER = 50
	IMBA_STARTING_GOLD = 2000
	IMBA_STARTING_GOLD_RANDOM = 2400
	HERO_STARTING_LEVEL = 5
	MAX_LEVEL = 40
	HERO_LEVEL_RESPAWN_MULTIPLY = 1.5
	CUSTOM_ROSHAN_RESPAWN = 30.0
elseif GetMapName() == "dbii_death_match" then									-- death match map defaults
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 8
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 8
	END_GAME_ON_KILLS = true
	KILLS_TO_END_GAME_FOR_TEAM = 200
	CUSTOM_GOLD_BONUS = 150
	CUSTOM_XP_BONUS = 210
	HERO_RESPAWN_TIME_MULTIPLIER = 25
	IMBA_STARTING_GOLD = 2000
	IMBA_STARTING_GOLD_RANDOM = 2400
	HERO_STARTING_LEVEL = 1
	MAX_LEVEL = 40
	HERO_LEVEL_RESPAWN_MULTIPLY = 1.5
	CUSTOM_ROSHAN_RESPAWN = 99999.0
end

XP_PER_LEVEL_TABLE = {}

for i = 1, HERO_STARTING_LEVEL do
	XP_PER_LEVEL_TABLE[i] = 0
end

for i = HERO_STARTING_LEVEL + 1, MAX_LEVEL do
	XP_PER_LEVEL_TABLE[i] = (HERO_STARTING_LEVEL * 150 + i * 150) * (i - HERO_STARTING_LEVEL) / 2
end

-- XP AWARDED per level table (how much bounty heroes are worth beyond level 25)
HERO_XP_BOUNTY_PER_LEVEL = {}
HERO_XP_BOUNTY_PER_LEVEL[1] = 175
HERO_XP_BOUNTY_PER_LEVEL[2] = 225
HERO_XP_BOUNTY_PER_LEVEL[3] = 265
HERO_XP_BOUNTY_PER_LEVEL[4] = 335
HERO_XP_BOUNTY_PER_LEVEL[5] = 400
HERO_XP_BOUNTY_PER_LEVEL[6] = 525
HERO_XP_BOUNTY_PER_LEVEL[7] = 655

for i = 8, 20 do
	HERO_XP_BOUNTY_PER_LEVEL[i] = HERO_XP_BOUNTY_PER_LEVEL[i-1] + 135
end

for i = 21, 100 do
	HERO_XP_BOUNTY_PER_LEVEL[i] = HERO_XP_BOUNTY_PER_LEVEL[i-1] + 135 + i * 3
end


BUYBACK_COOLDOWN_ENABLED = true												-- Is the buyback cooldown enabled?

BUYBACK_COOLDOWN_START_POINT = 0											-- Game time (in seconds) after which buyback cooldown is activated
BUYBACK_COOLDOWN_GROW_FACTOR = 0.147										-- Buyback cooldown increase per second
BUYBACK_COOLDOWN_MAXIMUM = 300												-- Maximum buyback cooldown

BUYBACK_BASE_COST = 100														-- Base cost to buyback
BUYBACK_COST_PER_LEVEL = 1.5												-- Level-based buyback cost
BUYBACK_COST_PER_LEVEL_AFTER_25 = 35										-- Level-based buyback cost growth after level 25
BUYBACK_COST_PER_SECOND = 0.5												-- Time-based buyback cost

SPELL_AMP_RAPIER_1 = 0.7
SPELL_AMP_RAPIER_3 = 2.0
SPELL_AMP_RAPIER_SUPER = 2.0


IMBA_TOWER_ABILITY_1 = {
"imba_tower_mana_flare",
"imba_tower_force",
"imba_tower_self_repair",
"imba_tower_plague",
"imba_tower_spell_shield",
"imba_tower_mana_burn",
"imba_tower_fervor",
"imba_tower_thorns",
"imba_tower_sniper",
"imba_tower_machinegun",
"imba_tower_berserk",
}

IMBA_TOWER_ABILITY_2 = {
"imba_tower_mana_flare",
"imba_tower_laser",
"imba_tower_chrono",
"imba_tower_force",
"imba_tower_nature",
"imba_tower_self_repair",
"imba_tower_plague",
"imba_tower_aegis",
"imba_tower_spell_shield",
"imba_tower_atrophy",
"imba_tower_disease",
"imba_tower_mana_burn",
"imba_tower_fervor",
"imba_tower_thorns",
"imba_tower_sniper",
"imba_tower_machinegun",
"imba_tower_berserk",
"imba_tower_grievous_wounds",
"imba_tower_spacecow",
"imba_tower_permabash",
"imba_tower_split",
}

IMBA_TOWER_ABILITY_3 = {
"imba_tower_mana_flare",
"imba_tower_laser",
"imba_tower_hex_aura",
"imba_tower_chrono",
"imba_tower_force",
"imba_tower_nature",
"imba_tower_mindblast",
"imba_tower_aegis",
"imba_tower_spell_shield",
"imba_tower_atrophy",
"imba_tower_disease",
"imba_tower_sniper",
"imba_tower_machinegun",
"imba_tower_berserk",
"imba_tower_grievous_wounds",
"imba_tower_spacecow",
"imba_tower_permabash",
"imba_tower_vicious",
"imba_tower_essence_drain",
"imba_tower_multihit",
"imba_tower_split",
}

IMBA_TOWER_ABILITY_4 = {
"imba_tower_laser",
"imba_tower_hex_aura",
"imba_tower_chrono",
"imba_tower_atrophy",
"imba_tower_disease",
"imba_tower_grievous_wounds",
"imba_tower_essence_drain",
"imba_tower_multihit",
}

IMBA_RANDOM_ABILITIES = {
	"imba_antimage_mana_break",
	"imba_antimage_blink",
	"imba_antimage_spell_shield",
	"imba_axe_berserkers_call",
	"imba_axe_battle_hunger",
	"imba_axe_counter_helix",
	"imba_bane_enfeeble",
	"imba_bane_brain_sap",
	"bloodseeker_bloodrage",
	"bloodseeker_blood_bath",
	"bloodseeker_thirst",
	"imba_crystal_maiden_crystal_nova",
	"imba_crystal_maiden_frostbite",
	"imba_crystal_maiden_brilliance_aura",
	"imba_drow_ranger_gust",
	"imba_drow_ranger_trueshot",
	"earthshaker_enchant_totem",
	"earthshaker_aftershock",
	"imba_juggernaut_blade_fury",
	"imba_juggernaut_healing_ward",
	"imba_juggernaut_blade_dance",
	"imba_mirana_starfall",
	"imba_mirana_arrow",
	"imba_mirana_leap",
	"imba_nevermore_shadowraze",
	"imba_nevermore_necromastery",
	"imba_nevermore_dark_lord",
	"morphling_waveform",
	"puck_waning_rift",
	"puck_phase_shift",
	"imba_pudge_rot",
	"imba_pudge_flesh_heap",
	"razor_plasma_field",
	"razor_static_link",
	"razor_unstable_current",
	"imba_sandking_burrowstrike",
	"imba_sandking_sand_storm",
	"imba_sandking_caustic_finale",
	"imba_storm_spirit_static_remnant",
	"imba_storm_spirit_electric_vortex",
	"imba_storm_spirit_overload",
	"imba_sven_storm_bolt",
	"imba_sven_great_cleave",
	"imba_sven_warcry",
	"tiny_avalanche",
	"tiny_toss",
	"imba_vengeful_magic_missile",
	"imba_vengeful_wave_of_terror",
	"imba_vengeful_command_aura",
	"windrunner_shackleshot",
	"windrunner_powershot",
	"windrunner_windrun",
	"zuus_arc_lightning",
	"zuus_lightning_bolt",
	"zuus_static_field",
	"imba_kunkka_torrent",
	"imba_kunkka_tidebringer",
	"imba_lina_dragon_slave",
	"imba_lina_light_strike_array",
	"imba_lich_frost_nova",
	"imba_lich_frost_armor",
	"imba_lich_dark_ritual",
	"imba_lion_earth_spike",
	"imba_lion_hex",
	"imba_lion_mana_drain",
	"shadow_shaman_ether_shock",
	"shadow_shaman_voodoo",
	"shadow_shaman_shackles",
	"slardar_sprint",
	"slardar_slithereen_crush",
	"slardar_bash",
	"tidehunter_gush",
	"tidehunter_kraken_shell",
	"tidehunter_anchor_smash",
	"imba_witch_doctor_paralyzing_cask",
	"imba_witch_doctor_voodoo_restoration",
	"imba_witch_doctor_maledict",
	"riki_smoke_screen",
	"riki_blink_strike",
	"riki_permanent_invisibility",
	"imba_enigma_malefice",
	"imba_enigma_demonic_conversion",
	"imba_enigma_midnight_pulse",
	"imba_tinker_laser",
	"imba_tinker_heat_seeking_missile",
	"imba_sniper_headshot",
	"sniper_shrapnel",
	"beastmaster_wild_axes",
	"beastmaster_inner_beast",
	"imba_queenofpain_shadow_strike",
	"imba_queenofpain_blink",
	"imba_queenofpain_scream_of_pain",
	"imba_faceless_void_time_walk",
	"imba_faceless_void_time_dilation",
	"imba_faceless_void_time_lock",
	"imba_wraith_king_wraithfire_blast",
	"imba_wraith_king_vampiric_aura",
	"imba_wraith_king_mortal_strike",
	"death_prophet_carrion_swarm",
	"death_prophet_silence",
	"death_prophet_spirit_siphon",
	"imba_pugna_nether_blast",
	"imba_pugna_decrepify",
	"imba_pugna_nether_ward",
	"templar_assassin_refraction",
	"templar_assassin_meld",
	"templar_assassin_psi_blades",
	"viper_poison_attack",
	"viper_nethertoxin",
	"viper_corrosive_skin",
	"luna_lucent_beam",
	"luna_lunar_blessing",
	"imba_luna_moon_glaive",
	"dragon_knight_breathe_fire",
	"dragon_knight_dragon_tail",
	"dragon_knight_dragon_blood",
	"imba_dazzle_poison_touch",
	"imba_dazzle_shallow_grave",
	"imba_dazzle_shadow_wave",
	"rattletrap_battery_assault",
	"rattletrap_power_cogs",
	"rattletrap_rocket_flare",
	"leshrac_split_earth",
	"leshrac_diabolic_edict",
	"leshrac_lightning_storm",
	"furion_sprout",
	"furion_teleportation",
	"imba_furion_force_of_nature",
	"life_stealer_rage",
	"life_stealer_feast",
	"life_stealer_open_wounds",
	"dark_seer_vacuum",
	"dark_seer_ion_shell",
	"dark_seer_surge",
	"imba_clinkz_strafe",
	"imba_clinkz_searing_arrows",
	"imba_clinkz_skeleton_walk",
	"imba_omniknight_purification",
	"imba_omniknight_repel",
	"imba_omniknight_degen_aura",
	"enchantress_untouchable",
	"enchantress_enchant",
	"enchantress_natures_attendants",
	"huskar_inner_fire",
	"huskar_burning_spear",
	"huskar_berserkers_blood",
	"imba_night_stalker_void",
	"imba_night_stalker_crippling_fear",
	"imba_night_stalker_hunter_in_the_night",
	"broodmother_spawn_spiderlings",
	"broodmother_spin_web",
	"broodmother_incapacitating_bite",
	"imba_bounty_hunter_shuriken_toss",
	"imba_bounty_hunter_wind_walk",
	"bounty_hunter_jinada",
	"weaver_the_swarm",
	"weaver_shukuchi",
	"weaver_geminate_attack",
	"imba_jakiro_liquid_fire",
	"jakiro_ice_path",
	"batrider_sticky_napalm",
	"batrider_flamebreak",
	"batrider_firefly",
	"chen_penitence",
	"chen_divine_favor",
	"chen_holy_persuasion",
	"doom_bringer_scorched_earth",
	"doom_bringer_infernal_blade",
	"ancient_apparition_cold_feet",
	"ancient_apparition_ice_vortex",
	"ancient_apparition_chilling_touch",
	"ursa_earthshock",
	"ursa_overpower",
	"ursa_fury_swipes",
	"spirit_breaker_charge_of_darkness",
	"spirit_breaker_bulldoze",
	"spirit_breaker_greater_bash",
	"gyrocopter_rocket_barrage",
	"gyrocopter_homing_missile",
	"gyrocopter_flak_cannon",
	"alchemist_acid_spray",
	"alchemist_goblins_greed",
	"silencer_curse_of_the_silent",
	"silencer_glaives_of_wisdom",
	"silencer_last_word",
	"imba_obsidian_destroyer_arcane_orb",
	"imba_obsidian_destroyer_astral_imprisonment",
	"imba_obsidian_destroyer_essence_aura",
	"lycan_summon_wolves",
	"lycan_howl",
	"lycan_feral_impulse",
	"brewmaster_thunder_clap",
	"brewmaster_cinder_brew",
	"brewmaster_drunken_brawler",
	"shadow_demon_disruption",
	"shadow_demon_soul_catcher",
	"chaos_knight_chaos_bolt",
	"chaos_knight_reality_rift",
	"chaos_knight_chaos_strike",
	"treant_natures_guise",
	"treant_leech_seed",
	"treant_living_armor",
	"ogre_magi_fireblast",
	"ogre_magi_ignite",
	"ogre_magi_bloodlust",
	"undying_decay",
	"undying_soul_rip",
	"undying_tombstone",
	"rubick_fade_bolt",
	"rubick_arcane_supremacy",
	"disruptor_thunder_strike",
	"disruptor_glimpse",
	"disruptor_kinetic_field",
	"imba_nyx_assassin_impale",
	"imba_nyx_assassin_mana_burn",
	"imba_nyx_assassin_spiked_carapace",
	"naga_siren_mirror_image",
	"naga_siren_ensnare",
	"naga_siren_rip_tide",
	"keeper_of_the_light_blinding_light",
	"keeper_of_the_light_chakra_magic",
	"wisp_relocate",
	"wisp_overcharge",
	"visage_grave_chill",
	"visage_soul_assumption",
	"visage_gravekeepers_cloak",
	"slark_dark_pact",
	"slark_pounce",
	"slark_essence_shift",
	"medusa_split_shot",
	"medusa_mystic_snake",
	"medusa_mana_shield",
	"imba_troll_warlord_fervor",
	"imba_centaur_hoof_stomp",
	"imba_centaur_double_edge",
	"imba_centaur_return",
	"imba_magnus_shockwave",
	"imba_magnus_empower",
	"imba_magnus_skewer",
	"shredder_whirling_death",
	"shredder_timber_chain",
	"shredder_reactive_armor",
	"bristleback_viscous_nasal_goo",
	"bristleback_quill_spray",
	"bristleback_bristleback",
	"tusk_ice_shards",
	"tusk_frozen_sigil",
	"tusk_tag_team",
	"imba_skywrath_mage_arcane_bolt",
	"imba_skywrath_mage_concussive_shot",
	"imba_skywrath_mage_ancient_seal",
	"imba_abaddon_death_coil",
	"imba_abaddon_aphotic_shield",
	"imba_abaddon_frostmourne",
	"elder_titan_echo_stomp",
	"elder_titan_natural_order",
	"legion_commander_overwhelming_odds",
	"legion_commander_press_the_attack",
	"legion_commander_moment_of_courage",
	"imba_ember_spirit_searing_chains",
	"imba_ember_spirit_sleight_of_fist",
	"imba_ember_spirit_flame_guard",
	"terrorblade_reflection",
	"terrorblade_conjure_image",
	"terrorblade_metamorphosis",
	"phoenix_icarus_dive",
	"oracle_fortunes_end",
	"oracle_fates_edict",
	"oracle_purifying_flames",
	"imba_techies_land_mines",
	"imba_techies_stasis_trap",
	"imba_techies_suicide",
	"abyssal_underlord_firestorm",
	"abyssal_underlord_pit_of_malice",
	"abyssal_underlord_atrophy_aura",
	"monkey_king_boundless_strike",
	"monkey_king_jingu_mastery",
	"pangolier_swashbuckle",
	"pangolier_shield_crash",
	"pangolier_heartpiercer",
	"pangolier_lucky_shot",
	"dark_willow_bramble_maze",
	"dark_willow_shadow_realm",
	"dark_willow_cursed_crown",
	"grimstroke_dark_artistry",
	"grimstroke_ink_creature",
	"grimstroke_spirit_walk",
}

IMBA_RANDOM_ABILITIES_ULTI = {
	"imba_antimage_mana_void",
	"imba_axe_culling_blade",
	"imba_bane_fiends_grip",
	"bloodseeker_rupture",
	"imba_crystal_maiden_freezing_field",
	"imba_drow_ranger_marksmanship",
	"earthshaker_echo_slam",
	"imba_juggernaut_omni_slash",
	"imba_mirana_moonlight_shadow",
	"puck_dream_coil",
	"imba_pudge_dismember",
	"razor_eye_of_the_storm",
	"imba_sandking_epicenter",
	"imba_storm_spirit_ball_lightning",
	"imba_sven_gods_strength",
	"tiny_grow",
	"windrunner_focusfire",
	"zuus_thundergods_wrath",
	"imba_kunkka_ghostship",
	"imba_lina_laguna_blade",
	"imba_lich_chain_frost",
	"imba_lion_finger_of_death",
	"shadow_shaman_mass_serpent_ward",
	"slardar_amplify_damage",
	"tidehunter_ravage",
	"imba_witch_doctor_death_ward",
	"riki_tricks_of_the_trade",
	"imba_enigma_black_hole",
	"imba_sniper_assassinate",
	"beastmaster_primal_roar",
	"imba_queenofpain_sonic_wave",
	"imba_faceless_void_chronosphere",
	"imba_wraith_king_reincarnation",
	"death_prophet_exorcism",
	"viper_viper_strike",
	"dragon_knight_elder_dragon_form",
	"imba_dazzle_weave",
	"rattletrap_hookshot",
	"leshrac_pulse_nova",
	"furion_wrath_of_nature",
	"dark_seer_wall_of_replica",
	"imba_clinkz_death_pact",
	"imba_omniknight_guardian_angel",
	"enchantress_impetus",
	"huskar_life_break",
	"imba_night_stalker_darkness",
	"broodmother_insatiable_hunger",
	"imba_bounty_hunter_track",
	"weaver_time_lapse",
	"imba_jakiro_macropyre",
	"batrider_flaming_lasso",
	"chen_hand_of_god",
	"imba_doom_bringer_doom",
	"ursa_enrage",
	"spirit_breaker_nether_strike",
	"gyrocopter_call_down",
	"alchemist_chemical_rage",
	"silencer_global_silence",
	"imba_obsidian_destroyer_sanity_eclipse",
	"lycan_shapeshift",
	"brewmaster_primal_split",
	"shadow_demon_demonic_purge",
	"chaos_knight_phantasm",
	"treant_overgrowth",
	"imba_ogre_magi_multicast",
	"undying_flesh_golem",
	"disruptor_static_storm",
	"imba_nyx_assassin_vendetta",
	"keeper_of_the_light_will_o_wisp",
	"imba_slark_shadow_dance",
	"medusa_stone_gaze",
	"imba_troll_warlord_battle_trance",
	"imba_centaur_stampede",
	"imba_magnus_reverse_polarity",
	"bristleback_warpath",
	"tusk_walrus_punch",
	"imba_skywrath_mage_mystic_flare",
	"imba_abaddon_borrowed_time",
	"elder_titan_earth_splitter",
	"legion_commander_duel",
	"terrorblade_sunder",
	"phoenix_supernova",
	"oracle_false_promise",
	"monkey_king_wukongs_command",
	"grimstroke_soul_chain",
}