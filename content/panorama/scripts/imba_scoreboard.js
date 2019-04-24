
"use strict";

var bUpdataPanel = false;

var teamContainer = [];
teamContainer[2] = $("#IMBARadiantTeamContainer");
teamContainer[3] = $("#IMBADireTeamContainer");

function UpdateHeroCustomNetTable()
{
	GameEvents.SendCustomGameEventToServer("update_scoreboard_hero", {});
}

function ToggleScoreBoard(bVisible)
{
	$.GetContextPanel().SetHasClass("flyout_scoreboard_visible", bVisible);
	if(bVisible)
	{
		UpdateHeroCustomNetTable();
		UpdateScoreBoard();
	}
}

function SetUltimateIconState(playerScorePanel, iState)
{
	var ultPanel = playerScorePanel.FindChildTraverse("IMBAUltICON");
	if(iState <= 1)
	{
		ultPanel.SetHasClass("UltLearned", false);
		ultPanel.SetHasClass("UltOnCooldown", false);
		ultPanel.SetHasClass("UltReady", false);
		ultPanel.SetHasClass("UltReadyNoMana", false);
	}
	if(iState == 2)
	{
		ultPanel.SetHasClass("UltLearned", true);
		ultPanel.SetHasClass("UltOnCooldown", false);
		ultPanel.SetHasClass("UltReady", true);
		ultPanel.SetHasClass("UltReadyNoMana", false);
	}
	if(iState == 3)
	{
		ultPanel.SetHasClass("UltLearned", true);
		ultPanel.SetHasClass("UltOnCooldown", false);
		ultPanel.SetHasClass("UltReady", false);
		ultPanel.SetHasClass("UltReadyNoMana", true);
	}
	if(iState == 4)
	{
		ultPanel.SetHasClass("UltLearned", true);
		ultPanel.SetHasClass("UltOnCooldown", false);
		ultPanel.SetHasClass("UltReady", false);
		ultPanel.SetHasClass("UltReadyNoMana", true);
	}
	if(iState == 5)
	{
		ultPanel.SetHasClass("UltLearned", true);
		ultPanel.SetHasClass("UltOnCooldown", true);
		ultPanel.SetHasClass("UltReady", false);
		ultPanel.SetHasClass("UltReadyNoMana", false);
	}
}

function UpdateScoreBoard()
{
	var base = $.GetContextPanel().FindChildTraverse("IMBABackground");
	if(base == null) return;
	if($.GetContextPanel().BHasClass("flyout_scoreboard_visible"))
	{
		$.Schedule(1.0, UpdateScoreBoard);
	}

	UpdateHeroCustomNetTable();

	var clientID = Players.GetLocalPlayer();
	var clientTeam = Players.GetTeam(clientID);

	for(var i=0; i<=19; i++)
	{
		var playerTable = CustomNetTables.GetTableValue("imba_player_detail", i.toString());
		var heroTable = CustomNetTables.GetTableValue("imba_scoreboard_detail", i.toString());
		if(playerTable && heroTable)
		{
			var playerID = i;
			var hero = playerTable.hero_index;
			var hero_name = playerTable.hero_name;
			var steam_id = playerTable.steamid_64;
			var player_name = playerTable.player_name;
			var team = playerTable.player_team;

			var ult_state = heroTable.ult_state;
			var level = heroTable.level;
			var gold = heroTable.gold;
			var connect = heroTable.connection_state;
			
			if(!$.GetContextPanel().FindChildTraverse("IMBAScoreBoard_Player_" + i))
			{
				var playerScore = $.CreatePanel("Panel", teamContainer[team], "IMBAScoreBoard_Player_" + playerID);
				playerScore.SetAttributeInt("player_id", playerID);
				playerScore.BLoadLayout("file://{resources}/layout/custom_game/imba_scoreboard_player.xml", false, false);

				playerScore.FindChild("IMBAPlayerColor").style.backgroundColor=GameUI.CustomUIConfig().player_colors[playerID]; 
				playerScore.FindChild("IMBAPlayerAvtar").steamid=steam_id;
				playerScore.FindChild("IMBAPlayerHero").heroname=hero_name;
				playerScore.FindChildTraverse("IMBAPlayerName").text=player_name;
				playerScore.FindChildTraverse("IMBAPlayerHeroName").text=$.Localize(hero_name);
				playerScore.FindChild("IMBAPlayerLevel").text=level;
				playerScore.FindChild("IMBAPlayerGold").text=gold;
				playerScore.FindChildTraverse("IMBAPlayerKills").text=Players.GetKills(i);
				playerScore.FindChildTraverse("IMBAPlayerDeaths").text=Players.GetDeaths(i);
				playerScore.FindChildTraverse("IMBAPlayerAssists").text=Players.GetAssists(i);
				SetUltimateIconState(playerScore, ult_state);

				if(clientID == i)
				{
					playerScore.FindChild("IMBAPlayerShare").style.opacity="0;";
				}
				if(team != clientTeam)
				{
					if(Players.IsSpectator(clientID))
					{
						playerScore.FindChildTraverse("IMBAUnitControlButton").style.opacity="0;";
						playerScore.FindChildTraverse("IMBAHeroControlButton").style.opacity="0;";
						playerScore.FindChildTraverse("IMBADisableHelpButton").style.opacity="0;";
						playerScore.FindChildTraverse("IMBAPlayerGold").style.opacity="1;";
						playerScore.FindChildTraverse("IMBAUltICON").style.opacity="1;";
					}
					else
					{
						playerScore.FindChildTraverse("IMBAUnitControlButton").style.opacity="0;";
						playerScore.FindChildTraverse("IMBAHeroControlButton").style.opacity="0;";
						playerScore.FindChildTraverse("IMBADisableHelpButton").style.opacity="0;";
						playerScore.FindChildTraverse("IMBAPlayerGold").style.opacity="0;";
						playerScore.FindChildTraverse("IMBAUltICON").style.opacity="0;";
					}
				}
			}
			else
			{
				var playerScore = $.GetContextPanel().FindChildTraverse("IMBAScoreBoard_Player_" + i);
				playerScore.FindChild("IMBAPlayerColor").style.backgroundColor=GameUI.CustomUIConfig().player_colors[playerID]; 
				playerScore.FindChild("IMBAPlayerAvtar").steamid=steam_id;
				playerScore.FindChild("IMBAPlayerHero").heroname=hero_name;
				playerScore.FindChildTraverse("IMBAPlayerName").text=player_name;
				playerScore.FindChildTraverse("IMBAPlayerHeroName").text=$.Localize(hero_name);
				playerScore.FindChild("IMBAPlayerLevel").text=level;
				playerScore.FindChild("IMBAPlayerGold").text=gold;
				playerScore.FindChildTraverse("IMBAPlayerKills").text=Players.GetKills(i);
				playerScore.FindChildTraverse("IMBAPlayerDeaths").text=Players.GetDeaths(i);
				playerScore.FindChildTraverse("IMBAPlayerAssists").text=Players.GetAssists(i);
				SetUltimateIconState(playerScore, ult_state);
				if(connect == 4)
				{
					playerScore.style.washColor = "#7F0200FF";
				}
				else
				{
					playerScore.style.washColor = "#7F020000";
				}
			}
		}
	}
	$.GetContextPanel().FindChildTraverse("IMBARadiantScoreLabel").text = Game.GetTeamDetails(2).team_score;
	$.GetContextPanel().FindChildTraverse("IMBADireScoreLabel").text = Game.GetTeamDetails(3).team_score;
}

$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), ToggleScoreBoard); 

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