--hero_slark

CreateEmptyTalents("slark")

imba_slark_shadow_dance = class({})

LinkLuaModifier("modifier_imba_shadow_dance_passive", "hero/hero_slark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_dance_active", "hero/hero_slark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_dance_effect", "hero/hero_slark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_dance_dummy", "hero/hero_slark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_dance_detect", "hero/hero_slark", LUA_MODIFIER_MOTION_NONE)

function imba_slark_shadow_dance:IsHiddenWhenStolen() 		return false end
function imba_slark_shadow_dance:IsRefreshable() 			return true end
function imba_slark_shadow_dance:IsStealable() 				return true end
function imba_slark_shadow_dance:IsNetherWardStealable()	return true end
function imba_slark_shadow_dance:GetIntrinsicModifierName() return "modifier_imba_shadow_dance_passive" end
function imba_slark_shadow_dance:GetCooldown(i) return (self:GetCaster():HasScepter() and self:GetSpecialValueFor("scepter_cooldown") or self.BaseClass.GetCooldown(self, i)) end
function imba_slark_shadow_dance:GetCastRange() return (self:GetCaster():HasScepter() and (self:GetSpecialValueFor("scepter_aoe") - self:GetCaster():GetCastRangeBonus()) or 0) end

function imba_slark_shadow_dance:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Slark.ShadowDance")
	caster:AddNewModifier(caster, self, "modifier_imba_shadow_dance_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_shadow_dance_passive = class({})

function modifier_imba_shadow_dance_passive:IsDebuff()			return false end
function modifier_imba_shadow_dance_passive:IsHidden() 			return true end
function modifier_imba_shadow_dance_passive:IsPurgable() 		return false end
function modifier_imba_shadow_dance_passive:IsPurgeException() 	return false end
function modifier_imba_shadow_dance_passive:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_imba_shadow_dance_passive:GetModifierInvisibilityLevel()
	if self:GetStackCount() == 2 or self:GetStackCount() == 1 then
		return 1
	end
	return 0
end
function modifier_imba_shadow_dance_passive:GetModifierMoveSpeedBonus_Percentage()
	if self:GetStackCount() == 4 or self:GetStackCount() == 1 then
		return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	end
end
function modifier_imba_shadow_dance_passive:GetModifierHealthRegenPercentage()
	if self:GetStackCount() == 4 or self:GetStackCount() == 1 then
		return self:GetAbility():GetSpecialValueFor("bonus_regen_pct")
	end
end
function modifier_imba_shadow_dance_passive:CheckState()
	if self:GetStackCount() == 1 or self:GetStackCount() == 2 then
		return {[MODIFIER_STATE_INVISIBLE] = true}
	end
end

function modifier_imba_shadow_dance_passive:OnCreated()
	if IsServer() then
		local dummy = CreateUnitByName("npc_dota_slark_visual", Vector(0,0,0), false, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS)
		dummy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_shadow_dance_detect", {})
		--self:StartIntervalThink(0.1)
	end
end

modifier_imba_shadow_dance_active = class({})

function modifier_imba_shadow_dance_active:IsDebuff()			return false end
function modifier_imba_shadow_dance_active:IsHidden() 			return false end
function modifier_imba_shadow_dance_active:IsPurgable() 		return false end
function modifier_imba_shadow_dance_active:IsPurgeException() 	return false end
function modifier_imba_shadow_dance_active:GetPriority() return MODIFIER_PRIORITY_ULTRA + 10 end
function modifier_imba_shadow_dance_active:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end

function modifier_imba_shadow_dance_active:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() then
		self:Destroy()
	end
end

function modifier_imba_shadow_dance_active:OnCreated()
	if IsServer() then
		--0, 1 absorigin
		--3 attach_eyeR
		--4 attach_eyeL
		local pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_CUSTOMORIGIN, nil, self:GetParent():GetTeamNumber())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeR", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eyeL", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		if self:GetCaster():HasScepter() then
			local pfx2 = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_slark/slark_shadow_dance_dummy_sceptor.vpcf", PATTACH_CUSTOMORIGIN, nil, self:GetParent():GetTeamNumber())
			ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx2, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx2, false, false, 15, false, false)
		end
		self.pfx_dummy = CreateModifierThinker(self:GetParent(), nil, "modifier_dummy_thinker", {duration = self:GetDuration() + 0.3}, self:GetParent():GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
		local pfx_dummy = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf", PATTACH_CUSTOMORIGIN, self.pfx_dummy)
		ParticleManager:SetParticleControlEnt(pfx_dummy, 1, self.pfx_dummy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.pfx_dummy:GetAbsOrigin(), true)
		local buff = self.pfx_dummy:FindModifierByName("modifier_dummy_thinker")
		buff:AddParticle(pfx_dummy, false, false, 15, false, false)
		if self:GetCaster():HasScepter() then
			local pfx_dummy2 = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy_sceptor.vpcf", PATTACH_CUSTOMORIGIN, self.pfx_dummy)
			ParticleManager:SetParticleControlEnt(pfx_dummy2, 1, self.pfx_dummy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.pfx_dummy:GetAbsOrigin(), true)
			buff:AddParticle(pfx_dummy2, false, false, 15, false, false)
		end
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_shadow_dance_active:OnRefresh()
	if IsServer() and self.pfx_dummy then
		local buff = self.pfx_dummy:FindModifierByName("modifier_dummy_thinker")
		buff:SetDuration(self:GetDuration(), false)
	end
end

function modifier_imba_shadow_dance_active:OnIntervalThink()
	if self.pfx_dummy and not self.pfx_dummy:IsNull() then
		self.pfx_dummy:SetAbsOrigin(self:GetParent():GetAbsOrigin())
	end
end

function modifier_imba_shadow_dance_active:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Slark.ShadowDance")
		if not self.pfx_dummy:IsNull() then
			self.pfx_dummy:RemoveModifierByName("modifier_dummy_thinker")
			self.pfx_dummy = nil
		end
	end
end

function modifier_imba_shadow_dance_active:IsAura() return true end
function modifier_imba_shadow_dance_active:GetAuraDuration() return 0.1 end
function modifier_imba_shadow_dance_active:GetModifierAura() return "modifier_imba_shadow_dance_effect" end
function modifier_imba_shadow_dance_active:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("scepter_aoe") end
function modifier_imba_shadow_dance_active:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_shadow_dance_active:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_shadow_dance_active:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_shadow_dance_active:GetAuraEntityReject(unit)
	if self:GetCaster():HasScepter() then
		return false
	end
	if self:GetCaster() == unit then
		return false
	end
	return true 
end

modifier_imba_shadow_dance_effect = class({})

function modifier_imba_shadow_dance_effect:IsDebuff()			return false end
function modifier_imba_shadow_dance_effect:IsHidden() 			return false end
function modifier_imba_shadow_dance_effect:IsPurgable() 		return false end
function modifier_imba_shadow_dance_effect:IsPurgeException() 	return false end
function modifier_imba_shadow_dance_effect:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true ,[MODIFIER_STATE_PROVIDES_VISION] = false} end
function modifier_imba_shadow_dance_effect:DeclareFunctions() return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_shadow_dance_effect:GetModifierProvidesFOWVision() return 0 end
function modifier_imba_shadow_dance_effect:GetStatusEffectName() return "particles/status_fx/status_effect_slark_shadow_dance.vpcf" end
function modifier_imba_shadow_dance_effect:StatusEffectPriority() return 15 end
function modifier_imba_shadow_dance_effect:GetPriority() return MODIFIER_PRIORITY_ULTRA + 10 end

