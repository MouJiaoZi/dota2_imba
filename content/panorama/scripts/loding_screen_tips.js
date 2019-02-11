
var $img = 
[
"file://{images}/spellicons/courier_shield.png",
"file://{images}/spellicons/faceless_void_time_lock.png",
"file://{images}/spellicons/beastmaster_inner_beast.png",
"file://{images}/spellicons/pangolier_heartpiercer.png",
"file://{images}/spellicons/centaur_return.png",
];

var $tip = 
[
"#IMBA_LOADING_TIPS_1",
"#IMBA_LOADING_TIPS_2",
"#IMBA_LOADING_TIPS_3",
"#IMBA_LOADING_TIPS_4",
"#IMBA_LOADING_TIPS_5",
];

function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

var tipContextPanel = FindDotaHudElement("LoDLoadingTip");

function setHint(img, txt) 
{
	if (tipContextPanel == null)
		return;


	// Set the image
	var tipImage = tipContextPanel.FindChildTraverse('LoDLoadingTipImage');
	if(tipImage != null) {
		tipImage.SetImage(img);
	}

	var tipText = tipContextPanel.FindChildTraverse('LoDLoadingTipText');
	if(tipText != null) {
		text_label = $.CreatePanel('Label', tipText, '');
		text_label.html = true;
		text_label.text = $.Localize(txt);
		text_label.hittest = false;
		text_label.AddClass("LoDLoadingTipText");
	}
}

var tips_n = Math.floor(Math.random()*$img.length);

var $img_s = $img[tips_n];
var $tio_s = $tip[tips_n];

setHint($img_s, $tio_s);

function SetVoteUI()
{
	if(Game.GetLocalPlayerInfo() == undefined)
	{
		$.Schedule(1, SetVoteUI);
		return;
	}
	if(Game.GetMapInfo().map_display_name == "dbii_death_match")
	{
		FindDotaHudElement("DMOMGVotePanel").visible = 1;
		FindDotaHudElement("DMOMGVotePanel").style.opacity = 1;
		FindDotaHudElement("AKVotePanel").visible = 0;
		FindDotaHudElement("AKVotePanel").style.opacity = 0;
		FindDotaHudElement("31VotePanel").visible = 0;
		FindDotaHudElement("31VotePanel").style.opacity = 0;
	}
	else
	{
		FindDotaHudElement("DMOMGVotePanel").visible = 0;
		FindDotaHudElement("DMOMGVotePanel").style.opacity = 0;
		FindDotaHudElement("AKVotePanel").visible = 1;
		FindDotaHudElement("AKVotePanel").style.opacity = 1;
		FindDotaHudElement("31VotePanel").visible = 1;
		FindDotaHudElement("31VotePanel").style.opacity = 1;
	}
	
}

SetVoteUI();

function IMBAVoteForOMG()
{
	FindDotaHudElement("DMOMGVoteButton").enabled = 0;
	FindDotaHudElement("DMOMGVoteButton").style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #808080FF ), to( #404040FF ) )';
	GameEvents.SendCustomGameEventToServer("vote_for_omg", {});
}

function UpdataOMGVote()
{
	var votes = CustomNetTables.GetTableValue("imba_omg", "enable_omg").agree;
	var enable = CustomNetTables.GetTableValue("imba_omg", "enable_omg").enable;
	FindDotaHudElement("DMOMGVoteNum").text = votes;
	if(enable == 1)
	{
		FindDotaHudElement("DMOMGVoteNum").style.color = '#48FF00';
	}
	else
	{
		FindDotaHudElement("DMOMGVoteNum").style.color = '#FF0000';
	}
	//$.Msg(votes, "   ", enable);
}

function IMBAVoteForAK()
{
	FindDotaHudElement("AKVoteButton").enabled = 0;
	FindDotaHudElement("AKVoteButton").style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #808080FF ), to( #404040FF ) )';
	GameEvents.SendCustomGameEventToServer("vote_for_ak", {});
}

function UpdataAKVote()
{
	var votes = CustomNetTables.GetTableValue("imba_omg", "enable_ak").agree;
	var enable = CustomNetTables.GetTableValue("imba_omg", "enable_ak").enable;
	FindDotaHudElement("AKVoteNum").text = votes;
	if(enable == 1)
	{
		FindDotaHudElement("AKVoteNum").style.color = '#48FF00';
	}
	else
	{
		FindDotaHudElement("AKVoteNum").style.color = '#FF0000';
	}
	//$.Msg(votes, "   ", enable);
}

function IMBAVoteFor31()
{
	FindDotaHudElement("31VoteButton").enabled = 0;
	FindDotaHudElement("31VoteButton").style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #808080FF ), to( #404040FF ) )';
	GameEvents.SendCustomGameEventToServer("vote_for_31", {});
}

function Updata31Vote()
{
	var votes = CustomNetTables.GetTableValue("imba_omg", "enable_31").agree;
	var enable = CustomNetTables.GetTableValue("imba_omg", "enable_31").enable;
	FindDotaHudElement("31VoteNum").text = votes;
	if(enable == 1)
	{
		FindDotaHudElement("31VoteNum").style.color = '#48FF00';
	}
	else
	{
		FindDotaHudElement("31VoteNum").style.color = '#FF0000';
	}
	//$.Msg(votes, "   ", enable);
}

GameEvents.Subscribe("updata_omg_vote", UpdataOMGVote);
GameEvents.Subscribe("updata_ak_vote", UpdataAKVote);
GameEvents.Subscribe("updata_31_vote", Updata31Vote);