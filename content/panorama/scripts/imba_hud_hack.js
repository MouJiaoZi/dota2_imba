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