modifier_imba_shadow_dance_dummy = class({})

function modifier_imba_shadow_dance_dummy:IsDebuff()			return false end
function modifier_imba_shadow_dance_dummy:IsHidden() 			return false end
function modifier_imba_shadow_dance_dummy:IsPurgable() 			return false end
function modifier_imba_shadow_dance_dummy:IsPurgeException() 	return false end

modifier_imba_shadow_dance_detect = class({})

function modifier_imba_shadow_dance_detect:IsDebuff()			return false end
function modifier_imba_shadow_dance_detect:IsHidden() 			return false end
function modifier_imba_shadow_dance_detect:IsPurgable() 		return false end
function modifier_imba_shadow_dance_detect:IsPurgeException() 	return false end
function modifier_imba_shadow_dance_detect:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_UNSELECTABLE] = true} end

function modifier_imba_shadow_dance_detect:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_shadow_dance_detect:OnIntervalThink()
	if not self:GetCaster() or self:GetCaster():IsNull() or not self:GetAbility() or self:GetAbility():IsNull() then
		self:GetParent():ForceKill(false)
		return
	end
	-- FOW + NIGHT = 1, NO FOW + NIGHT = 2, FOW + DAY = 4, NO FOW + DAY = 8
	local can_be_seen = self:GetParent():CanEntityBeSeenByMyTeam(self:GetCaster())
	local day = GameRules:IsDaytime()
	local buff = self:GetCaster():FindModifierByName("modifier_imba_shadow_dance_passive")
	if not buff then
		return
	end
	if day and can_be_seen then
		buff:SetStackCount(8)
		buff:GetParent():RemoveModifierByName("modifier_imba_shadow_dance_dummy")
	elseif day and not can_be_seen then
		buff:SetStackCount(4)
		buff:GetParent():AddNewModifier(buff:GetParent(), buff:GetAbility(), "modifier_imba_shadow_dance_dummy", {})
	elseif not day and can_be_seen then
		buff:SetStackCount(2)
		buff:GetParent():RemoveModifierByName("modifier_imba_shadow_dance_dummy")
	elseif not day and not can_be_seen then
		buff:SetStackCount(1)
		buff:GetParent():AddNewModifier(buff:GetParent(), buff:GetAbility(), "modifier_imba_shadow_dance_dummy", {})
	end
end