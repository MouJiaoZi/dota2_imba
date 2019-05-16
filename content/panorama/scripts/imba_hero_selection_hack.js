//var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
//var TopRadiant = BaseHud.FindChildTraverse("TopBarRadiantPlayersContainer");
//TopRadiant.setAttribute("width", "100px");

// 0 = non IMBA 1 = Full IMBA 2 = Half IMBA 3 = is Going to IMBA

var HeroCardStyle = 
[
"#000000aa -2px -2px 4px 4px",
"#FF7800aa -5px -5px 10px 10px",
"#FF0023aa -5px -5px 10px 10px",
"#0BDFF3aa -5px -5px 10px 10px",
];

var IMBAHeroes =
[
["npc_dota_hero_alchemist", 0],
["npc_dota_hero_ancient_apparition", 0],
["npc_dota_hero_antimage", 1],
["npc_dota_hero_axe", 1],
["npc_dota_hero_bane", 1],
["npc_dota_hero_beastmaster", 0],
["npc_dota_hero_bloodseeker", 0],
["npc_dota_hero_chen", 0],
["npc_dota_hero_crystal_maiden", 1],
["npc_dota_hero_dark_seer", 2],
["npc_dota_hero_dazzle", 1],
["npc_dota_hero_dragon_knight", 0],
["npc_dota_hero_doom_bringer", 2],
["npc_dota_hero_drow_ranger", 1],
["npc_dota_hero_earthshaker", 2],
["npc_dota_hero_enchantress", 0],
["npc_dota_hero_enigma", 1],
["npc_dota_hero_faceless_void", 1],
["npc_dota_hero_furion", 2],
["npc_dota_hero_juggernaut", 1],
["npc_dota_hero_kunkka", 1],
["npc_dota_hero_leshrac", 0],
["npc_dota_hero_lich", 1],
["npc_dota_hero_life_stealer", 0],
["npc_dota_hero_lina", 1],
["npc_dota_hero_lion", 1],
["npc_dota_hero_mirana", 1],
["npc_dota_hero_morphling", 2],
["npc_dota_hero_necrolyte", 2],
["npc_dota_hero_nevermore", 1],
["npc_dota_hero_night_stalker", 1],
["npc_dota_hero_omniknight", 1],
["npc_dota_hero_puck", 2],
["npc_dota_hero_pudge", 1],
["npc_dota_hero_pugna", 1],
["npc_dota_hero_rattletrap", 1],
["npc_dota_hero_razor", 0],
["npc_dota_hero_riki", 2],
["npc_dota_hero_sand_king", 1],
["npc_dota_hero_shadow_shaman", 0],
["npc_dota_hero_slardar", 0],
["npc_dota_hero_sniper", 1],
["npc_dota_hero_spectre", 2],
["npc_dota_hero_storm_spirit", 1],
["npc_dota_hero_sven", 1],
["npc_dota_hero_tidehunter", 0],
["npc_dota_hero_tinker", 1],
["npc_dota_hero_tiny", 0],
["npc_dota_hero_vengefulspirit", 1],
["npc_dota_hero_venomancer", 1],
["npc_dota_hero_viper", 0],
["npc_dota_hero_weaver", 0],
["npc_dota_hero_windrunner", 0],
["npc_dota_hero_witch_doctor", 1],
["npc_dota_hero_zuus", 0],
["npc_dota_hero_broodmother", 1],
["npc_dota_hero_skeleton_king", 1],
["npc_dota_hero_queenofpain", 1],
["npc_dota_hero_huskar", 2],
["npc_dota_hero_jakiro", 1],
["npc_dota_hero_batrider", 0],
["npc_dota_hero_warlock", 1],
["npc_dota_hero_death_prophet", 0],
["npc_dota_hero_ursa", 0],
["npc_dota_hero_bounty_hunter", 1],
["npc_dota_hero_silencer", 0],
["npc_dota_hero_spirit_breaker", 0],
["npc_dota_hero_invoker", 2],
["npc_dota_hero_clinkz", 1],
["npc_dota_hero_obsidian_destroyer", 1],
["npc_dota_hero_shadow_demon", 0],
["npc_dota_hero_lycan", 0],
["npc_dota_hero_lone_druid", 0],
["npc_dota_hero_brewmaster", 0],
["npc_dota_hero_phantom_lancer", 0],
["npc_dota_hero_treant", 0],
["npc_dota_hero_ogre_magi", 2],
["npc_dota_hero_chaos_knight", 2],
["npc_dota_hero_phantom_assassin", 1],
["npc_dota_hero_gyrocopter", 0],
["npc_dota_hero_rubick", 2],
["npc_dota_hero_luna", 2],
["npc_dota_hero_wisp", 0],
["npc_dota_hero_disruptor", 1],
["npc_dota_hero_undying", 0],
["npc_dota_hero_templar_assassin", 2],
["npc_dota_hero_naga_siren", 0],
["npc_dota_hero_nyx_assassin", 1],
["npc_dota_hero_keeper_of_the_light", 0],
["npc_dota_hero_visage", 2],
["npc_dota_hero_meepo", 0],
["npc_dota_hero_magnataur", 1],
["npc_dota_hero_centaur", 1],
["npc_dota_hero_slark", 2],
["npc_dota_hero_shredder", 0],
["npc_dota_hero_medusa", 0],
["npc_dota_hero_troll_warlord", 1],
["npc_dota_hero_tusk", 0],
["npc_dota_hero_bristleback", 2],
["npc_dota_hero_skywrath_mage", 1],
["npc_dota_hero_elder_titan", 0],
["npc_dota_hero_abaddon", 1],
["npc_dota_hero_earth_spirit", 1],
["npc_dota_hero_ember_spirit", 1],
["npc_dota_hero_legion_commander", 0],
["npc_dota_hero_phoenix", 0],
["npc_dota_hero_terrorblade", 0],
["npc_dota_hero_techies", 1],
["npc_dota_hero_oracle", 2],
["npc_dota_hero_winter_wyvern", 0],
["npc_dota_hero_arc_warden", 0],
["npc_dota_hero_abyssal_underlord", 0],
["npc_dota_hero_monkey_king", 0],
["npc_dota_hero_pangolier", 2],
["npc_dota_hero_dark_willow", 0],
["npc_dota_hero_mars", 0],
["npc_dota_hero_grimstroke", 0]
];

