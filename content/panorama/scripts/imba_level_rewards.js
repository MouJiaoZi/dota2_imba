var local_ID = Players.GetLocalPlayer()
var local_IMBALevel = 0;
var local_is_vip = 0;
var current_retrys = 0;
var max_retrys = 60;

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
		$.DispatchEvent("DOTAShowTitleTextTooltip", button, "#IMBA_HUD_RewardButton_Titile", "#IMBA_HUD_RewardButton_Description");
	}
	else
	{
		$.Schedule(0.1, SetIMBALevelRewardsButton);
	}
}

var created = -1
var MainPanel = $.GetContextPanel().FindChildTraverse("IMBALevelRewardBackground_Outer");
var RewardPage = [];
RewardPage[1] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Hero");
RewardPage[2] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Courier");
RewardPage[3] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Ward");
RewardPage[4] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Maelstrom");
RewardPage[5] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Shiva");
RewardPage[6] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Sheep");
RewardPage[7] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Radiance");
RewardPage[8] = $.GetContextPanel().FindChildTraverse("IMBALevelRewardPage_Blink");

function IMBARewardButtonClick()
{
	//if(Game.IsInToolsMode())
	//{
		MainPanel.ToggleClass("LevelRewardPanleVisible");
	//}
}

function ShowIMBARewardPage_Hero()
{
	HideAllRewardPage();
	RewardPage[1].style.visibility = "visible";
}

function ShowIMBARewardPage_Courier()
{
	HideAllRewardPage();
	RewardPage[2].style.visibility = "visible";
}

function ShowIMBARewardPage_Ward()
{
	HideAllRewardPage();
	RewardPage[3].style.visibility = "visible";
}

function ShowIMBARewardPage_Maelstorm()
{
	HideAllRewardPage();
	RewardPage[4].style.visibility = "visible";
}

function ShowIMBARewardPage_Shiva()
{
	HideAllRewardPage();
	RewardPage[5].style.visibility = "visible";
}

function ShowIMBARewardPage_Sheep()
{
	HideAllRewardPage();
	RewardPage[6].style.visibility = "visible";
}

function ShowIMBARewardPage_Radiance()
{
	HideAllRewardPage();
	RewardPage[7].style.visibility = "visible";
}

function ShowIMBARewardPage_Blink()
{
	HideAllRewardPage();
	RewardPage[8].style.visibility = "visible";
}

function HideAllRewardPage()
{
	for(var i=1;i<=8;i++)
	{
		RewardPage[i].style.visibility = "collapse";
	}
}


///////////////////////////////////////////////////////////////////

var HeroColor = [];
HeroColor[1] = ["#FFFFFFFF", 20];
HeroColor[2] = ["#000000FF", 20];
HeroColor[3] = ["#00FFFFFF", 100];
HeroColor[4] = ["#0094FFFF", 200];
HeroColor[5] = ["#0026FFFF", 300];
HeroColor[6] = ["#4800FFFF", 400];
HeroColor[7] = ["#B200FFFF", 500];
HeroColor[8] = ["#00FF90FF", 600];
HeroColor[9] = ["#00FF21FF", 700];
HeroColor[10] = ["#4CFF00FF", 800];
HeroColor[11] = ["#B6FF00FF", 900];
HeroColor[12] = ["#FFD800FF", 1000];
HeroColor[13] = ["#FF6A00FF", 1100];
HeroColor[14] = ["#FF0000FF", 1200];
HeroColor[15] = ["#FF00DCFF", 1300];
HeroColor[16] = ["#FF69B4FF", 0];
HeroColor[17] = ["#FF4004FF", 0];
HeroColor[18] = ["#B03060FF", 0];
HeroColor[19] = ["#FFDAB9FF", 0];

