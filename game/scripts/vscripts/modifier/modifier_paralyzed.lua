modifier_paralyzed = class({})

function modifier_paralyzed:IsDebuff()			return true end
function modifier_paralyzed:IsHidden() 			return false end
function modifier_paralyzed:IsPurgable() 		return true end
function modifier_paralyzed:IsPurgeException() 	return true end
function modifier_paralyzed:GetEffectName() return "particles/basic_ambient/generic_paralyzed.vpcf" end
function modifier_paralyzed:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_paralyzed:ShouldUseOverheadOffset() return true end

function modifier_paralyzed:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_paralyzed:GetModifierMoveSpeedBonus_Percentage() return -10000 end