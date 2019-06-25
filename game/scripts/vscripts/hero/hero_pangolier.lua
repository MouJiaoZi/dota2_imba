CreateEmptyTalents("pangolier")

--STR particles/units/heroes/hero_pangolier/pangolier_heartpiercer_delay.vpcf
--AGI particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_debuff.vpcf
--INT particles/units/heroes/hero_pangolier/pangolier_luckyshot_silence_debuff.vpcf
--ARMOR particles/units/heroes/hero_pangolier/pangolier_heartpiercer_delay.vpcf

LinkLuaModifier("modifier_lucky_shot_passive", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lucky_shot_debuff_str", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lucky_shot_debuff_agi", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lucky_shot_debuff_int", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lucky_shot_debuff_armor", "hero/hero_pangolier.lua", LUA_MODIFIER_MOTION_NONE)

imba_pangolier_lucky_shot = class({})

function imba_pangolier_lucky_shot:GetIntrinsicModifierName() return "modifier_lucky_shot_passive" end

modifier_lucky_shot_passive = class({})

function modifier_lucky_shot_passive:IsDebuff()				return false end
function modifier_lucky_shot_passive:IsHidden() 			return true end
function modifier_lucky_shot_passive:IsPurgable() 			return false end
function modifier_lucky_shot_passive:IsPurgeException() 	return false end
function modifier_lucky_shot_passive:AllowIllusionDuplicate() return false end
function modifier_lucky_shot_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_lucky_shot_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsMagicImmune() then
		return
	end
	local ability = self:GetAbility()
	if PseudoRandom:RollPseudoRandom(ability, ability:GetSpecialValueFor("chance_pct")) then
		if keys.target:HasModifier("modifier_lucky_shot_debuff_str") or keys.target:HasModifier("modifier_lucky_shot_debuff_agi") or keys.target:HasModifier("modifier_lucky_shot_debuff_int") then
			keys.target:EmitSound("Hero_Pangolier.HeartPiercer")
			local buff = keys.target:AddNewModifier(self:GetParent(), ability, "modifier_lucky_shot_debuff_armor", {duration = ability:GetSpecialValueFor("armor_duration")})
			buff:ForceRefresh()
		end
		keys.target:EmitSound("Hero_Pangolier.LuckyShot.Proc")
		local buff_name = {"modifier_lucky_shot_debuff_str",
							"modifier_lucky_shot_debuff_agi",
							"modifier_lucky_shot_debuff_int",}
		keys.target:AddNewModifier(self:GetParent(), ability, buff_name[RandomInt(1, 3)], {duration = ability:GetSpecialValueFor("duration")})
	end
end

modifier_lucky_shot_debuff_str = class({})

function modifier_lucky_shot_debuff_str:IsDebuff()			return true end
function modifier_lucky_shot_debuff_str:IsHidden() 			return false end
function modifier_lucky_shot_debuff_str:IsPurgable() 		return true end
function modifier_lucky_shot_debuff_str:IsPurgeException() 	return true end
function modifier_lucky_shot_debuff_str:DeclareFunctions() return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_lucky_shot_debuff_str:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow")) end
function modifier_lucky_shot_debuff_str:GetModifierHPRegenAmplify_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("hp_regen_reduce_pct")) end
function modifier_lucky_shot_debuff_str:GetEffectName() return "particles/hero/pangolier/pangolier_lucky_shot_str.vpcf" end
function modifier_lucky_shot_debuff_str:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_lucky_shot_debuff_str:ShouldUseOverheadOffset() return true end

modifier_lucky_shot_debuff_agi = class({})

function modifier_lucky_shot_debuff_agi:IsDebuff()			return true end
function modifier_lucky_shot_debuff_agi:IsHidden() 			return false end
function modifier_lucky_shot_debuff_agi:IsPurgable() 		return true end
function modifier_lucky_shot_debuff_agi:IsPurgeException() 	return true end
function modifier_lucky_shot_debuff_agi:CheckState() return {[MODIFIER_STATE_DISARMED] = true} end
function modifier_lucky_shot_debuff_agi:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_lucky_shot_debuff_agi:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow")) end
function modifier_lucky_shot_debuff_agi:GetEffectName() return "particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_debuff.vpcf" end
function modifier_lucky_shot_debuff_agi:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_lucky_shot_debuff_agi:ShouldUseOverheadOffset() return true end

modifier_lucky_shot_debuff_int = class({})

function modifier_lucky_shot_debuff_int:IsDebuff()			return true end
function modifier_lucky_shot_debuff_int:IsHidden() 			return false end
function modifier_lucky_shot_debuff_int:IsPurgable() 		return true end
function modifier_lucky_shot_debuff_int:IsPurgeException() 	return true end
function modifier_lucky_shot_debuff_int:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_lucky_shot_debuff_int:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_lucky_shot_debuff_int:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow")) end
function modifier_lucky_shot_debuff_int:GetEffectName() return "particles/units/heroes/hero_pangolier/pangolier_luckyshot_silence_debuff.vpcf" end
function modifier_lucky_shot_debuff_int:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_lucky_shot_debuff_int:ShouldUseOverheadOffset() return true end

modifier_lucky_shot_debuff_armor = class({})

function modifier_lucky_shot_debuff_armor:IsDebuff()			return true end
function modifier_lucky_shot_debuff_armor:IsHidden() 			return false end
function modifier_lucky_shot_debuff_armor:IsPurgable() 			return true end
function modifier_lucky_shot_debuff_armor:IsPurgeException() 	return true end
function modifier_lucky_shot_debuff_armor:GetTexture() 			return "pangolier_heartpiercer" end
function modifier_lucky_shot_debuff_armor:GetEffectName() return "particles/units/heroes/hero_pangolier/pangolier_heartpiercer_debuff.vpcf" end
function modifier_lucky_shot_debuff_armor:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_lucky_shot_debuff_armor:ShouldUseOverheadOffset() return true end
function modifier_lucky_shot_debuff_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_lucky_shot_debuff_armor:GetModifierPhysicalArmorBonus() return (self:GetStackCount() / 100) end

function modifier_lucky_shot_debuff_armor:OnCreated()
	self:SetStackCount(0)
	if self:GetParent():GetPhysicalArmorValue(false) > 0 then
		self:SetStackCount(0 - self:GetParent():GetPhysicalArmorValue(false) * 100)
	end
end

function modifier_lucky_shot_debuff_armor:OnRefresh()
	self:SetStackCount(0)
	if self:GetParent():GetPhysicalArmorValue(false) > 0 then
		self:SetStackCount(0 - self:GetParent():GetPhysicalArmorValue(false) * 100)
	end
end

