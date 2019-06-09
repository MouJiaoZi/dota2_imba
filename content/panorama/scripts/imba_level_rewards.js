function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

function SetIMBALevelRewardsButton()
{
	var button = $.GetContextPanel().FindChildTraverse("IMBALevelRewardTriggerButton");
	if(!Players.IsSpectator(Players.GetLocalPlayer()) && FindDotaHudElement("RoshanTimerContainer") && button)
	{
		var container = FindDotaHudElement("RoshanTimerContainer");
		container.FindChildTraverse("RoshanTimer").style.visibility = "visible";
		container.FindChildTraverse("RoshanIcon").style.width = "0px";
		container.FindChildTraverse("RoshanIcon").style.height = "0px";
		container.FindChildTraverse("RoshanTimerRadial").style.width = "0px";
		container.FindChildTraverse("RoshanTimerRadial").style.height = "0px";
		container.FindChildTraverse("RoshanIconBackground").style.backgroundColor = "#141414";
		container.FindChildTraverse("RoshanIconBackground").style.borderRadius = "50%";
		container.FindChildTraverse("RoshanIconBackground").style.backgroundSize = "cover";
		container.FindChildTraverse("RoshanIconBackground").style.backgroundRepeat = "no-repeat";
		container.FindChildTraverse("RoshanIconBackground").style.width = "42px";
		container.FindChildTraverse("RoshanIconBackground").style.height = "42px";
		container.FindChildTraverse("RoshanIconBackground").style.marginLeft = "6px";
		container.FindChildTraverse("RoshanIconBackground").style.marginTop = "8px";
		container.FindChildTraverse("RoshanIconBackground").RemoveClass("RoshanIconBackground");
		if(container.FindChildTraverse("RoshanIconBackground") && container.FindChildTraverse("RoshanIconBackground").FindChildTraverse("IMBALevelRewardTriggerButton"))
		{
			return;
		}
		button.SetParent(container.FindChildTraverse("RoshanIconBackground"));
		button.style.visibility = "visible";
		$.Msg("done");
	}
	else
	{
		$.Schedule(1.0, SetIMBALevelRewardsButton);
	}
}

$.Schedule(1.0, SetIMBALevelRewardsButton);

var created = -1

function IMBARewardButtonClick()
{
	var info = Game.GetLocalPlayerInfo();
	var hero = info.player_selected_hero_entity_index;
	GameEvents.SendCustomGameEventToServer("imbalevelrewardtest", {});
}