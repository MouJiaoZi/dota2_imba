
function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

var local_player = Players.GetLocalPlayer();
var local_player_info = null;
if(local_player != -1)
{
	local_player_info = Game.GetPlayerInfo(local_player);
}
var team = $.GetContextPanel().GetAttributeInt("player_team", 0);
var pID = $.GetContextPanel().GetAttributeInt("player_id", -1);
var namePanel = $("#PlayerCard_PlayerName");
var heroIMGPanel = $("#PlayerCard_HeroImage");
heroIMGPanel.SetHasClass("HeroPickDirty", true);

if(team == 3)
{
	$("#PlayerCard_Border").ToggleClass("DireTeamPlayers");
	$("#PlayerCard_HeroImageContainer").ToggleClass("DireTeamPlayers");
	$("#PlayerCard_NameContainer").ToggleClass("DireTeamPlayers");
}
if(team == 2)
{
	$("#PlayerCard_NameContainer").ToggleClass("RadiantTeamPlayers");
}

function UpdatePlayerInfo()
{
	var info = Game.GetPlayerInfo(pID);
	namePanel.steamid = info.player_steamid;
	var hero_name_bot = info.player_selected_hero;
	var hero_name_dirty = CustomNetTables.GetTableValue("imba_hero_selection_player", "player_hero_dirty_"+pID);
	var hero_name_locked = CustomNetTables.GetTableValue("imba_hero_selection_player", "player_hero_selected_"+pID);
	if(info.player_connection_state == 1)
	{
		heroIMGPanel.SetHasClass("HeroPickDirty", false);
		heroIMGPanel.heroname = hero_name_bot;
	}
	else if(hero_name_locked)
	{
		heroIMGPanel.SetHasClass("HeroPickDirty", false);
		heroIMGPanel.heroname = hero_name_locked.hero;
	}
	else if(local_player == -1 && hero_name_dirty)
	{

		heroIMGPanel.SetHasClass("HeroPickDirty", true);
		heroIMGPanel.heroname = hero_name_dirty.hero;
	}
	else if(local_player_info && hero_name_dirty && info.player_team_id == local_player_info.player_team_id)
	{
		heroIMGPanel.SetHasClass("HeroPickDirty", true);
		heroIMGPanel.heroname = hero_name_dirty.hero;
	}
	else
	{
		heroIMGPanel.SetHasClass("HeroPickDirty", false);
		heroIMGPanel.heroname = "";
	}
}

UpdatePlayerInfo();
GameEvents.Subscribe("IMBAHeroSelection_PlayerSelectedHero", UpdatePlayerInfo);