var OMGHeroes = 
["npc_dota_hero_abaddon",
"npc_dota_hero_alchemist",
"npc_dota_hero_ancient_apparition",
"npc_dota_hero_antimage",
"npc_dota_hero_axe",
"npc_dota_hero_bane",
"npc_dota_hero_bounty_hunter",
"npc_dota_hero_centaur",
"npc_dota_hero_chaos_knight",
"npc_dota_hero_crystal_maiden",
"npc_dota_hero_dazzle",
"npc_dota_hero_dragon_knight",
"npc_dota_hero_drow_ranger",
"npc_dota_hero_earthshaker",
"npc_dota_hero_jakiro",
"npc_dota_hero_juggernaut",
"npc_dota_hero_kunkka",
"npc_dota_hero_lich",
"npc_dota_hero_lina",
"npc_dota_hero_lion",
"npc_dota_hero_luna",
"npc_dota_hero_medusa",
"npc_dota_hero_mirana",
"npc_dota_hero_naga_siren",
"npc_dota_hero_furion",
"npc_dota_hero_necrolyte",
"npc_dota_hero_obsidian_destroyer",
"npc_dota_hero_omniknight",
"npc_dota_hero_phantom_assassin",
"npc_dota_hero_phantom_lancer",
"npc_dota_hero_phoenix",
"npc_dota_hero_puck",
"npc_dota_hero_queenofpain",
"npc_dota_hero_sand_king",
"npc_dota_hero_shadow_demon",
"npc_dota_hero_nevermore",
"npc_dota_hero_slark",
"npc_dota_hero_sniper",
"npc_dota_hero_storm_spirit",
"npc_dota_hero_sven",
"npc_dota_hero_templar_assassin",
"npc_dota_hero_terrorblade",
"npc_dota_hero_tinker",
"npc_dota_hero_ursa",
"npc_dota_hero_vengefulspirit",
"npc_dota_hero_venomancer",
"npc_dota_hero_wisp",
"npc_dota_hero_witch_doctor",
"npc_dota_hero_zuus",
"npc_dota_hero_mars"];

/*var heroArray = new Array();
var heroType = new Array();

for(var i=0; i<IMBAHeroes.length; i++)
{
	heroArray[i] = IMBAHeroes[i][0];
	heroType[i] = IMBAHeroes[i][1];
}*/

var enable31 = CustomNetTables.GetTableValue("imba_omg", "enable_31").enable;

var str = CustomNetTables.GetTableValue("imba_hero_selection_list", "str");
var agi = CustomNetTables.GetTableValue("imba_hero_selection_list", "agi");
var int = CustomNetTables.GetTableValue("imba_hero_selection_list", "int");

var player_heroes = [];
var teammates_heroes = [];

if(!Players.IsSpectator(Players.GetLocalPlayer()))
{
	player_heroes.push(str[Players.GetLocalPlayer() + 1]);
	player_heroes.push(agi[Players.GetLocalPlayer() + 1]);
	player_heroes.push(int[Players.GetLocalPlayer() + 1]);
	for(var i=0; i<=19; i++)
	{
		if(Players.GetLocalPlayer() != i && Players.IsValidPlayerID(i) && Players.GetTeam(Players.GetLocalPlayer()) == Players.GetTeam(i))
		//if(Players.GetLocalPlayer() != i)
		{
			teammates_heroes.push(str[i + 1]);
			teammates_heroes.push(agi[i + 1]);
			teammates_heroes.push(int[i + 1]);
		}
	}
}

