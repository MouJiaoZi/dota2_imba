modifier_imba_suicide = class({})

function modifier_imba_suicide:IsDebuff()			return true end
function modifier_imba_suicide:IsHidden() 			return false end
function modifier_imba_suicide:IsPurgable() 		return false end
function modifier_imba_suicide:IsPurgeException() 	return false end
function modifier_imba_suicide:GetTexture() return "tombstone" end
function modifier_imba_suicide:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_PASSIVES_DISABLED] = true, [MODIFIER_STATE_MUTED] = true} end
function modifier_imba_suicide:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end

function modifier_imba_suicide:OnDestroy()
	if IsServer() and self:GetElapsedTime() >= self:GetDuration() then
		self:GetParent():RemoveAllModifiers()
		local pos = GetGroundPosition(Vector(0,0,0), self:GetParent())
		self:GetParent():SetOrigin(pos)
		TrueKill(self:GetParent(), self:GetParent(), nil)
	end
end