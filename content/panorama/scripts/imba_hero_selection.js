// 0 = non IMBA 1 = Full IMBA 2 = Half IMBA 3 = is Going to IMBA

var IMBAHeroes =
{
npc_dota_hero_alchemist: 0,
npc_dota_hero_ancient_apparition: 0,
npc_dota_hero_antimage: 1,
npc_dota_hero_axe: 1,
npc_dota_hero_bane: 1,
npc_dota_hero_beastmaster: 0,
npc_dota_hero_bloodseeker: 0,
npc_dota_hero_chen: 0,
npc_dota_hero_crystal_maiden: 1,
npc_dota_hero_dark_seer: 2,
npc_dota_hero_dazzle: 1,
npc_dota_hero_dragon_knight: 0,
npc_dota_hero_doom_bringer: 2,
npc_dota_hero_drow_ranger: 1,
npc_dota_hero_earthshaker: 2,
npc_dota_hero_enchantress: 0,
npc_dota_hero_enigma: 1,
npc_dota_hero_faceless_void: 1,
npc_dota_hero_furion: 2,
npc_dota_hero_juggernaut: 1,
npc_dota_hero_kunkka: 1,
npc_dota_hero_leshrac: 0,
npc_dota_hero_lich: 1,
npc_dota_hero_life_stealer: 0,
npc_dota_hero_lina: 1,
npc_dota_hero_lion: 1,
npc_dota_hero_mirana: 1,
npc_dota_hero_morphling: 2,
npc_dota_hero_necrolyte: 2,
npc_dota_hero_nevermore: 1,
npc_dota_hero_night_stalker: 1,
npc_dota_hero_omniknight: 1,
npc_dota_hero_puck: 1,
npc_dota_hero_pudge: 1,
npc_dota_hero_pugna: 1,
npc_dota_hero_rattletrap: 1,
npc_dota_hero_razor: 0,
npc_dota_hero_riki: 2,
npc_dota_hero_sand_king: 1,
npc_dota_hero_shadow_shaman: 3,
npc_dota_hero_slardar: 0,
npc_dota_hero_sniper: 1,
npc_dota_hero_spectre: 2,
npc_dota_hero_storm_spirit: 1,
npc_dota_hero_sven: 1,
npc_dota_hero_tidehunter: 0,
npc_dota_hero_tinker: 1,
npc_dota_hero_tiny: 0,
npc_dota_hero_vengefulspirit: 1,
npc_dota_hero_venomancer: 1,
npc_dota_hero_viper: 0,
npc_dota_hero_weaver: 0,
npc_dota_hero_windrunner: 0,
npc_dota_hero_witch_doctor: 1,
npc_dota_hero_zuus: 0,
npc_dota_hero_broodmother: 1,
npc_dota_hero_skeleton_king: 1,
npc_dota_hero_queenofpain: 1,
npc_dota_hero_huskar: 2,
npc_dota_hero_jakiro: 1,
npc_dota_hero_batrider: 0,
npc_dota_hero_warlock: 1,
npc_dota_hero_death_prophet: 0,
npc_dota_hero_ursa: 0,
npc_dota_hero_bounty_hunter: 1,
npc_dota_hero_silencer: 0,
npc_dota_hero_spirit_breaker: 0,
npc_dota_hero_invoker: 2,
npc_dota_hero_clinkz: 1,
npc_dota_hero_obsidian_destroyer: 1,
npc_dota_hero_shadow_demon: 0,
npc_dota_hero_lycan: 0,
npc_dota_hero_lone_druid: 1,
npc_dota_hero_brewmaster: 0,
npc_dota_hero_phantom_lancer: 0,
npc_dota_hero_treant: 0,
npc_dota_hero_ogre_magi: 2,
npc_dota_hero_chaos_knight: 1,
npc_dota_hero_phantom_assassin: 1,
npc_dota_hero_gyrocopter: 0,
npc_dota_hero_rubick: 2,
npc_dota_hero_luna: 2,
npc_dota_hero_wisp: 0,
npc_dota_hero_disruptor: 1,
npc_dota_hero_undying: 2,
npc_dota_hero_templar_assassin: 2,
npc_dota_hero_naga_siren: 0,
npc_dota_hero_nyx_assassin: 1,
npc_dota_hero_keeper_of_the_light: 0,
npc_dota_hero_visage: 2,
npc_dota_hero_meepo: 2,
npc_dota_hero_magnataur: 1,
npc_dota_hero_centaur: 1,
npc_dota_hero_slark: 2,
npc_dota_hero_shredder: 0,
npc_dota_hero_medusa: 0,
npc_dota_hero_troll_warlord: 1,
npc_dota_hero_tusk: 2,
npc_dota_hero_bristleback: 2,
npc_dota_hero_skywrath_mage: 1,
npc_dota_hero_elder_titan: 0,
npc_dota_hero_abaddon: 1,
npc_dota_hero_earth_spirit: 1,
npc_dota_hero_ember_spirit: 1,
npc_dota_hero_legion_commander: 0,
npc_dota_hero_phoenix: 0,
npc_dota_hero_terrorblade: 0,
npc_dota_hero_techies: 1,
npc_dota_hero_oracle: 2,
npc_dota_hero_winter_wyvern: 0,
npc_dota_hero_arc_warden: 0,
npc_dota_hero_abyssal_underlord: 1,
npc_dota_hero_monkey_king: 0,
npc_dota_hero_pangolier: 2,
npc_dota_hero_dark_willow: 0,
npc_dota_hero_mars: 0,
npc_dota_hero_grimstroke: 1
};

