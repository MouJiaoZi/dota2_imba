HeroItems = class({})

function HeroItems:UnitHasItem(hUnit, sItemModelName)
	local item = hUnit:GetChildren()
	for i=1, #item do
		if item[i]:GetClassname() == "dota_item_wearable" and string.find(item[i]:GetModelName(), sItemModelName) then
			return item[i]
		end
	end
	return nil
end

function HeroItems:RemoveHeroItem(hHeroItem)
	Timers:CreateTimer(0.1, function()
		if hHeroItem and hHeroItem.GetModelName then
			hHeroItem:SetModel("models/development/invisiblebox.vmdl")
			hHeroItem:AddEffects(EF_NODRAW)
		end
	end)
end

function HeroItems:AddHeroItem(hUnit, sPreItemModelName, sItemModelName)
	if not hUnit or not sPreItemModelName or not sItemModelName then
		return
	end
	local pre_item = HeroItems:UnitHasItem(hUnit, sPreItemModelName)
	if not pre_item then
		return
	end
	local new_item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = sItemModelName})
	new_item:FollowEntity(hUnit, true)
	local pfx = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_weapon_pipe/dazzle_ambient_pipe.vpcf", PATTACH_ABSORIGIN_FOLLOW, new_item)
	ParticleManager:ReleaseParticleIndex(pfx)
	HeroItems:RemoveHeroItem(sPreItemModelName)
end