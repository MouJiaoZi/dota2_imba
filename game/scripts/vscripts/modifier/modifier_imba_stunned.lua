modifier_imba_stunned = class({})

function modifier_imba_stunned:IsDebuff()			return true end
function modifier_imba_stunned:IsHidden() 			return false end
function modifier_imba_stunned:IsPurgable() 		return false end
function modifier_imba_stunned:IsPurgeException() 	return true end
function modifier_imba_stunned:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_stunned:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_stunned:GetOverrideAnimation() return ACT_DOTA_DISABLED end
function modifier_imba_stunned:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_imba_stunned:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_stunned:ShouldUseOverheadOffset() return true end

modifier_imba_bashed = class({})

function modifier_imba_bashed:IsDebuff()			return true end
function modifier_imba_bashed:IsHidden() 			return false end
function modifier_imba_bashed:IsPurgable() 			return false end
function modifier_imba_bashed:IsPurgeException() 	return true end
function modifier_imba_bashed:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_bashed:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_bashed:GetOverrideAnimation() return ACT_DOTA_DISABLED end
function modifier_imba_bashed:GetEffectName() return "particles/generic_gameplay/generic_bashed.vpcf" end
function modifier_imba_bashed:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_bashed:ShouldUseOverheadOffset() return true end