var local_player = Players.GetLocalPlayer();
var pick_mode = CustomNetTables.GetTableValue("imba_hero_selection_list", "pick_mode")[1];
// all_pick   

var hero_str = CustomNetTables.GetTableValue("imba_hero_selection_list", "all_pick_str");
var hero_agi = CustomNetTables.GetTableValue("imba_hero_selection_list", "all_pick_agi");
var hero_int = CustomNetTables.GetTableValue("imba_hero_selection_list", "all_pick_int");
var hero_sum = [];

var hero_attribute = {};

var grid_str = $("#HeroCardGrid_Str");
var grid_agi = $("#HeroCardGrid_Agi");
var grid_int = $("#HeroCardGrid_Int");

function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

var hero_card_set = 0;

function CreateHeroCard(hero_array, i, target_panel, main_attribute)
{
	var hero_name = hero_array[i];
	var hero_card = $.CreatePanel("Panel", target_panel, "IMBAHeroCard_" + hero_name);
	hero_card.SetAttributeString("heroname", hero_name);
	hero_card.SetAttributeInt("hero_attribute", main_attribute);
	hero_card.BLoadLayout("file://{resources}/layout/custom_game/imba_hero_selection_hero.xml", false, false);
	hero_sum[hero_sum.length] = hero_name;
	hero_attribute[hero_name] = main_attribute;
	SetUpHeroCard(hero_name);
}

function InitHeroGrid()
{
	for(var i in hero_str)
	{
		(function(a)
		{
			$.Schedule(a * 0.05, function() {CreateHeroCard(hero_str, a, grid_str, 0);});
		})(i);
	}
	for(var i in hero_agi)
	{
		(function(a)
		{
			$.Schedule(a * 0.05, function() {CreateHeroCard(hero_agi, a, grid_agi, 1);});
		})(i);
	}
	for(var i in hero_int)
	{
		(function(a)
		{
			$.Schedule(a * 0.05, function() {CreateHeroCard(hero_int, a, grid_int, 2);});
		})(i);
	}
}

function SetUpHeroCard(hero_name)
{
	var hero_card_movie = $("#HeroPick_Card_Hover");
	//for(var i in hero_sum)
	//{
		var hero_card = $("#IMBAHeroCard_"+hero_name);
		if(hero_card)
		{
			(function (panel, name) {
				panel.SetPanelEvent("onmouseover", function() {
					hero_card_movie.FindChild("HeroPick_Card_Hover_Movie").heroname = name;
					var screen_width = Game.GetScreenWidth();
					var screen_heidht = Game.GetScreenHeight();
					var window_width = panel.actualxoffset+panel.GetParent().actualxoffset+panel.GetParent().GetParent().actualxoffset+panel.GetParent().GetParent().GetParent().actualxoffset+panel.GetParent().GetParent().GetParent().GetParent().actualxoffset-50;
					var window_height = panel.actualyoffset+panel.GetParent().actualyoffset+panel.GetParent().GetParent().actualyoffset+panel.GetParent().GetParent().GetParent().actualyoffset+panel.GetParent().GetParent().GetParent().GetParent().actualyoffset-58.5;
					hero_card_movie.style.marginLeft = (screen_width * (window_width / 1920)) + "px";
					hero_card_movie.style.marginTop = (screen_heidht * (window_height / 1080)) + "px";
					hero_card_movie.FindChild("HeroPick_Card_Hover_Name").text = $.Localize(name);
					hero_card_movie.ToggleClass("Show");
				})
				panel.SetPanelEvent("onmouseout", function() {
					hero_card_movie.ToggleClass("Show");
				})
			})(hero_card, hero_name);
			if(pick_mode == "all_pick")
			{
				if(IMBAHeroes[hero_name] == 1)
				{
					hero_card.FindChildTraverse("Overlay_FullyIMBA").SetHasClass("visible", true);
				}
				else if(IMBAHeroes[hero_name] == 2)
				{
					hero_card.FindChildTraverse("Overlay_HalfIMBA").SetHasClass("visible", true);
				}
				else if(IMBAHeroes[hero_name] == 3)
				{
					hero_card.FindChildTraverse("Overlay_GoingIMBA").SetHasClass("visible", true);
				}
			}
		}
	//}
}

