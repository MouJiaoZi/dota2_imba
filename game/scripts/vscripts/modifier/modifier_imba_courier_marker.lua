modifier_imba_courier_marker = class({})

function modifier_imba_courier_marker:IsDebuff()			return false end
function modifier_imba_courier_marker:IsHidden() 			return true end
function modifier_imba_courier_marker:IsPurgable() 			return false end
function modifier_imba_courier_marker:IsPurgeException() 	return false end
function modifier_imba_courier_marker:RemoveOnDeath() return false end
function modifier_imba_courier_marker:GetTexture() return "centaur_return" end

modifier_imba_courier_prevent = class({})

function modifier_imba_courier_prevent:IsDebuff()			return false end
function modifier_imba_courier_prevent:IsHidden() 			return true end
function modifier_imba_courier_prevent:IsPurgable() 		return false end
function modifier_imba_courier_prevent:IsPurgeException() 	return false end
function modifier_imba_courier_prevent:RemoveOnDeath() return false end
function modifier_imba_courier_prevent:GetTexture() return "centaur_stampede" end
function modifier_imba_courier_prevent:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_courier_prevent:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticleForPlayer("particles/item/greatwyrm_plate/greatwyrm_passive.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 99, false, false)
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_courier_prevent:OnIntervalThink()
	for i=0, 8 do
		local item = self:GetParent():GetItemInSlot(i)
		if item and item:GetPurchaser() == self:GetCaster() and self:GetParent():IsInvulnerable() then
			self:GetParent():DropItemAtPositionImmediate(item, self:GetParent():GetAbsOrigin())
		end
	end
end