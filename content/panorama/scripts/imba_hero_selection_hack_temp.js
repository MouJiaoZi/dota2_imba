/*
function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
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
FindDotaHudElement("PreGame").FindChildTraverse("Header").style.visibility = "collapse";
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
enemyIcon.FindChildTraverse("PredictEnemyHeroes").style.height = "80px";
enemyIcon.FindChildTraverse("PredictEnemyHeroes").style.width = "232px";

var pa = FindDotaHudElement("PreGame");

function PickButtonHitCheck()
{
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	var hero = "npc_dota_hero_"+localPlayerInfo.possible_hero_selection;
	var ability = CustomNetTables.GetTableValue("imba_hero_selection_ability", hero);
	var talent = CustomNetTables.GetTableValue("imba_hero_selection_talent", hero);
	$.Msg(ability);
	$.Msg(talent);
}


GameEvents.Subscribe( "dota_player_hero_selection_dirty", PickButtonHitCheck );
pa.style.visibility = "visible";*/
//pa.style.width = "0%";
//pa.style.height = "0%";