$.Schedule(0.1, PickButtonHitCheck);

function PickButtonHitCheck()
{
	if(Game.GameStateIs(3) && enable31 == 1)
	{
		var txt = FindDotaHudElement("HeroInspectHeroName").text
		var button = FindDotaHudElement("LockInButton");
		for(var i=0; i<player_heroes.length; i++)
		{
			if($.Localize(player_heroes[i]).search(txt) != -1)
			{
				button.style.washColor = "#FFFFFF00";
				button.hittest = true;
				button.enabled = true;
				break;
			}
			else
			{
				button.style.washColor = "#000000E7";
				button.hittest = (Game.GetAllPlayerIDs().length <= 2);
				button.enabled = (Game.GetAllPlayerIDs().length <= 2);
			}
		}
		$.Schedule(0.01, PickButtonHitCheck);
	}
}

var total;
var current = 0;


function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

function FillTopBarPlayer() 
{
	FindDotaHudElement('IMBA_CLICK_BLOCKER').style.opacity = "1.0";
	var herocard = FindDotaHudElement('GridCore');
	total = herocard.GetChildCount();
	var delay = 0.03;
	if(Game.IsInToolsMode())
	{
		delay = 0;
	}
	for(var i=0; i<total; i++)
	{
		$.Schedule((delay * i), UpdateHeroCard);
	}
	$.Schedule((delay * (i + 3)), ReEnablePickButton);
}

function ReEnablePickButton()
{
	FindDotaHudElement('IMBA_CLICK_BLOCKER').style.opacity = "0.0";
	FindDotaHudElement('IMBA_CLICK_BLOCKER').style.height = "0%";
	FindDotaHudElement('IMBA_CLICK_BLOCKER').style.width = "0%";
}

function UpdateHeroCard() 
{
	current = current + 1;
	var herocard = FindDotaHudElement('GridCore');
	var heroIMG = herocard.GetChild(current - 1).FindChildTraverse("HeroImage");
	if(heroIMG)
	{
		var heroName = heroIMG.heroname;
		for(var j=0; j<IMBAHeroes.length; j++)
		{
			var hero = IMBAHeroes[j][0];
			if(hero.search(heroName) != -1)
			{
				if(enable31 == 1)
				{
					heroIMG.GetParent().style.boxShadow = "#FF0000C4 0px 0px 0px 0px";
					heroIMG.GetParent().style.washColor = "#000000F3";
					heroIMG.GetParent().GetParent().FindChildTraverse("HitTarget").style.opacity = "0.0";
					heroIMG.GetParent().GetParent().FindChildTraverse("HitBlocker").style.visibility = "visible";
					for(var k=0; k<teammates_heroes.length; k++)
					{
						if(teammates_heroes[k].search(heroName) != -1)
						{
							heroIMG.GetParent().style.washColor = "#000000A3";
							heroIMG.GetParent().style.boxShadow = "#FFE700CB -5px -5px 10px 10px";
							heroIMG.GetParent().GetParent().FindChildTraverse("HitTarget").style.opacity = "1.0";
							heroIMG.GetParent().GetParent().FindChildTraverse("HitBlocker").style.visibility = "collapse";
							heroIMG.GetParent().GetParent().FindChildTraverse("SuggestedOverlay").GetChild(0).style.verticalAlign = "top";
							heroIMG.GetParent().GetParent().FindChildTraverse("SuggestedOverlay").GetChild(0).style.marginTop = "15%";
							break;
						}
					}
					if(str[Players.GetLocalPlayer() + 1].search(heroName) != -1 || agi[Players.GetLocalPlayer() + 1].search(heroName) != -1 || int[Players.GetLocalPlayer() + 1].search(heroName) != -1)
					{
						//$.Msg(heroName);
						heroIMG.GetParent().GetParent().FindChildTraverse("SuggestedBanOverlay").style.opacity = "1.0";
						heroIMG.GetParent().GetParent().FindChildTraverse("SuggestedBanOverlay").GetChild(0).style.verticalAlign = "top";
						heroIMG.GetParent().GetParent().FindChildTraverse("SuggestedBanOverlay").GetChild(0).style.marginTop = "15%";
						heroIMG.GetParent().GetParent().FindChildTraverse("SuggestedOverlay").GetChild(0).style.verticalAlign = "top";
						heroIMG.GetParent().GetParent().FindChildTraverse("SuggestedOverlay").GetChild(0).style.marginTop = "25%";
						heroIMG.GetParent().GetParent().FindChildTraverse("HitTarget").style.opacity = "1.0";
						heroIMG.GetParent().GetParent().FindChildTraverse("HitBlocker").style.visibility = "collapse";
						heroIMG.GetParent().style.washColor = "#FFFFFF00";
						heroIMG.GetParent().style.boxShadow = "#FF0000C4 -8px -8px 16px 16px";
					}
					/**if(Game.GetMapInfo().map_display_name == "dbii_death_match" && CustomNetTables.GetTableValue("imba_omg", "enable_omg").enable == 1)
					{
						heroIMG.GetParent().GetParent().FindChildTraverse("HitTarget").visible = 0;
						heroIMG.GetParent().GetParent().FindChildTraverse("HitBlocker").visible = 1;
					}*/
					break;
				}
				else
				{
					heroIMG.GetParent().AddClass("IMBA_HeroCard");
					heroIMG.GetParent().style.boxShadow=HeroCardStyle[IMBAHeroes[j][1]];
					break;
				}
				
			}
		}
	}
}


