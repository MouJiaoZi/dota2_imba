CreateEmptyTalents("doom")


imba_doom_bringer_doom = class({})

LinkLuaModifier("modifier_imba_doom_caster", "hero/hero_doom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_doom_enemy", "hero/hero_doom", LUA_MODIFIER_MOTION_NONE)

function imba_doom_bringer_doom:IsHiddenWhenStolen() 		return false end
function imba_doom_bringer_doom:IsRefreshable() 			return true end
function imba_doom_bringer_doom:IsStealable() 				return true end
function imba_doom_bringer_doom:IsNetherWardStealable()		return true end
function imba_doom_bringer_doom:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_doom_bringer_doom:OnSpellStart()
	self:GetCaster():EmitSound("Hero_DoomBringer.Doom")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_doom_caster", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_doom_caster = class({})

function modifier_imba_doom_caster:IsDebuff()			return false end
function modifier_imba_doom_caster:IsHidden() 			return false end
function modifier_imba_doom_caster:IsPurgable() 		return false end
function modifier_imba_doom_caster:IsPurgeException() 	return false end
function modifier_imba_doom_caster:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_doom_caster:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

function modifier_imba_doom_caster:OnCreated()
	if IsServer() then
		local pfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_doom_ring_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx3, false, false, 15, false, false)
		for i=1, 10 do
			local pfx1 = ParticleManager:CreateParticle("particles/econ/courier/courier_trail_lava/courier_trail_lava_model.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			self:AddParticle(pfx1, false, false, 15, false, false)
			local pfx2 = ParticleManager:CreateParticle("particles/econ/courier/courier_roshan_lava/courier_roshan_lava_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(pfx2, 15, Vector(213,114,10))
			self:AddParticle(pfx2, false, false, 15, false, false)
			local pfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			self:AddParticle(pfx3, false, false, 15, false, false)
		end
	end
end

function modifier_imba_doom_caster:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_DoomBringer.Doom")
	end
end

function modifier_imba_doom_caster:IsAura() return true end
function modifier_imba_doom_caster:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("aura_linger") end
function modifier_imba_doom_caster:GetModifierAura() return "modifier_imba_doom_enemy" end
function modifier_imba_doom_caster:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_doom_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_doom_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_doom_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_doom_enemy = class({})

function modifier_imba_doom_enemy:IsDebuff()			return true end
function modifier_imba_doom_enemy:IsHidden() 			return false end
function modifier_imba_doom_enemy:IsPurgable() 			return false end
function modifier_imba_doom_enemy:IsPurgeException() 	return false end
function modifier_imba_doom_enemy:CheckState() return {[MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_PASSIVES_DISABLED] = true} end
function modifier_imba_doom_enemy:GetEffectName() return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf" end
function modifier_imba_doom_enemy:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_doom_enemy:GetStatusEffectName() return "particles/status_fx/status_effect_doom.vpcf" end
function modifier_imba_doom_enemy:StatusEffectPriority() return 15 end

function modifier_imba_doom_enemy:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_doom_enemy:OnIntervalThink() ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType(), damage = self:GetAbility():GetSpecialValueFor("damage")}) end