function SetHeroEmEmblem()
{
	var current = 1;
	var total = 15;
	if(Game.GetLocalPlayerInfo().player_steamid == "76561198097609945" || Game.GetLocalPlayerInfo().player_steamid == "76561198100269546" || Game.GetLocalPlayerInfo().player_steamid == "76561198361355161")
	{
		total = 19;
	}
	for(var i=1;i<=4;i++)
	{
		for(var j=1;j<=8;j++)
		{
			if(i == 1 && j == 1)
			{
				var colorButton = $("#IMBALevelRewardPage_Hero_ColorPick_L"+i+"R"+j);
				colorButton.SetAttributeString("type", "disable");
				colorButton.SetAttributeInt("hero_pfx_id", 0);
			}
			else
			{
				var colorButton = $("#IMBALevelRewardPage_Hero_ColorPick_L"+i+"R"+j);
				if(colorButton && current <= total)
				{
					colorButton.style.backgroundColor = HeroColor[current][0];
					colorButton.SetAttributeString("type", HeroColor[current][0]);
					colorButton.SetAttributeInt("hero_pfx_id", current);
					if(GetPlayerPfxSet("hero_pfx") == current && (HeroColor[current][1] <= local_IMBALevel || local_is_vip == 1))
					{
						ApplyHeroEmblem(colorButton.id);
					}
					if(local_IMBALevel < HeroColor[current][1] && local_is_vip != 1)
					{
						colorButton.hittest = false;
						colorButton.GetChild(0).GetChild(0).style.visibility = "visible";
						colorButton.GetChild(0).GetChild(0).SetDialogVariable("req_level", HeroColor[current][1]);
					}
					current = current + 1;
				}
			}
		}
	}
}

function ApplyHeroEmblem(id)
{
	var colorButton = $("#"+id);
	if(!colorButton)
	{
		return;
	}
	var sType = colorButton.GetAttributeString("type", "");
	var iID = colorButton.GetAttributeInt("hero_pfx_id", 1);
	if(sType == "")
	{
		return;
	}
	if(colorButton != $("#IMBALevelRewardPage_Hero_ColorPick_L1R1"))
	{
		colorButton.GetChild(0).GetChild(1).style.visibility = "visible";
	}
	for(var i=1;i<=4;i++)
	{
		for(var j=1;j<=8;j++)
		{
			if(i + j != 2)
			{
				var otherColorButton = $("#IMBALevelRewardPage_Hero_ColorPick_L"+i+"R"+j);
				if(otherColorButton && otherColorButton != colorButton)
				{
					otherColorButton.GetChild(0).GetChild(1).style.visibility = "collapse";
				}
			}
		}
	}
	
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_HeroEffect", {type: sType, id: iID});
}

///////////////////////////////////////////////////////////////////

var CourierPfx = [];
CourierPfx[1] = ["particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient.vpcf", 10];
CourierPfx[2] = ["particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient_lvl2.vpcf", 10];
CourierPfx[3] = ["particles/econ/courier/courier_devourling_gold/courier_devourling_gold_ambient.vpcf", 20];
CourierPfx[4] = ["particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf", 40];
CourierPfx[5] = ["particles/econ/courier/courier_faceless_rex/cour_rex_ground_a.vpcf", 60];
CourierPfx[6] = ["particles/econ/courier/courier_gold_horn/courier_gold_horn_ambient.vpcf", 80];
CourierPfx[7] = ["particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf", 100];
CourierPfx[8] = ["particles/econ/courier/courier_jadehoof_ambient/jadehoof_ambient.vpcf", 120];
CourierPfx[9] = ["particles/econ/courier/courier_onibi/courier_onibi_black_ambient_drip_lvl21.vpcf", 140];
CourierPfx[10] = ["particles/econ/courier/courier_greevil_red/courier_greevil_red_ambient_3.vpcf", 160];
CourierPfx[11] = ["particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_2.vpcf", 200];
CourierPfx[12] = ["particles/econ/courier/courier_greevil_orange/courier_greevil_orange_ambient_3.vpcf", 220];
CourierPfx[13] = ["particles/econ/courier/courier_greevil_naked/courier_greevil_naked_ambient_3.vpcf", 240];
CourierPfx[14] = ["particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf", 260];
CourierPfx[15] = ["particles/econ/courier/courier_greevil_blue/courier_greevil_blue_ambient_3.vpcf", 280];
CourierPfx[16] = ["particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf", 300];
CourierPfx[17] = ["particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf", 320];
CourierPfx[18] = ["particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf", 340];
CourierPfx[19] = ["particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient_flying.vpcf", 360];
CourierPfx[20] = ["particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf", 400];