function InitPlayerCard()
{
	var radiantBase = $("#HeroSelection_Top_Left");
	var direBase = $("#HeroSelection_Top_Right");
	for(var i=0;i<20;i++)
	{
		var info = Game.GetPlayerInfo(i);
		if(info)
		{ 
			if(info.player_team_id == 2)
			{
				var player_card = $.CreatePanel("Panel", radiantBase, "IMBAPlayerCard_"+i);
				player_card.style.zIndex="80";
				player_card.SetAttributeInt("player_team", 2);
				player_card.SetAttributeInt("player_id", i);
				player_card.BLoadLayout("file://{resources}/layout/custom_game/imba_hero_selection_player.xml", false, false);
			}
			else if(info.player_team_id == 3)
			{
				var player_card = $.CreatePanel("Panel", direBase, "IMBAPlayerCard_"+i);
				player_card.style.zIndex="80";
				player_card.SetAttributeInt("player_team", 3);
				player_card.SetAttributeInt("player_id", i);
				player_card.BLoadLayout("file://{resources}/layout/custom_game/imba_hero_selection_player.xml", false, false);
			}
		}
	}
}

function InitIMBAHeroSelection()
{
	if(CustomNetTables.GetTableValue("imba_hero_selection_list", "selection_phase_done"))
	{
		SelectionDone();
	}
	else
	{
		InitHeroGrid();
		InitPlayerCard();
		$.GetContextPanel().SetHasClass("ongoing", true)
	}
}

InitIMBAHeroSelection();

function PlayerSelectHero()
{
	if(local_player == -1)
		return;
	GameEvents.SendCustomGameEventToServer("IMBAHeroSelection_PlayerLockHeroIn", {});
	Game.EmitSound("HeroPicker.Selected");
}

function PlayerRandomHero()
{
	if(local_player == -1)
		return;
	Game.EmitSound("HeroPicker.Selected");
	GameEvents.SendCustomGameEventToServer("IMBAHeroSelection_PlayerRandomSelect", {});
}

function PlayerBanHero()
{
	if(local_player == -1)
		return;
	GameEvents.SendCustomGameEventToServer("IMBAHeroSelection_PlayerBanHero", {});
}

function UpdateSelectButton()
{
	var ban_info = CustomNetTables.GetTableValue("imba_hero_selection_list", "banned_hero");
	var current_view = $("#HeroPick_Info_Main_Movie_Main").GetAttributeString("heroname", "no_hero_name");
	var button_panel = $("#HeroPick_Info_ButtonBase");
	var ban_button = $("#HeroSelection_BanButton");
	var pick_random_base = $("#HeroPick_Info_PickRandomButton");
	var pick_button = $("#HeroPick_Info_Button_Pick");
	var random_button = $("#HeroPick_Info_Button_Random");
	var phase = CustomNetTables.GetTableValue("imba_hero_selection_list", "pick_phase")[1];
	if(local_player == -1 || (!phase.match("pick") && !phase.match("ban")) || phase == "end_pick")
	{
		button_panel.style.visibility = "collapse";
		ban_button.style.visibility = "collapse";
		pick_random_base.style.visibility = "collapse";
	}
	else
	{
		button_panel.style.visibility = "visible";
		if(phase.match("ban"))
		{
			if(Game.GetLocalPlayerInfo().player_team_id != 2 && phase == "ban_radiant")
			{
				ban_button.style.visibility = "collapse";
				pick_random_base.style.visibility = "collapse";
				return;
			}
			if(Game.GetLocalPlayerInfo().player_team_id != 3 && phase == "ban_dire")
			{
				ban_button.style.visibility = "collapse";
				pick_random_base.style.visibility = "collapse";
				return;
			}
			ban_button.style.visibility = "visible";
			pick_random_base.style.visibility = "collapse";
			if(current_view == "" || (ban_info && ban_info[current_view]))
			{
				ban_button.style.washColor = "#000000E7";
				ban_button.hittest = false;
				ban_button.enabled = false;
			}
			else
			{
				ban_button.style.washColor = "#FFFFFF00";
				ban_button.hittest = true;
				ban_button.enabled = true;
			}
		}
		else if(phase.match("pick"))
		{
			ban_button.style.visibility = "collapse";
			pick_random_base.style.visibility = "visible";
			if(ban_info && ban_info[current_view])
			{
				pick_button.style.washColor = "#000000E7";
				pick_button.hittest = false;
				pick_button.enabled = false;
				return;
			}
			else
			{
				pick_button.style.washColor = "#FFFFFF00";
				pick_button.hittest = true;
				pick_button.enabled = true;
			}
			for(var i=0;i<20;i++)
			{
				var info = CustomNetTables.GetTableValue("imba_hero_selection_player", "player_hero_selected_"+i);
				if((info && info.hero == current_view) || current_view == "" || CustomNetTables.GetTableValue("imba_hero_selection_player", "player_hero_selected_"+local_player) || local_player == -1)
				{
					pick_button.style.washColor = "#000000E7";
					pick_button.hittest = false;
					pick_button.enabled = false;
					if(local_player == -1 || CustomNetTables.GetTableValue("imba_hero_selection_player", "player_hero_selected_"+local_player)) 
					{
						random_button.style.washColor = "#000000E7";
						random_button.hittest = false;
						random_button.enabled = false;
						random_button.GetChild(0).hittest = false;
						random_button.GetChild(0).enabled = false;
					}
					return;
				}
			}
			pick_button.style.washColor = "#FFFFFF00";
			pick_button.hittest = true;
			pick_button.enabled = true;
		}
	}
}

