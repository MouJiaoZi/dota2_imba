IMBA_GAME_VERSION = 174

IMBA_WEB_SERVER = "https://www.moujiaozi.me/"

IMBA_WEB_KEY = GetDedicatedServerKeyV2("imba")

GAME_UPDATED_CAST = false


-- In this file you can set up all the properties and settings for your game mode.
ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
if GameRules:IsCheatMode() then
	UNIVERSAL_SHOP_MODE = true
end
ALLOW_SAME_HERO_SELECTION = false        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 60.0              -- How long should we let people select their hero?
IMBA_SELECTION_SHOW_UP_DELAY = 5.0
AP_BAN_TIME_TEAM = 10.0
IMBA_LOADING_DELAY = 30.0
if GameRules:IsCheatMode() then
	IMBA_SELECTION_SHOW_UP_DELAY = 0
	HERO_SELECTION_TIME = 10.0
	AP_BAN_TIME_TEAM = 0
	IMBA_LOADING_DELAY = 0
end
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
FORCE_PICKED_HERO = "npc_dota_hero_dummy_dummy"                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

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
if IsInToolsMode() then
	AUTO_LAUNCH_DELAY = 0.1
end
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

HERO_STARTING_LEVEL = 1

if GetMapName() == "dbii_5v5" then										-- Standard map defaults
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5
	END_GAME_ON_KILLS = false
	CUSTOM_GOLD_BONUS = 110
	CUSTOM_XP_BONUS = 110
	HERO_RESPAWN_TIME_MULTIPLIER = 50
	IMBA_STARTING_GOLD = 1300
	IMBA_STARTING_GOLD_RANDOM = 1600
	HERO_STARTING_LEVEL = 2
	MAX_LEVEL = 35
	HERO_LEVEL_RESPAWN_MULTIPLY = 1.5
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
	CUSTOM_GOLD_BONUS = 150
	CUSTOM_XP_BONUS = 210
	HERO_RESPAWN_TIME_MULTIPLIER = 25
	IMBA_STARTING_GOLD = 2000
	IMBA_STARTING_GOLD_RANDOM = 2400
	HERO_STARTING_LEVEL = 1
	MAX_LEVEL = 40
	HERO_LEVEL_RESPAWN_MULTIPLY = 1.5
	CUSTOM_ROSHAN_RESPAWN = 10.0
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
HERO_XP_BOUNTY_PER_LEVEL[1] = 150
HERO_XP_BOUNTY_PER_LEVEL[2] = 200
HERO_XP_BOUNTY_PER_LEVEL[3] = 250
HERO_XP_BOUNTY_PER_LEVEL[4] = 300
HERO_XP_BOUNTY_PER_LEVEL[5] = 350
HERO_XP_BOUNTY_PER_LEVEL[6] = 400
HERO_XP_BOUNTY_PER_LEVEL[7] = 450

for i = 8, 20 do
	HERO_XP_BOUNTY_PER_LEVEL[i] = HERO_XP_BOUNTY_PER_LEVEL[i-1] + 100
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

HeroList = {}

IMBA_HEROLIST_STR = {}
IMBA_HEROLIST_AGI = {}
IMBA_HEROLIST_INT = {}

IMBA_PICKLIST_STR = {}
IMBA_PICKLIST_AGI = {}
IMBA_PICKLIST_INT = {}

IMBA_TOWER_ABILITY_1 = {
"imba_tower_mana_flare",
"imba_tower_axe",
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
"imba_tower_axe",
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
"imba_tower_axe",
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

IMBA_TOWER_ABILITY_SUM = {}
IMBA_TOWER_ABILITY_SUM[1] = IMBA_TOWER_ABILITY_1
IMBA_TOWER_ABILITY_SUM[2] = IMBA_TOWER_ABILITY_2
IMBA_TOWER_ABILITY_SUM[3] = IMBA_TOWER_ABILITY_3
IMBA_TOWER_ABILITY_SUM[4] = IMBA_TOWER_ABILITY_4

PRECACHED_UNIT = {}

IMBA_DISABLE_PLAYER = {}
for i=0, 23 do
	IMBA_DISABLE_PLAYER[i] = false
end

IMBA_COURIER_FEEDING = {}
for i=0, 23 do
	IMBA_COURIER_FEEDING[i] = 0
end

IMBA_RESET_COURIER_FEEDING = false

noDamageFilterUnits = {}
noDamageFilterUnits["npc_dota_unit_tombstone1"] = true
noDamageFilterUnits["npc_dota_unit_tombstone2"] = true
noDamageFilterUnits["npc_dota_unit_tombstone3"] = true
noDamageFilterUnits["npc_dota_unit_tombstone4"] = true
noDamageFilterUnits["npc_dota_unit_undying_zombie"] = true
noDamageFilterUnits["npc_dota_zeus_cloud"] = true

IMBA_WARD_TABLE = {}