function SetCourierPfx()
{
	var current = 1;
	var total = 20;
	for(var i=1;i<=5;i++)
	{
		for(var j=1;j<=4;j++)
		{
			var pfxButton = $("#IMBALevelRewardPage_Courier_Pick_L"+i+"R"+j);
			pfxButton.SetAttributeString("type", CourierPfx[current][0]);
			pfxButton.SetAttributeInt("courier_pfx_id", current);
			pfxButton.style.backgroundImage = "url('file://{images}/custom_game/imba_level_rewards/courier_"+current+".png')";
			if(GetPlayerPfxSet("courier_pfx") == current && (CourierPfx[current][1] <= local_IMBALevel || local_is_vip == 1))
			{
				ApplyCourierPfx(pfxButton.id);
			}
			if(local_IMBALevel < CourierPfx[current][1] && local_is_vip != 1)
			{
				pfxButton.hittest = false;
				pfxButton.GetChild(0).style.visibility = "visible";
				pfxButton.GetChild(0).SetDialogVariable("req_level", CourierPfx[current][1]);
			}
			current = current + 1
		}
	}
}

function ApplyCourierPfx(id)
{
	var colorButton = $("#"+id);
	if(!colorButton)
	{
		return;
	}
	colorButton.GetChild(1).style.visibility = "visible";
	for(var i=1;i<=5;i++)
	{
		for(var j=1;j<=4;j++)
		{
			var otherColorButton = $("#IMBALevelRewardPage_Courier_Pick_L"+i+"R"+j);
			if(otherColorButton && otherColorButton != colorButton)
			{
				otherColorButton.GetChild(1).style.visibility = "collapse";
			}
		}
	}
	var sType = colorButton.GetAttributeString("type", "");
	var iID = colorButton.GetAttributeInt("courier_pfx_id", 1);
	if(sType == "")
	{
		return;
	}
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_CourierEffect", {type: sType, id: iID});
}

function RemoveCourierPfx()
{
	for(var i=1;i<=5;i++)
	{
		for(var j=1;j<=4;j++)
		{
			var otherColorButton = $("#IMBALevelRewardPage_Courier_Pick_L"+i+"R"+j);
			if(otherColorButton)
			{
				otherColorButton.GetChild(1).style.visibility = "collapse";
			}
		}
	}
	var sType = "disable";
	var iID = 0;
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_CourierEffect", {type: sType, id: iID});
}

///////////////////////////////////////////////////////////////////

var WardPfx = [];
WardPfx[1] = 10;
WardPfx[2] = 40;
WardPfx[3] = 60;
WardPfx[4] = 90;
WardPfx[5] = 100;
WardPfx[6] = 120;
WardPfx[7] = 140;
WardPfx[8] = 160;
WardPfx[9] = 200;
WardPfx[10] = 220;
WardPfx[11] = 230;
WardPfx[12] = 230;
WardPfx[13] = 300;
WardPfx[14] = 400;
WardPfx[15] = 500;
WardPfx[16] = 600;
WardPfx[17] = 700;
WardPfx[18] = 800;

function SetWardPfx()
{
	var current = 1;
	var total = 18;
	for(var i=1;i<=3;i++)
	{
		for(var j=1;j<=6;j++)
		{
			if(current > total)
			{
				var pfxButton = $("#IMBALevelRewardPage_Ward_Pick_L"+i+"R"+j);
				pfxButton.hittest = false;
				return;
			}
			var pfxButton = $("#IMBALevelRewardPage_Ward_Pick_L"+i+"R"+j);
			pfxButton.SetAttributeInt("ward_pfx_id", current);
			pfxButton.style.backgroundImage = "url('file://{images}/custom_game/imba_level_rewards/ward_"+current+".png')";
			if(GetPlayerPfxSet("ward_pfx") == current && (WardPfx[current] <= local_IMBALevel || local_is_vip == 1))
			{
				ApplyWardPfx(pfxButton.id);
			}
			if(local_IMBALevel < WardPfx[current] && local_is_vip != 1)
			{
				pfxButton.hittest = false;
				pfxButton.GetChild(0).style.visibility = "visible";
				pfxButton.GetChild(0).SetDialogVariable("req_level", WardPfx[current]);
			}
			current = current + 1
		}
	}
}

