var base = $.GetContextPanel();
var UnitControlButton = base.FindChildTraverse("IMBAUnitControlButton");
var HeroControlButton = base.FindChildTraverse("IMBAHeroControlButton");
var DisableHelpButton = base.FindChildTraverse("IMBADisableHelpButton");
var MuteButton = base.FindChildTraverse("IMBAMuteButton");



function ToggleUnit()
{
	var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
	if (Players.IsValidPlayerID(playerId)) {
		GameEvents.SendCustomGameEventToServer("toggle_share_unit", {
			otherPlayerID: playerId
		})
	}
}

function ToggleHero()
{
	var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
	if (Players.IsValidPlayerID(playerId)) {
		GameEvents.SendCustomGameEventToServer("toggle_share_hero", {
			otherPlayerID: playerId
		})
	}
}

function ToggleDisableHelp()
{
	var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
	if (Players.IsValidPlayerID(playerId))
	{
		GameEvents.SendCustomGameEventToServer("toggle_disable_player_help", {
			otherPlayerID: playerId
		})
	}
}

function ToggleMute()
{
	var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
	Game.SetPlayerMuted(playerId, MuteButton.IsSelected());
}
