modifier_imba_seen = class({})

function modifier_imba_seen:IsDebuff()				return false end
function modifier_imba_seen:IsHidden() 				return true end
function modifier_imba_seen:IsPurgable() 			return false end
function modifier_imba_seen:IsPurgeException() 		return false end
function modifier_imba_seen:DeclareFunctions()		return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_seen:GetModifierProvidesFOWVision() return 1 end