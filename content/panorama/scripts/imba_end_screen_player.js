var playerPanel = $.GetContextPanel();
var i





function updataPlayerInfo()
{
	var playerInfo = Game.GetPlayerInfo(i);
	//playerPanel.FindChild("IMBAPlayerHero").heroname=playerInfo.player_selected_hero;
	//playerPanel.FindChildTraverse("IMBAPlayerName").text=playerInfo.player_name;
	//playerPanel.FindChildTraverse("IMBAPlayerHeroName").text=$.Localize(playerInfo.player_selected_hero);
	//playerPanel.FindChildTraverse("IMBAPlayerLevel").text=playerInfo.player_level;
	playerPanel.FindChildTraverse("IMBAPlayerKills").text=playerInfo.player_kills;
	playerPanel.FindChildTraverse("IMBAPlayerDeaths").text=playerInfo.player_deaths;
	playerPanel.FindChildTraverse("IMBAPlayerAssists").text=playerInfo.player_assists;
	
	var playerInfoTable = CustomNetTables.GetTableValue("imba_player_info", i.toString());

	if(playerInfoTable != null)
	{
		playerPanel.FindChildTraverse("IMBAPlayerGold").text = playerInfoTable[1];
		for(var j=0;j<=8;j++)
		{
			var item = playerInfoTable[j+2];
			playerPanel.FindChildTraverse("IMBAItem_"+j).itemname = item;
		}
	}
	else
	{
		GameEvents.SendCustomGameEventToServer("update_imba_player_info", {});
		$.Schedule(0.5, updataPlayerInfo);
	}
}

function start()
{
	i = playerPanel.GetAttributeInt("player_id", 0);
	if(i == null)
	{
		$.Schedule(0.5, start);
	}
	else
	{
		updataPlayerInfo();
	}
}

start();