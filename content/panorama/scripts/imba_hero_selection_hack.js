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
["npc_dota_hero_furion", 0],
["npc_dota_hero_juggernaut", 1],
["npc_dota_hero_kunkka", 1],
["npc_dota_hero_leshrac", 0],
["npc_dota_hero_lich", 1],
["npc_dota_hero_life_stealer", 0],
["npc_dota_hero_lina", 1],
["npc_dota_hero_lion", 1],
["npc_dota_hero_mirana", 1],
["npc_dota_hero_morphling", 0],
["npc_dota_hero_necrolyte", 1],
["npc_dota_hero_nevermore", 1],
["npc_dota_hero_night_stalker", 1],
["npc_dota_hero_omniknight", 1],
["npc_dota_hero_puck", 0],
["npc_dota_hero_pudge", 1],
["npc_dota_hero_pugna", 1],
["npc_dota_hero_rattletrap", 0],
["npc_dota_hero_razor", 0],
["npc_dota_hero_riki", 0],
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
["npc_dota_hero_broodmother", 0],
["npc_dota_hero_skeleton_king", 1],
["npc_dota_hero_queenofpain", 1],
["npc_dota_hero_huskar", 0],
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
["npc_dota_hero_disruptor", 0],
["npc_dota_hero_undying", 0],
["npc_dota_hero_templar_assassin", 2],
["npc_dota_hero_naga_siren", 0],
["npc_dota_hero_nyx_assassin", 1],
["npc_dota_hero_keeper_of_the_light", 0],
["npc_dota_hero_visage", 0],
["npc_dota_hero_meepo", 0],
["npc_dota_hero_magnataur", 1],
["npc_dota_hero_centaur", 1],
["npc_dota_hero_slark", 2],
["npc_dota_hero_shredder", 0],
["npc_dota_hero_medusa", 0],
["npc_dota_hero_troll_warlord", 1],
["npc_dota_hero_tusk", 0],
["npc_dota_hero_bristleback", 0],
["npc_dota_hero_skywrath_mage", 1],
["npc_dota_hero_elder_titan", 0],
["npc_dota_hero_abaddon", 1],
["npc_dota_hero_earth_spirit", 1],
["npc_dota_hero_ember_spirit", 1],
["npc_dota_hero_legion_commander", 0],
["npc_dota_hero_phoenix", 0],
["npc_dota_hero_terrorblade", 0],
["npc_dota_hero_techies", 1],
["npc_dota_hero_oracle", 0],
["npc_dota_hero_winter_wyvern", 0],
["npc_dota_hero_arc_warden", 0],
["npc_dota_hero_abyssal_underlord", 0],
["npc_dota_hero_monkey_king", 0],
["npc_dota_hero_pangolier", 0],
["npc_dota_hero_dark_willow", 0],
["npc_dota_hero_grimstroke", 0]
];

/*var heroArray = new Array();
var heroType = new Array();

for(var i=0; i<IMBAHeroes.length; i++)
{
	heroArray[i] = IMBAHeroes[i][0];
	heroType[i] = IMBAHeroes[i][1];
}

//$.Msg(IMBAHeroes[2][0]);*/

var total;
var current = 0;


function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

function FillTopBarPlayer() 
{
	var herocard = FindDotaHudElement('GridCore');
	total = herocard.GetChildCount();
	for(var i=0; i<total; i++)
	{
		$.Schedule((0.01 * i), UpdateHeroCard);
	}
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
				heroIMG.GetParent().AddClass("IMBA_HeroCard");
				heroIMG.GetParent().style.boxShadow=HeroCardStyle[IMBAHeroes[j][1]];
				break;
			}
		}
	}
}


FillTopBarPlayer() ;