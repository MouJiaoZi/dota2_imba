
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