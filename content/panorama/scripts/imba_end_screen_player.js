var playerPanel = $.GetContextPanel();
var i





function updataPlayerInfo()
{
	var playerInfoTable = CustomNetTables.GetTableValue("imba_hero_end_info", i.toString());
	playerPanel.FindChildTraverse("IMBAPlayerKills").text=Players.GetKills(i);
	playerPanel.FindChildTraverse("IMBAPlayerDeaths").text=Players.GetDeaths(i);
	playerPanel.FindChildTraverse("IMBAPlayerAssists").text=Players.GetAssists(i);

	if(Players.GetLocalPlayer() == i)
	{
		playerPanel.FindChildTraverse("IMBAPlayerAndHeroName").style.washColor = GameUI.CustomUIConfig().player_colors[i] + "FF";// + " -3px -3px 6px 6px";
	}

	if(playerInfoTable != null)
	{
		playerPanel.FindChildTraverse("IMBAPlayerGold").text = playerInfoTable.player_gold;
		playerPanel.FindChildTraverse("IMBAPlayerLevel").text=playerInfoTable.hero_level;
		for(var j=0;j<=8;j++)
		{
			var item = playerInfoTable["item_"+j];
			var stack = playerInfoTable["item_charges_"+j];
			var itemPanel = playerPanel.FindChildTraverse("IMBAItem_"+j); 
			itemPanel.itemname = item;
			if(stack > 1 && item != "item_imba_dummy")
			{
				itemPanel.FindChildTraverse("IMBAItemStackText").text = stack;
			}
			else
			{
				itemPanel.FindChildTraverse("IMBAItemStackText").style.opacity="0";
			}
		}
		var scepter = playerInfoTable.scepter_consumed; 
		var moon = playerInfoTable.moon_consumed;
		if(scepter == 0)
		{
			playerPanel.FindChildTraverse("IMBAItem_Scepter").style.washColor="#000000EE";
			playerPanel.FindChildTraverse("IMBAItem_Scepter").FindChildTraverse("IMBAItemStackText").text="×";
		}
		else
		{
			playerPanel.FindChildTraverse("IMBAItem_Scepter").style.washColor="#00000000";
			playerPanel.FindChildTraverse("IMBAItem_Scepter").FindChildTraverse("IMBAItemStackText").text="√";
		}
		playerPanel.FindChildTraverse("IMBAItem_Moon").FindChildTraverse("IMBAItemStackText").text=moon;
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