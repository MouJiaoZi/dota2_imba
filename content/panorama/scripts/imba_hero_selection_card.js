
function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

var language = $.Localize("IMBA_Language");
var lang_pre = "none"
switch(language)
{
	case "Schinese":
		lang_pre = "lang_chn_";
		break;
	case "English":
		lang_pre = "lang_eng_";
		break;
}
var desc_pre = "none"
switch(language)
{
	case "Schinese":
		desc_pre = "desc_chn_";
		break;
	case "English":
		desc_pre = "desc_eng_";
		break;
}
var local_player = Players.GetLocalPlayer();
var hero_name = $.GetContextPanel().GetAttributeString("heroname", "no_hero_name");
var attribute = $.GetContextPanel().GetAttributeInt("hero_attribute", 0);
var ability = CustomNetTables.GetTableValue("imba_hero_selection_ability", hero_name);
var talent = CustomNetTables.GetTableValue("imba_hero_selection_talent", hero_name);
var talent_lang = CustomNetTables.GetTableValue("imba_hero_selection_talent", lang_pre+hero_name);
var talent_desc = CustomNetTables.GetTableValue("imba_hero_selection_talent", desc_pre+hero_name);
$("#Overlay_Selected").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/overlay_selected.png')";
$("#Overlay_FullyIMBA").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/overlay_fully_imba.png')";
$("#Overlay_HalfIMBA").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/overlay_half_imba.png')";
$("#Overlay_GoingIMBA").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/overlay_going_imba.png')";
$("#Overlay_ICanPick").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/overlay_can_pick_announce.png')";
$("#Overlay_Suggest").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/overlay_suggest.png')";
$("#Overlay_CanSelect").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/overlay_selectable.png')";
$("#Overlay_Banned").style.backgroundImage = "url('file://{images}/custom_game/hero_selection/banned_overlay.png')";
$("#Overlay_Banned").style.washColor = "#FF0000FF";
$("#HeroCard_HeroIMG").heroname = hero_name;

var hero_info_name = FindDotaHudElement("HeroPick_Info_Main_Header_HeroName");
var hero_info_attribute_icon = FindDotaHudElement("HeroPick_Info_Main_Header_PrimaryAttributeIcon");
var icon = ['url("s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_strength_psd.vtex")', 'url("s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_agility_psd.vtex")', 'url("s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_intelligence_psd.vtex")'];
var hero_show_movie = FindDotaHudElement("HeroPick_Card_Hover");
var hero_info_movie = FindDotaHudElement("HeroPick_Info_Main_Movie_Main");
var hero_info_ability_1 = FindDotaHudElement("HeroPick_Info_Main_Ability_1");
var hero_info_ability_2 = FindDotaHudElement("HeroPick_Info_Main_Ability_2");
var hero_info_ability_3 = FindDotaHudElement("HeroPick_Info_Main_Ability_3");
var hero_info_ability_4 = FindDotaHudElement("HeroPick_Info_Main_Ability_4");
var hero_info_ability_5 = FindDotaHudElement("HeroPick_Info_Main_Ability_5");
var hero_info_ability_6 = FindDotaHudElement("HeroPick_Info_Main_Ability_6");
var hero_info_ability = [hero_info_ability_1, hero_info_ability_2, hero_info_ability_3, hero_info_ability_4, hero_info_ability_5, hero_info_ability_6];
var hero_info_talent_1 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade1").GetChild(0);
var hero_info_talent_2 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade2").GetChild(0);
var hero_info_talent_3 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade3").GetChild(0);
var hero_info_talent_4 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade4").GetChild(0);
var hero_info_talent_5 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade5").GetChild(0);
var hero_info_talent_6 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade6").GetChild(0);
var hero_info_talent_7 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade7").GetChild(0);
var hero_info_talent_8 = FindDotaHudElement("HeroPick_Info_Talent_Tree_Upgrade8").GetChild(0);
var hero_info_talent = [hero_info_talent_1, hero_info_talent_2, hero_info_talent_3, hero_info_talent_4, hero_info_talent_5, hero_info_talent_6, hero_info_talent_7, hero_info_talent_8];