function ApplyWardPfx(id)
{
	var colorButton = $("#"+id);
	if(!colorButton)
	{
		return;
	}
	colorButton.GetChild(1).style.visibility = "visible";
	for(var i=1;i<=3;i++)
	{
		for(var j=1;j<=6;j++)
		{
			var otherColorButton = $("#IMBALevelRewardPage_Ward_Pick_L"+i+"R"+j);
			if(otherColorButton && otherColorButton != colorButton)
			{
				otherColorButton.GetChild(1).style.visibility = "collapse";
			}
		}
	}
	var iID = colorButton.GetAttributeInt("ward_pfx_id", 1);
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_WardEffect", {id: iID});
}

function RemoveWardPfx()
{
	for(var i=1;i<=3;i++)
	{
		for(var j=1;j<=6;j++)
		{
			var otherColorButton = $("#IMBALevelRewardPage_Ward_Pick_L"+i+"R"+j);
			if(otherColorButton)
			{
				otherColorButton.GetChild(1).style.visibility = "collapse";
			}
		}
	}
	var iID = 0;
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_WardEffect", {id: iID});
}

///////////////////////////////////////////////////////////////////

var MaelstromPfx = [];
MaelstromPfx[1] = 100;
MaelstromPfx[2] = 200;
MaelstromPfx[3] = 300;
MaelstromPfx[4] = 400;

var MaelstromColor = [];
MaelstromColor[1] = ["#808080FF", 500];
MaelstromColor[2] = ["#000000FF", 550];
MaelstromColor[3] = ["#FFFFFFFF", 600];
MaelstromColor[4] = ["#00FFFFFF", 650];
MaelstromColor[5] = ["#0094FFFF", 700];
MaelstromColor[6] = ["#0026FFFF", 750];
MaelstromColor[7] = ["#4800FFFF", 800];
MaelstromColor[8] = ["#B200FFFF", 850];
MaelstromColor[9] = ["#00FF90FF", 900];
MaelstromColor[10] = ["#00FF21FF", 950];
MaelstromColor[11] = ["#4CFF00FF", 1000];
MaelstromColor[12] = ["#B6FF00FF", 1100];
MaelstromColor[13] = ["#FFD800FF", 1200];
MaelstromColor[14] = ["#FF6A00FF", 1300];
MaelstromColor[15] = ["#FF00DCFF", 1400];
MaelstromColor[16] = ["#FF0000FF", 1500];
MaelstromColor[17] = ["#FF69B4FF", 0];
MaelstromColor[18] = ["#FF4004FF", 0];
MaelstromColor[19] = ["#B03060FF", 0];
MaelstromColor[20] = ["#FFDAB9FF", 0];

function SetMaelstromPfx()
{
	for(var i=1;i<=4;i++)
	{
		var pfxButton = $("#IMBALevelRewardPage_Maelstrom_Pick_"+i);
		if(pfxButton)
		{
			pfxButton.SetAttributeInt("maelstrom_pfx_id", i);
			pfxButton.style.backgroundImage = "url('file://{images}/custom_game/imba_level_rewards/maelstrom_"+i+".png')";
			if(GetPlayerPfxSet("maelstrom_pfx") == i && (MaelstromPfx[i] <= local_IMBALevel || local_is_vip == 1))
			{
				ApplyMaelstromPfx(pfxButton.id);
			}
			if(local_IMBALevel < MaelstromPfx[i] && local_is_vip != 1)
			{
				pfxButton.hittest = false;
				pfxButton.GetChild(0).style.visibility = "visible";
				pfxButton.GetChild(0).SetDialogVariable("req_level", MaelstromPfx[i]);
			}
		}
	}
	for(var i=1;i<=20;i++)
	{
		var pfxButton = $("#IMBALevelRewardPage_MaelstromColor_Pick_"+i);
		if(pfxButton)
		{
			if(i < 17 || (Game.GetLocalPlayerInfo().player_steamid == "76561198097609945" || Game.GetLocalPlayerInfo().player_steamid == "76561198100269546" || Game.GetLocalPlayerInfo().player_steamid == "76561198361355161"))
			{
				pfxButton.SetAttributeInt("maelstrom_color_id", i);
				pfxButton.SetAttributeString("color_hex", MaelstromColor[i][0]);
				pfxButton.style.backgroundColor = MaelstromColor[i][0];
				if(GetPlayerPfxSet("maelstrom_color") == i && (MaelstromColor[i][1] <= local_IMBALevel || local_is_vip == 1))
				{
					ApplyMaelstromColor(pfxButton.id);
				}
				if(local_IMBALevel < MaelstromColor[i][1] && local_is_vip != 1)
				{
					pfxButton.hittest = false;
					pfxButton.GetChild(0).style.visibility = "visible";
					pfxButton.GetChild(0).SetDialogVariable("req_level", MaelstromColor[i][1]);
				}
			}
		}
	}
}

