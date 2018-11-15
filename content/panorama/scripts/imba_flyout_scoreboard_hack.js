$.Msg("HELLO");


function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

var flyOut = FindDotaHudElement("CustomUIContainer_FlyoutScoreboard")

var flyRoot = flyOut.FindChildrenWithClassTraverse("FlyoutScoreboardRoot")[0]

flyRoot.style.marginTop = "50px";