function ShowHeroDetail()
{
	if(GameUI.IsAltDown() && !GameUI.IsShiftDown() && !GameUI.IsControlDown() && local_player != -1)
	{
		var hero_name_string = $.Localize(hero_name);
		var info_string = $.Localize("IMBA_HUD_HERO_SELECTION_PLAYER_SUGGEST");
		GameEvents.SendCustomGameEventToServer("IMBAHeroSelection_APSuggestHero", {hero: hero_name, hero_name: hero_name_string, info_string: info_string});
	}
	else if(GameUI.IsAltDown() && !GameUI.IsShiftDown() && GameUI.IsControlDown() && local_player != -1)
	{
		$.Msg("ctrl+alt");
	}
	else if(!GameUI.IsAltDown() && !GameUI.IsShiftDown() && !GameUI.IsControlDown())
	{
		hero_info_name.text = $.Localize(hero_name);
		hero_info_attribute_icon.style.backgroundImage = icon[attribute];
		hero_info_attribute_icon.style.backgroundSize = "100% 100%";
		hero_info_movie.heroname = hero_name;
		hero_info_movie.SetAttributeString("heroname", hero_name);
		var has_talent = talent ? true : false;
		for(var i=1;i<=6;i++)
		{
			var ability_name = ability[i];
			var ability_panel = hero_info_ability[i-1];
			if(ability_name)
			{
				ability_panel.style.visibility = "visible";
				ability_panel.abilityname = ability_name;
				(function (abilityPanel, ability) {
					abilityPanel.SetPanelEvent("onmouseover", function() {
						$.DispatchEvent("DOTAShowAbilityTooltip", abilityPanel, ability);
					})
					abilityPanel.SetPanelEvent("onmouseout", function() {
						$.DispatchEvent("DOTAHideAbilityTooltip", abilityPanel);
					})
				})(ability_panel, ability_name);
			}
			else
			{
				ability_panel.style.visibility = "collapse";
			}
		}
		if(has_talent)
		{
			for(var i=1;i<=8;i++)
			{
				var txt = talent_lang[i];
				var desc = talent_desc[i];
				hero_info_talent[i-1].text = txt ? txt : $.Localize("DOTA_Tooltip_ability_"+talent[i]);
				if($.Localize("DOTA_Tooltip_ability_"+talent[i]+"_Description") != "DOTA_Tooltip_ability_"+talent[i]+"_Description")
				{
					(function (abilityPanel, ability) {
						abilityPanel.hittest = true;
						abilityPanel.SetPanelEvent("onmouseover", function() {
							$.DispatchEvent("DOTAShowTextTooltip", abilityPanel, ability);
						})
						abilityPanel.SetPanelEvent("onmouseout", function() {
							$.DispatchEvent("DOTAHideTextTooltip", abilityPanel);
						})
					})(hero_info_talent[i-1], desc ? desc : $.Localize("DOTA_Tooltip_ability_"+talent[i]+"_Description"));
				}
				else
				{
					(function (abilityPanel) {
						abilityPanel.hittest = false;
					})(hero_info_talent[i-1]);
				}
			}
		}
		else
		{
			for(var i=1;i<=8;i++)
			{
				hero_info_talent[i-1].text = "";
			}
		}
		GameEvents.SendCustomGameEventToServer("IMBAHeroSelection_PlayerDirtySelectHero", {hero: hero_name});
	}
	
}

function HideAllOverlay()
{
	$("#Overlay_Selected").SetHasClass("visible", false);
	$("#Overlay_FullyIMBA").SetHasClass("visible", false);
	$("#Overlay_HalfIMBA").SetHasClass("visible", false);
	$("#Overlay_GoingIMBA").SetHasClass("visible", false);
	$("#Overlay_ICanPick").SetHasClass("visible", false);
	$("#Overlay_Suggest").SetHasClass("visible", false);
	$("#Overlay_CanSelect").SetHasClass("visible", false);
	$("#Overlay_Banned").SetHasClass("visible", false);
}

function UpdateHeroCard_OnPick()
{
	var ban_info = CustomNetTables.GetTableValue("imba_hero_selection_list", "banned_hero");
	if(ban_info && ban_info[hero_name])
	{
		HideAllOverlay();
		$("#Overlay_Banned").SetHasClass("visible", true);
		$.GetContextPanel().SetPanelEvent("onmouseover", function() {});
		$.GetContextPanel().SetPanelEvent("onmouseout", function() {});
		return;
	}
	for(var i=0;i<20;i++)
	{
		var info = CustomNetTables.GetTableValue("imba_hero_selection_player", "player_hero_selected_"+i);
		if(info && info.hero == hero_name && local_player != -1)
		{
			$("#HeroCard_HeroIMG").style.washColor = "#000000E7";
			if(i == local_player)
			{
				HideAllOverlay();
				$("#Overlay_Selected").SetHasClass("visible", true);
				$.GetContextPanel().SetPanelEvent("onmouseover", function() {});
				$.GetContextPanel().SetPanelEvent("onmouseout", function() {});
				return;
			}
			else
			{
				$.GetContextPanel().SetPanelEvent("onmouseover", function() {});
				$.GetContextPanel().SetPanelEvent("onmouseout", function() {});
			}
		}
	}
}

function UpdateHeroCard_OnSuggest()
{
	if(local_player == -1)
	{
		return;
	}
	else
	{
		var info = CustomNetTables.GetTableValue("imba_hero_selection_list", "ap_suggest_list"+Game.GetLocalPlayerInfo().player_team_id);
		if(info && info[hero_name])
		{
			$("#Overlay_Suggest").SetHasClass("visible", true);
		}
		else
		{
			$("#Overlay_Suggest").SetHasClass("visible", false);
		}
	}
}

UpdateHeroCard_OnPick();
UpdateHeroCard_OnSuggest();
GameEvents.Subscribe("IMBAHeroSelection_PlayerSelectedHero", UpdateHeroCard_OnPick);
GameEvents.Subscribe("IMBAHeroSelection_PlayerSuggestHero", UpdateHeroCard_OnSuggest);