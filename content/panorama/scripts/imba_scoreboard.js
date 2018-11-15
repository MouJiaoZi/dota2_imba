
"use strict";

var bUpdataPanel = false;

var teamContainer = [];
teamContainer[2] = $("#IMBARadiantTeamContainer");
teamContainer[3] = $("#IMBADireTeamContainer");

function ToggleScoreBoard(bVisible)
{
	$.GetContextPanel().SetHasClass("flyout_scoreboard_visible", bVisible);
	updataScoreBoard();
}

function InitScoreBoard()
{
	var clientTeam = null;
	for(var i=0; i<=19; i++)
	{
		var playerInfo = Game.GetPlayerInfo(i);
		if(playerInfo != undefined && playerInfo.player_is_local)
		{
			clientTeam = playerInfo.player_team_id;
			break;
		}
	}
	for(var i=0; i<=19; i++)
	{
		var playerInfo = Game.GetPlayerInfo(i);
		if(playerInfo != undefined)
		{
			var playerID = playerInfo.player_id;
			var playerScore = $.CreatePanel("Panel", teamContainer[playerInfo.player_team_id], "IMBAScoreBoard_Player_" + playerID);
			playerScore.SetAttributeInt("player_id", playerID);
			playerScore.BLoadLayout("file://{resources}/layout/custom_game/imba_scoreboard_player.xml", false, false);

			playerScore.FindChild("IMBAPlayerColor").style.backgroundColor=GameUI.CustomUIConfig().player_colors[playerID]; 
			playerScore.FindChild("IMBAPlayerAvtar").steamid=playerInfo.player_steamid;
			playerScore.FindChild("IMBAPlayerHero").heroname=playerInfo.player_selected_hero;
			playerScore.FindChildTraverse("IMBAPlayerName").text=playerInfo.player_name;
			playerScore.FindChildTraverse("IMBAPlayerHeroName").text=$.Localize(playerInfo.player_selected_hero);

			if(playerInfo.player_is_local)
			{
				playerScore.FindChild("IMBAPlayerShare").style.opacity="0;";
			}
			if(playerInfo.player_team_id != clientTeam)
			{
				playerScore.FindChildTraverse("IMBAPlayerGold").style.opacity="0;";
				playerScore.FindChildTraverse("IMBAUltICON").style.opacity="0;";
				playerScore.FindChildTraverse("IMBAUnitControlButton").style.opacity="0;";
				playerScore.FindChildTraverse("IMBAHeroControlButton").style.opacity="0;";
				playerScore.FindChildTraverse("IMBADisableHelpButton").style.opacity="0;";
			}
		}
	}
}

function updataScoreBoard()
{
	var base = $.GetContextPanel().FindChildTraverse("IMBABackground");
	var kills = [];
	kills[2] = 0;
	kills[3] = 0;
	if(base == null) return;
	if($.GetContextPanel().BHasClass("flyout_scoreboard_visible"))
	{
		$.Schedule(1.0, updataScoreBoard);
	}
	for(var i=0; i<=19; i++)
	{
		var playerPanel = base.FindChildTraverse("IMBAScoreBoard_Player_"+i);
		if(playerPanel != null)
		{
			var playerInfo = Game.GetPlayerInfo(i);
			kills[playerInfo.player_team_id] = kills[playerInfo.player_team_id] + playerInfo.player_kills;
			playerPanel.FindChild("IMBAPlayerHero").heroname=playerInfo.player_selected_hero;
			playerPanel.FindChildTraverse("IMBAPlayerName").text=playerInfo.player_name;
			playerPanel.FindChildTraverse("IMBAPlayerHeroName").text=$.Localize(playerInfo.player_selected_hero);
			playerPanel.FindChildTraverse("IMBAPlayerLevel").text=playerInfo.player_level;
			playerPanel.FindChildTraverse("IMBAPlayerGold").text=playerInfo.player_gold;
			playerPanel.FindChildTraverse("IMBAPlayerKills").text=playerInfo.player_kills;
			playerPanel.FindChildTraverse("IMBAPlayerDeaths").text=playerInfo.player_deaths;
			playerPanel.FindChildTraverse("IMBAPlayerAssists").text=playerInfo.player_assists;

			var playerHero = playerInfo.player_selected_hero_entity_index;
			var ult = Entities.GetAbility(playerHero, 5);
			var ultPanel = playerPanel.FindChildTraverse("IMBAUltICON");
			if(Abilities.GetLevel(ult) == 0)
			{
				ultPanel.SetHasClass("UltLearned", false);
				ultPanel.SetHasClass("UltOnCooldown", false);
				ultPanel.SetHasClass("UltReady", false);
				ultPanel.SetHasClass("UltReadyNoMana", false);
			}
			if(Abilities.GetLevel(ult) > 0 && Abilities.IsCooldownReady(ult) && Abilities.IsOwnersManaEnough(ult))
			{
				ultPanel.SetHasClass("UltLearned", true);
				ultPanel.SetHasClass("UltOnCooldown", false);
				ultPanel.SetHasClass("UltReady", true);
				ultPanel.SetHasClass("UltReadyNoMana", false);
			}
			if(Abilities.GetLevel(ult) > 0 && Abilities.IsCooldownReady(ult) && !Abilities.IsOwnersManaEnough(ult))
			{
				ultPanel.SetHasClass("UltLearned", true);
				ultPanel.SetHasClass("UltOnCooldown", false);
				ultPanel.SetHasClass("UltReady", false);
				ultPanel.SetHasClass("UltReadyNoMana", true);
			}
			if(Abilities.GetLevel(ult) > 0 && !Abilities.IsCooldownReady(ult) && !Abilities.IsOwnersManaEnough(ult))
			{
				ultPanel.SetHasClass("UltLearned", true);
				ultPanel.SetHasClass("UltOnCooldown", false);
				ultPanel.SetHasClass("UltReady", false);
				ultPanel.SetHasClass("UltReadyNoMana", true);
			}
			if(Abilities.GetLevel(ult) > 0 && !Abilities.IsCooldownReady(ult) && Abilities.IsOwnersManaEnough(ult))
			{
				ultPanel.SetHasClass("UltLearned", true);
				ultPanel.SetHasClass("UltOnCooldown", true);
				ultPanel.SetHasClass("UltReady", false);
				ultPanel.SetHasClass("UltReadyNoMana", false);
			}
		}
	}
	base.FindChildTraverse("IMBARadiantScoreLabel").text=kills[2];
	base.FindChildTraverse("IMBADireScoreLabel").text=kills[3];
}
$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), ToggleScoreBoard); 


InitScoreBoard(); 
updataScoreBoard();
//{"player_id":0,"player_name":"function fgnb() return true end","player_connection_state":2,"player_steamid":"76561198097609945","player_kills":0,"player_deaths":0,"player_assists":0,"player_selected_hero_id":35,"player_selected_hero":"npc_dota_hero_sniper","player_selected_hero_entity_index":662,"possible_hero_selection":"","player_level":5,"player_respawn_seconds":-1,"player_gold":2000,"player_team_id":2,"player_is_local":true,"player_has_host_privileges":true}




function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false );      //Lefthand flyout scoreboard.

var CombatLogButton = FindDotaHudElement("CombatLogButton");
var contentButton = FindDotaHudElement("SharedContentButton");
var buttonBar = FindDotaHudElement("ButtonBar");
var beforebutton = FindDotaHudElement("ToggleScoreboardButton");
CombatLogButton.SetParent(buttonBar);
CombatLogButton.MoveChildAfter(buttonBar, beforebutton);