function ApplyMaelstromPfx(id)
{
	var colorButton = $("#"+id);
	if(!colorButton)
	{
		return;
	}
	colorButton.GetChild(1).style.visibility = "visible";
	for(var i=1;i<=4;i++)
	{
		var otherColorButton = $("#IMBALevelRewardPage_Maelstrom_Pick_"+i);
		if(otherColorButton && otherColorButton != colorButton)
		{
			otherColorButton.GetChild(1).style.visibility = "collapse";
		}
	}
	var iID = colorButton.GetAttributeInt("maelstrom_pfx_id", 1);
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_MaelStromEffect", {id: iID});
}

function ApplyMaelstromColor(id)
{
	var colorButton = $("#"+id);
	if(!colorButton || colorButton.GetAttributeString("color_hex", "") == "")
	{
		return;
	}
	colorButton.GetChild(1).style.visibility = "visible";
	for(var i=1;i<=20;i++)
	{
		var otherColorButton = $("#IMBALevelRewardPage_MaelstromColor_Pick_"+i);
		if(otherColorButton && otherColorButton != colorButton)
		{
			otherColorButton.GetChild(1).style.visibility = "collapse";
		}
	}
	var iID = colorButton.GetAttributeInt("maelstrom_color_id", 0);
	var sColor = colorButton.GetAttributeString("color_hex", "");
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_MaelStromColor", {id: iID, color: sColor});
}

function RemoveMaelstromPfx()
{
	for(var i=1;i<=4;i++)
	{
		var otherColorButton = $("#IMBALevelRewardPage_Maelstrom_Pick_"+i);
		if(otherColorButton)
		{
			otherColorButton.GetChild(1).style.visibility = "collapse";
		}
	}
	var iID = 0;
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_MaelStromEffect", {id: iID});
}

function RemoveMaelstromColor()
{
	for(var i=1;i<=20;i++)
	{
		var otherColorButton = $("#IMBALevelRewardPage_MaelstromColor_Pick_"+i);
		if(otherColorButton)
		{
			otherColorButton.GetChild(1).style.visibility = "collapse";
		}
	}
	var iID = 0;
	GameEvents.SendCustomGameEventToServer("IMBALevelReward_MaelStromColor", {id: iID});
}

///////////////////////////////////////////////////////////////////

function InitIMBALevel()
{
	if(current_retrys > max_retrys)
	{
		$.GetContextPanel().FindChildTraverse("IMBALevelReward_CurrentLevelText").SetDialogVariable("current_level", "ERROR");
		return;
	}
	var table = CustomNetTables.GetTableValue("imba_level_rewards", "player_state_"+local_ID);
	if(table)
	{
		local_IMBALevel = table.imba_level;
		local_is_vip = table.is_vip;
		$.GetContextPanel().FindChildTraverse("IMBALevelReward_CurrentLevelText").SetDialogVariable("current_level", local_IMBALevel);
		$.Schedule(0.1, SetIMBALevelRewardsButton);
		ShowIMBARewardPage_Hero();
		SetHeroEmEmblem();
		SetCourierPfx();
		SetWardPfx();
		SetMaelstromPfx();
	}
	else
	{
		current_retrys = current_retrys + 1;
		$.Schedule(1.0, InitIMBALevel);
	}
}

$.Schedule(5.0, InitIMBALevel);

function GetPlayerPfxSet(sType)
{
	var table = CustomNetTables.GetTableValue("imba_level_rewards", "player_state_"+local_ID);
	if(!table)
	{
		return 0;
	}
	else
	{
		return table[sType] ? table[sType] : 0;
	}
}