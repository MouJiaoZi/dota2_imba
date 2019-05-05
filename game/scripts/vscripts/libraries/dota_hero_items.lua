HeroItems = class({})

local steamid = 
{
	"76561198097609945",
}

function HeroItems:UnitHasItem(hUnit, sItemModelName)
	return false
	--[[if IsInTable(tostring(PlayerResource:GetSteamID(hUnit:GetPlayerOwnerID())), steamid) then
		return true
	end
	local item = hUnit:GetChildren()
	for i=1, #item do
		if item[i]:GetClassname() == "dota_item_wearable" and string.find(item[i]:GetModelName(), sItemModelName) then
			return true
		end
	end
	return nil]]
end

function HeroItems:UnitHasItem2(hUnit, sItemModelName)
	local entity = hUnit:FirstMoveChild()
	while entity do
		if entity:GetClassname() == "dota_item_wearable" and string.find(entity:GetModelName(), sItemModelName) then
			return entity
		end
		entity = hUnit:NextMovePeer()
	end
	return nil
end

function HeroItems:RemoveHeroItem(hHeroItem)
	Timers:CreateTimer(0.1, function()
		if hHeroItem and hHeroItem.GetModelName then
			hHeroItem:AddEffects(EF_NODRAW)
			print("Removing Hero Item:",hHeroItem:GetModelName())
			hHeroItem:SetModel("models/development/invisiblebox.vmdl")
		end
	end)
end

function HeroItems:AddHeroItem(hUnit, sItemSlot, sNewItemModelName, sParticleName, iParticleAttach)
	if not hUnit or not sItemSlot or not sNewItemModelName then
		return
	end
	local pre_item = HeroItems:UnitHasItem(hUnit, sItemSlot)
	if not pre_item then
		return
	end
	local new_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = sNewItemModelName})
	new_item:SetParent(hUnit, "attach_hitloc")
	new_item:FollowEntity(hUnit, true)
	HeroItems:RemoveHeroItem(pre_item)
end