function UpdateTimer(keys)
{
	if($("#HeroSelection_Top_Center_Time").text != keys.time && keys.time == 10)
		Game.EmitSound("IMBA_TIME_10");
	if($("#HeroSelection_Top_Center_Time").text != keys.time && keys.time == 5)
		Game.EmitSound("IMBA_TIME_5");
	$("#HeroSelection_Top_Center_Time").text = keys.time;
}

function SelectionDone()
{
	$.GetContextPanel().SetHasClass("ongoing", false)
}

function ChangeSelectionPhase()
{
	var phase_text = $("#HeroSelection_Top_Center_Phase");
	var phase = CustomNetTables.GetTableValue("imba_hero_selection_list", "pick_phase")[1];
	switch(phase)
	{
		case "set_up":
			phase_text.text = "#Please_Wait";
			break;
		case "end_pick":
			phase_text.text = "#Please_Wait";
			break;
		case "ban_radiant":
			phase_text.text = "#IMBA_HUD_HERO_SELECTION_RADIANT_Phase_Ban";
			Game.EmitSound("IMBA_SELECTION_BAN_RADIANT");
			break;
		case "ban_dire":
			phase_text.text = "#IMBA_HUD_HERO_SELECTION_DIRE_Phase_Ban";
			Game.EmitSound("IMBA_SELECTION_BAN_DIRE");
			break;
		case "all_pick":
			phase_text.text = "#DOTA_GameMode_AllPick";
			Game.EmitSound("IMBA_SELECTION_MODE_AP");
			break;
	}
	UpdateSelectButton();
}

UpdateSelectButton();
ChangeSelectionPhase();
GameEvents.Subscribe("IMBAHeroSelection_PlayerSelectedHero", UpdateSelectButton);
GameEvents.Subscribe("IMBAHeroSelection_UpdateTimer", UpdateTimer);
GameEvents.Subscribe("IMBAHeroSelection_SelectionDone", SelectionDone);
GameEvents.Subscribe("IMBAHeroSelection_ChangePhase", ChangeSelectionPhase);

// "IMBA_TIME_10"
// "IMBA_TIME_5"
// "IMBA_TIME_RESERVE" bei yong shi jian
// "IMBA_SELECTION_BAN_DIRE" dire ban
// "IMBA_SELECTION_BAN_RADIANT" radiant ban
// "IMBA_SELECTION_PICK_DIRE" dire pick
// "IMBA_SELECTION_PICK_RADIANT" radiant pick
// "IMBA_SELECTION_MODE_CM" dui zhang mo shi -CM "DOTA_GameMode_CaptainsMode"
// "IMBA_SELECTION_MODE_RD" sui ji zheng zhao -RD "DOTA_GameMode_RandomDraft"
// "IMBA_SELECTION_MODE_AP" -AP "DOTA_GameMode_AllPick"
// "IMBA_SELECTION_MODE_31" san xuan yi "DOTA_GameMode_SingleDraft"
// "Please_Wait"