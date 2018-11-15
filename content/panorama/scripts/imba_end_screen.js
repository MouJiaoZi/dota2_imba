
var teamContainer = [];
teamContainer[2] = $.GetContextPanel().FindChildTraverse("IMBAEndRadiantTeamContainer");
teamContainer[3] = $.GetContextPanel().FindChildTraverse("IMBAEndDireTeamContainer");

var winnerClass = [];
winnerClass[2] = "IMBARadiantWin";
winnerClass[3] = "IMBADireWin";

var winnerTeam = Game.GetGameWinner();
var winnerTeamDetails = Game.GetTeamDetails(winnerTeam);
$("#IMBAEndVictory").SetDialogVariable("winning_team_name", $.Localize(winnerTeamDetails.team_name));
$("#IMBAEndVictory").AddClass(winnerClass[winnerTeam]);

function InitEndBoard()
{
	for(var i=0; i<=19; i++)
	{
		var playerBaseTable = CustomNetTables.GetTableValue("imba_player_base", i.toString());
		var playerInfoTable = CustomNetTables.GetTableValue("imba_player_info", i.toString());
		if(playerBaseTable != undefined)
		{
			var playerID = i;
			var team = playerBaseTable[4]; 
			var playerScore = $.CreatePanel("Panel", teamContainer[team], "IMBAScoreBoard_Player_" + playerID);
			playerScore.SetAttributeInt("player_id", playerID);
			playerScore.BLoadLayout("file://{resources}/layout/custom_game/imba_end_screen_player.xml", false, false);

			playerScore.FindChild("IMBAPlayerColor").style.backgroundColor=GameUI.CustomUIConfig().player_colors[playerID]; 
			playerScore.FindChild("IMBAPlayerAvtar").steamid=playerBaseTable[1];
			playerScore.FindChild("IMBAPlayerHero").heroname=playerBaseTable[3];
			playerScore.FindChildTraverse("IMBAPlayerName").text=playerBaseTable[2];
			playerScore.FindChildTraverse("IMBAPlayerHeroName").text=$.Localize(playerBaseTable[3]);
		}
	}
}


function updataScoreBoard()
{
	var base = $.GetContextPanel().FindChildTraverse("IMBAEndBackgroundPanel");

	var kills = [];
	kills[2] = Game.GetTeamDetails(2).team_score;
	kills[3] = Game.GetTeamDetails(3).team_score;
	if(base == null) return;
	base.FindChildTraverse("IMBARadiantScoreLabel").text=kills[2];
	base.FindChildTraverse("IMBADireScoreLabel").text=kills[3];
}

$.Schedule(1.0, startEnd);

function startEnd()
{

	InitEndBoard();
	updataScoreBoard();

}


GameEvents.SendCustomGameEventToServer("update_imba_player_info", {});


//$.Msg(CustomNetTables.GetTableValue("imba_player_info", "11"));