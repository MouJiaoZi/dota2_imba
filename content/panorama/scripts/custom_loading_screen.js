

function FindDotaHudElement(sElement)
{
	var BaseHud = $.GetContextPanel().GetParent().GetParent().GetParent();
	return BaseHud.FindChildTraverse(sElement);
}

FindDotaHudElement("GameAndPlayersRoot").style.width = "0px";
FindDotaHudElement("TeamListHeader").style.width = "0px";
FindDotaHudElement("TeamsList").style.backgroundColor = "rgba(1,1,1,0.2)";
var team =  FindDotaHudElement("TeamsListRoot").FindChildrenWithClassTraverse("team_2")[0];
team.style.backgroundColor = "rgba(0,255,0,0.1)";
var team =  FindDotaHudElement("TeamsListRoot").FindChildrenWithClassTraverse("team_3")[0];
team.style.backgroundColor = "rgba(255,0,0,0.1)";
FindDotaHudElement("PlayerIsHostPanel").style.width = "0px";
FindDotaHudElement("PlayerIsHostPanel").style.height = "0px";