if(!Players.IsSpectator(Players.GetLocalPlayer()))
{
	FillTopBarPlayer() ;
}

FindDotaHudElement("BattlePassHeroUpsell").style.width = "0%";
FindDotaHudElement("BattlePassHeroUpsell").style.height = "0%";
FindDotaHudElement("BattlePassHeroData").style.width = "0%";
FindDotaHudElement("BattlePassHeroData").style.height = "0%";
FindDotaHudElement("ToGameTransition").style.width = "0%";
FindDotaHudElement("ToGameTransition").style.height = "0%";
FindDotaHudElement("HeroRoles").style.width = "0%";
FindDotaHudElement("HeroRoles").style.height = "0%";
FindDotaHudElement("HeroPickTeamComposition").FindChildTraverse("RoleColumnContainer").style.width = "0%";
FindDotaHudElement("HeroPickTeamComposition").FindChildTraverse("RoleColumnContainer").style.height = "0%";
FindDotaHudElement("HeroPickTeamComposition").FindChildTraverse("MeleeLabel").hittest = false;
FindDotaHudElement("HeroPickTeamComposition").FindChildTraverse("RangedLabel").hittest = false;
FindDotaHudElement("HeroFilters").style.width = "0%";
FindDotaHudElement("HeroFilters").style.height = "0%";
////////
FindDotaHudElement("StrategyTeamComposition").FindChildTraverse("RoleColumnContainer").style.width = "0%";
FindDotaHudElement("StrategyTeamComposition").FindChildTraverse("RoleColumnContainer").style.height = "0%";
FindDotaHudElement("StrategyTeamComposition").FindChildTraverse("MeleeLabel").hittest = false;
FindDotaHudElement("StrategyTeamComposition").FindChildTraverse("RangedLabel").hittest = false;

var allyIcon = FindDotaHudElement("AllyHeroesStrategyControl");
allyIcon.style.marginBottom = "0px";
allyIcon.GetChild(0).style.height = "30px"
allyIcon.GetChild(0).GetChild(2).style.width = "80px"
allyIcon.FindChildTraverse("AllyHeroes").style.flowChildren = "right-wrap";
allyIcon.FindChildTraverse("AllyHeroes").style.height = "70px"
allyIcon.FindChildTraverse("AllyHeroes").style.width = "232px"

var enemyIcon = FindDotaHudElement("PredictEnemyHeroesStrategyControl");
enemyIcon.style.marginBottom = "0px";
enemyIcon.GetChild(0).style.height = "30px"
enemyIcon.GetChild(0).GetChild(2).style.width = "70px"
enemyIcon.FindChildTraverse("PredictEnemyHeroes").style.flowChildren = "right-wrap";
enemyIcon.FindChildTraverse("PredictEnemyHeroes").style.height = "80px"
enemyIcon.FindChildTraverse("PredictEnemyHeroes").style.width = "232px"

function SetUpHeroIcon()
{
	for(var i=0; i<=9; i++)
	{
		var icon = allyIcon.FindChildTraverse("AllyHeroes").GetChild(i);
		if(icon)
		{
			icon.style.width = "38px";
			icon.style.height = "35px";
			icon.style.marginRight = "8px";
			icon.style.horizontalAlign = "center";
		}
	}
	for(var i=0; i<=9; i++)
	{
		var icon = enemyIcon.FindChildTraverse("PredictEnemyHeroes").GetChild(i);
		if(icon)
		{
			//
			icon.style.width = "38px";
			icon.style.height = "35px";
			icon.style.marginRight = "8px";
			icon.style.horizontalAlign = "center";
		}
	}
	if(Game.GameStateIsBefore(7))
	{
		$.Schedule(1.0, SetUpHeroIcon);
	}
}

$.Schedule(1.0, SetUpHeroIcon);