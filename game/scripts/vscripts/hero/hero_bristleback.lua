CreateEmptyTalents("bristleback")

imba_bristleback_bristleback = class({})

LinkLuaModifier("modifier_imba_bristleback_passive", "hero/hero_bristleback", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_bristleback_active", "hero/hero_bristleback", LUA_MODIFIER_MOTION_NONE)

function imba_bristleback_bristleback:IsHiddenWhenStolen() 		return false end
function imba_bristleback_bristleback:IsRefreshable() 			return true end
function imba_bristleback_bristleback:IsStealable() 			return false end
function imba_bristleback_bristleback:IsNetherWardStealable()	return false end
function imba_bristleback_bristleback:GetIntrinsicModifierName() return "modifier_imba_bristleback_passive" end

function imba_bristleback_bristleback:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_imba_bristleback_active", {duration = self:GetSpecialValueFor("active_duration")})
	caster:EmitSound("DOTA_Item.Pipe.Activate")
end

modifier_imba_bristleback_passive = class({})

function modifier_imba_bristleback_passive:IsDebuff()			return false end
function modifier_imba_bristleback_passive:IsHidden() 			return true end
function modifier_imba_bristleback_passive:IsPurgable() 		return false end
function modifier_imba_bristleback_passive:IsPurgeException() 	return false end
function modifier_imba_bristleback_passive:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end

function modifier_imba_bristleback_passive:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() or self:GetParent():PassivesDisabled() or keys.attacker:IsBuilding() or self:GetParent():IsIllusion() then
		return
	end
	local cast_angle = VectorToAngles(self:GetParent():GetForwardVector() * -1)
	local angle = VectorToAngles((keys.attacker:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
	local degree = math.abs(AngleDiff(cast_angle[2], angle[2]))
	local min_degree = self:GetParent():HasModifier("modifier_imba_bristleback_active") and 360 or self:GetAbility():GetSpecialValueFor("side_angle")
	if degree <= min_degree then
		local reduce = 0
		local ability = self:GetParent():FindAbilityByName("bristleback_quill_spray")
		self:GetParent():EmitSound("Hero_Bristleback.Bristleback")
		if degree > self:GetAbility():GetSpecialValueFor("back_angle") then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_side_dmg.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlForward(pfx, 3, (keys.attacker:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
			ParticleManager:ReleaseParticleIndex(pfx)
			self:SetStackCount(self:GetStackCount() + keys.damage * (self:GetAbility():GetSpecialValueFor("side_damage_reduction") / 100))
			reduce = (0 - self:GetAbility():GetSpecialValueFor("side_damage_reduction"))
		else
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_back_dmg.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlForward(pfx, 3, (keys.attacker:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
			ParticleManager:ReleaseParticleIndex(pfx)
			self:SetStackCount(self:GetStackCount() + keys.damage * (self:GetAbility():GetSpecialValueFor("back_damage_reduction") / 100))
			reduce = (0 - self:GetAbility():GetSpecialValueFor("back_damage_reduction"))
		end
		if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("quill_release_threshold") and ability and ability:GetLevel() > 0 then
			local max = math.floor(self:GetStackCount() / self:GetAbility():GetSpecialValueFor("quill_release_threshold"))
			for i=1, max do
				self:SetStackCount(self:GetStackCount() - self:GetAbility():GetSpecialValueFor("quill_release_threshold"))
				Timers:CreateTimer((i * 0.1), function()
						ability:OnSpellStart()
						return nil
					end
				)
			end
		end
		return reduce
	end
end

modifier_imba_bristleback_active = class({})

function modifier_imba_bristleback_active:IsDebuff()			return false end
function modifier_imba_bristleback_active:IsHidden() 			return false end
function modifier_imba_bristleback_active:IsPurgable() 			return true end
function modifier_imba_bristleback_active:IsPurgeException() 	return true end
function modifier_imba_bristleback_active:GetEffectName() return "particles/units/heroes/hero_pangolier/pangolier_defense_stance_shield.vpcf" end
function modifier_imba_bristleback_active:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_bristleback_active:ShouldUseOverheadOffset() return true end
function modifier_imba_bristleback_active:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_bristleback_active:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("active_movespeed")) end