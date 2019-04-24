//var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
//var TopRadiant = BaseHud.FindChildTraverse("TopBarRadiantPlayersContainer");
//TopRadiant.setAttribute("width", "100px");
//$.Msg(TopRadiant);

function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

function FillTopBarPlayer(TeamContainer) 
{
	// Fill players top bar in case on partial lobbies
	var playerCount = TeamContainer.GetChildCount();
	for (var i = playerCount + 1; i <= 10; i++) {
		var newPlayer = $.CreatePanel('DOTATopBarPlayer', TeamContainer, 'RadiantPlayer-1');
		if (newPlayer) {
			//newPlayer.FindChildTraverse('PlayerColor').style.backgroundColor = '#FFFFFFFF';
		}
		newPlayer.SetHasClass('EnemyTeam', true);
	}
}

function SetupTopBar()
{
	//$.GetContextPanel().SetHasClass('TenVTen', true);
	var topbar = FindDotaHudElement('topbar');
	topbar.style.width = '1550px';

	// Top Bar Radiant
	var TopBarRadiantTeam = topbar.FindChildTraverse('TopBarRadiantTeam');
	TopBarRadiantTeam.style.width = '690px';

	var topbarRadiantPlayers = topbar.FindChildTraverse('TopBarRadiantPlayers');
	topbarRadiantPlayers.style.width = '690px';

	var topbarRadiantPlayersContainer = topbar.FindChildTraverse('TopBarRadiantPlayersContainer');
	topbarRadiantPlayersContainer.style.width = '630px';
	topbarRadiantPlayersContainer.SetHasClass("LeftRightFlow", false);
	topbarRadiantPlayersContainer.style.flowChildren="left";
	FillTopBarPlayer(topbarRadiantPlayersContainer);

	//var RadiantTeamContainer = topbar.FindChildTraverse('RadiantTeamContainer');
	//RadiantTeamContainer.style.height = '737px';

	// Top Bar Dire
	var TopBarDireTeam = topbar.FindChildTraverse('TopBarDireTeam');
	TopBarDireTeam.style.width = '690px';

	var topbarDirePlayers = topbar.FindChildTraverse('TopBarDirePlayers');
	topbarDirePlayers.style.width = '690px';

	var topbarDirePlayersContainer = topbar.FindChildTraverse('TopBarDirePlayersContainer');
	topbarDirePlayersContainer.style.width = '630px';
	FillTopBarPlayer(topbarDirePlayersContainer);

	//var DireTeamContainer = topbar.FindChildTraverse('DireTeamContainer');
	//DireTeamContainer.style.height = '737px';
}

function SetupTopPlayerColor()
{
	var topbar = FindDotaHudElement('topbar');
	var topbarRadiantPlayersContainer = topbar.FindChildTraverse('TopBarRadiantPlayersContainer');
	var topRadiantCount = topbarRadiantPlayersContainer.GetChildCount();
	var topbarDirePlayersContainer = topbar.FindChildTraverse('TopBarDirePlayersContainer');
	var topDireCount = topbarDirePlayersContainer.GetChildCount();
	for(var i=0;i<topRadiantCount;i++)
	{
		var base = topbarRadiantPlayersContainer.GetChild(i);
		var playerID = base.id.replace(/[^0-9]/ig,"");
		base.FindChildTraverse("PlayerColor").style.backgroundColor = GameUI.CustomUIConfig().player_colors[playerID];
	}
	for(var i=0;i<topDireCount;i++)
	{
		var base = topbarDirePlayersContainer.GetChild(i);
		var playerID = base.id.replace(/[^0-9]/ig,"");
		base.FindChildTraverse("PlayerColor").style.backgroundColor = GameUI.CustomUIConfig().player_colors[playerID];
	}
}

SetupTopBar();
$.Schedule(1.0, SetupTopPlayerColor);

function GetLocalPlayerCursorPos(keys)
{
	var parm = keys;
	var pos = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
	if(!pos)
	{
		return;
	}
	parm.pan_x = pos[0];
	parm.pan_y = pos[1];
	parm.pan_z = pos[2];
	GameEvents.SendCustomGameEventToServer("imba_compare_cursor_pos", parm);
}

FindDotaHudElement("TopBarRadiantScore").style.textShadow = "0px 0px 6px 1.0 #9BE40C8F";
FindDotaHudElement("TopBarDireScore").style.textShadow = "0px 0px 6px 1.0 #E74D088F";

GameEvents.Subscribe("imba_compare_cursor_pos_client", GetLocalPlayerCursorPos);

function SetDeathMatchKillGoal()
{
	var DoN = FindDotaHudElement("TimeOfDay");
	var NSN_ICON = FindDotaHudElement("NightstalkerNight");
	NSN_ICON.SetParent(FindDotaHudElement("DayNightCycle"));
	//FindDotaHudElement("GameTime").MoveChildAfter(DoN, FindDotaHudElement("IMBA_DN_ICON"));
	//FindDotaHudElement("NightstalkerNight").style.width = "0px";
	//FindDotaHudElement("NightstalkerNight").style.height = "0px";

	DoN.AddClass("TopBottomFlow");
	DoN.style.height = "" + (DoN.actuallayoutheight * 2) + "px";
	FindDotaHudElement("GameTime").style.verticalAlign = "top";
	var goal = $.CreatePanel('Label', DoN, 'DM_KILL_GOAL');
	goal.text = "";
	if(Game.GetMapInfo().map_display_name == "dbii_death_match")
	{
		$.Schedule(1.0, SetDeathMatchKillGoalNum);
	}
	goal.hittest = false;
	goal.style.width = "100%";
	goal.style.fontSize = "22px";
	goal.style.fontWeight = "bold";
	goal.style.textAlign = "center";
	goal.style.color = "white";
	goal.style.textShadow = "0px 0px 6px 1.0 #FFD8008F";
}

function SetDeathMatchKillGoalNum()
{
	var table = CustomNetTables.GetTableValue("imba_omg", "death_match");
	var goal = FindDotaHudElement("DM_KILL_GOAL")
	if(table == null)
	{
		$.Schedule(1.0, SetDeathMatchKillGoalNum);
	}
	else
	{
		goal.hittest = true;
		goal.text = table.kill_goal;
		goal.SetPanelEvent("onmouseover", 
		function()
		{
			$.DispatchEvent("DOTAShowTextTooltip", goal, "#IMBA_HUD_DMKillGoalTip");
		}
		)
		goal.SetPanelEvent("onmouseout", 
			function()
			{
				$.DispatchEvent("DOTAHideTextTooltip", goal);
			}
		)
	}
}

$.Schedule(1.0, SetDeathMatchKillGoal);