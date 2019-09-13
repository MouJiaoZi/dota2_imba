imba_abyssal_underlord_firestorm = class({})

LinkLuaModifier("modifier_imba_firestorm_thinker", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_firestorm_dot", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)

function imba_abyssal_underlord_firestorm:IsHiddenWhenStolen() 		return false end
function imba_abyssal_underlord_firestorm:IsRefreshable() 			return true end
function imba_abyssal_underlord_firestorm:IsStealable() 			return true end
function imba_abyssal_underlord_firestorm:IsNetherWardStealable()	return true end
function imba_abyssal_underlord_firestorm:GetAOERadius()			return self:GetSpecialValueFor("radius") end

function imba_abyssal_underlord_firestorm:OnAbilityPhaseStart()
	local pos = self:GetCursorPosition()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Start")
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_firestorm_pre.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.pfx, 0, pos)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))
	return true
end

function imba_abyssal_underlord_firestorm:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_AbyssalUnderlord.Firestorm.Start")
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function imba_abyssal_underlord_firestorm:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Cast")
	CreateModifierThinker(caster, self, "modifier_imba_firestorm_thinker", {}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_firestorm_thinker = class({})

function modifier_imba_firestorm_thinker:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("wave_count"))
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("wave_interval") + self:GetCaster():GetTalentValue("special_bonus_imba_abyssal_underlord_2"))
		self:OnIntervalThink()
	end
end

function modifier_imba_firestorm_thinker:OnIntervalThink()
	if self:GetStackCount() <= 0 then
		self:Destroy()
		return
	else
		self:SetStackCount(self:GetStackCount() - 1)
	end
	local caster = self:GetCaster()
	local thinker = self:GetParent()
	local ability = self:GetAbility()
	thinker:EmitSound("Hero_AbyssalUnderlord.Firestorm")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, thinker:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 4, Vector(ability:GetSpecialValueFor("radius"), 1, 1))
	ParticleManager:SetParticleControl(pfx, 5, Vector(0, 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), thinker:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local dmg = ability:GetSpecialValueFor("wave_damage") + caster:GetTalentValue("special_bonus_imba_abyssal_underlord_1")
	local dmg_building = dmg * (ability:GetSpecialValueFor("building_damage") / 100)
	for i=1, #enemy do
		enemy[i]:EmitSound("Hero_AbyssalUnderlord.Firestorm.Target")
		if enemy[i]:IsBuilding() then
			ApplyDamage({victim = enemy[i], attacker = caster, damage = dmg_building, damage_type = DAMAGE_TYPE_PHYSICAL})
		else
			enemy[i]:AddNewModifier(caster, ability, "modifier_imba_firestorm_dot", {duration = ability:GetSpecialValueFor("burn_duration")})
			ApplyDamage({victim = enemy[i], attacker = caster, damage = dmg, damage_type = ability:GetAbilityDamageType()})
		end
	end
	local thinkers = Entities:FindAllByNameWithin("npc_dota_thinker", thinker:GetAbsOrigin(), ability:GetSpecialValueFor("radius"))
	for i=1, #thinkers do
		if thinkers[i]:FindModifierByNameAndCaster("modifier_imba_pit_of_malice_thinker", caster) then
			thinkers[i]:FindModifierByNameAndCaster("modifier_imba_pit_of_malice_thinker", caster):SetDuration(thinkers[i]:FindModifierByNameAndCaster("modifier_imba_pit_of_malice_thinker", caster):GetRemainingTime() + thinkers[i]:FindModifierByNameAndCaster("modifier_imba_pit_of_malice_thinker", caster):GetAbility():GetSpecialValueFor("fs_extend_duration"), true)
		end
	end
end

modifier_imba_firestorm_dot = class({})

function modifier_imba_firestorm_dot:IsDebuff()			return true end
function modifier_imba_firestorm_dot:IsHidden() 		return false end
function modifier_imba_firestorm_dot:IsPurgable() 		return true end
function modifier_imba_firestorm_dot:IsPurgeException() return true end
function modifier_imba_firestorm_dot:GetEffectName() return "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave_burn.vpcf" end
function modifier_imba_firestorm_dot:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_firestorm_dot:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_imba_firestorm_dot:OnTooltip() return (self:GetAbility():GetSpecialValueFor("burn_damage") + self:GetStackCount() * self:GetAbility():GetSpecialValueFor("burn_stack_damage")) end

function modifier_imba_firestorm_dot:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("burn_interval"))
	end
end

function modifier_imba_firestorm_dot:OnRefresh()
	if IsServer() then
		self:SetStackCount(self:GetStackCount() + 1)
		if self:GetParent():GetTeamNumber() == DOTA_TEAM_NEUTRALS and not self:GetParent():IsAncient() and not self:GetParent():IsBoss() and self:GetParent():IsCreep() and self:GetStackCount() == self:GetAbility():GetSpecialValueFor("wave_count") - 1 then
			self:GetParent():Kill(self:GetAbility(), self:GetCaster())
		end
	end
end

function modifier_imba_firestorm_dot:OnIntervalThink()
	local target = self:GetParent()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local dmg = target:GetMaxHealth() * ((ability:GetSpecialValueFor("burn_damage") + self:GetStackCount() * ability:GetSpecialValueFor("burn_stack_damage")) / 100)
	ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type = ability:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
end









imba_abyssal_underlord_pit_of_malice = class({})

LinkLuaModifier("modifier_imba_pit_of_malice_thinker", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_pit_of_malice_apply", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_pit_of_malice_debuff", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_pit_of_malice_timer", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_pit_of_malice_disarm", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)

function imba_abyssal_underlord_pit_of_malice:IsHiddenWhenStolen() 		return false end
function imba_abyssal_underlord_pit_of_malice:IsRefreshable() 			return true end
function imba_abyssal_underlord_pit_of_malice:IsStealable() 			return true end
function imba_abyssal_underlord_pit_of_malice:IsNetherWardStealable()	return true end
function imba_abyssal_underlord_pit_of_malice:GetAOERadius()			return self:GetSpecialValueFor("radius") end

function imba_abyssal_underlord_pit_of_malice:OnAbilityPhaseStart()
	local pos = self:GetCursorPosition()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_AbyssalUnderlord.PitOfMalice.Start")
	local pfx_name = "particles/units/heroes/heroes_underlord/underlord_pitofmalice_pre.vpcf"
	if HeroItems:UnitHasItem(caster, "underlord_ti8_immortal_weapon") then
		pfx_name = "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_pre.vpcf"
	end
	self.pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.pfx, 0, pos)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	return true
end

function imba_abyssal_underlord_pit_of_malice:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_AbyssalUnderlord.PitOfMalice.Start")
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function imba_abyssal_underlord_pit_of_malice:OnSpellStart()
	local pos = self:GetCursorPosition()
	local caster = self:GetCaster()
	CreateModifierThinker(caster, self, "modifier_imba_pit_of_malice_thinker", {duration = self:GetSpecialValueFor("pit_duration")}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_pit_of_malice_thinker = class({})

function modifier_imba_pit_of_malice_thinker:OnCreated()
	if IsServer() then
		self.hitted = {}
		local pfx_name = "particles/units/heroes/heroes_underlord/underlord_pitofmalice.vpcf"
		if HeroItems:UnitHasItem(self:GetCaster(), "underlord_ti8_immortal_weapon") then
			self:GetParent():EmitSound("Hero_AbyssalUnderlord.PitOfMalice.TI8")
			pfx_name = "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice.vpcf"
		else
			self:GetParent():EmitSound("Hero_AbyssalUnderlord.PitOfMalice")
		end
		local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 13, 0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(500, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_pit_of_malice_thinker:IsAura() return true end
function modifier_imba_pit_of_malice_thinker:GetAuraDuration() return FrameTime() end
function modifier_imba_pit_of_malice_thinker:GetModifierAura() return "modifier_imba_pit_of_malice_apply" end
function modifier_imba_pit_of_malice_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_pit_of_malice_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_pit_of_malice_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_pit_of_malice_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end
function modifier_imba_pit_of_malice_thinker:GetAuraEntityReject(unit)
	if IsServer() then
		return self.hitted[unit:entindex()] and true or false
	end
end

function modifier_imba_pit_of_malice_thinker:OnDestroy()
	if IsServer() then
		self.hitted = nil
	end
end

modifier_imba_pit_of_malice_apply = class({})

function modifier_imba_pit_of_malice_apply:IsDebuff()			return true end
function modifier_imba_pit_of_malice_apply:IsHidden() 			return false end
function modifier_imba_pit_of_malice_apply:IsPurgable() 		return false end
function modifier_imba_pit_of_malice_apply:IsPurgeException()	return false end

function modifier_imba_pit_of_malice_apply:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_pit_of_malice_debuff", {duration = self:GetAbility():GetSpecialValueFor("ensnare_duration") + self:GetCaster():GetTalentValue("special_bonus_imba_abyssal_underlord_3")})
		self:GetParent():AddNewModifier(self:GetAuraOwner(), self:GetAbility(), "modifier_imba_pit_of_malice_timer", {duration = self:GetAbility():GetSpecialValueFor("pit_interval")})
		if self:GetParent():IsHero() then
			self:GetParent():EmitSound("Hero_AbyssalUnderlord.Pit.TargetHero")
		else
			self:GetParent():EmitSound("Hero_AbyssalUnderlord.Pit.Target")
		end
		self:Destroy()
	end
end

modifier_imba_pit_of_malice_debuff = class({})

function modifier_imba_pit_of_malice_debuff:IsDebuff()			return true end
function modifier_imba_pit_of_malice_debuff:IsHidden() 			return false end
function modifier_imba_pit_of_malice_debuff:IsPurgable() 		return true end
function modifier_imba_pit_of_malice_debuff:IsPurgeException() 	return true end
function modifier_imba_pit_of_malice_debuff:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_pit_of_malice_debuff:GetEffectName() return "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf" end
function modifier_imba_pit_of_malice_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_pit_of_malice_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_imba_pit_of_malice_debuff:StatusEffectPriority() return 15 end
function modifier_imba_pit_of_malice_debuff:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_pit_of_malice_debuff:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and keys.target == self:GetCaster() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_pit_of_malice_disarm", {duration = self:GetAbility():GetSpecialValueFor("disarm_duration")})
		self:GetParent():EmitSound("DOTA_Item.HeavensHalberd.Activate")
	end
end

modifier_imba_pit_of_malice_timer = class({})

function modifier_imba_pit_of_malice_timer:IsDebuff()			return false end
function modifier_imba_pit_of_malice_timer:IsHidden() 			return true end
function modifier_imba_pit_of_malice_timer:IsPurgable() 		return false end
function modifier_imba_pit_of_malice_timer:IsPurgeException() 	return false end
function modifier_imba_pit_of_malice_timer:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_pit_of_malice_timer:OnCreated()
	if IsServer() and self:GetCaster() then
		self:GetCaster():FindModifierByName("modifier_imba_pit_of_malice_thinker").hitted[self:GetParent():entindex()] = true
	end
end

function modifier_imba_pit_of_malice_timer:OnDestroy()
	if IsServer() and self:GetCaster() then
		self:GetCaster():FindModifierByName("modifier_imba_pit_of_malice_thinker").hitted[self:GetParent():entindex()] = nil
	end
end

modifier_imba_pit_of_malice_disarm = class({})

function modifier_imba_pit_of_malice_disarm:IsDebuff()			return true end
function modifier_imba_pit_of_malice_disarm:IsHidden() 			return false end
function modifier_imba_pit_of_malice_disarm:IsPurgable() 		return true end
function modifier_imba_pit_of_malice_disarm:IsPurgeException() 	return true end
function modifier_imba_pit_of_malice_disarm:CheckState() return {[MODIFIER_STATE_DISARMED] = true} end
function modifier_imba_pit_of_malice_disarm:GetEffectName() return "particles/items2_fx/heavens_halberd.vpcf" end
function modifier_imba_pit_of_malice_disarm:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_pit_of_malice_disarm:ShouldUseOverheadOffset() return true end


imba_abyssal_underlord_atrophy_aura = class({})

LinkLuaModifier("modifier_imba_atrophy_aura_passive", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_atrophy_aura_debuff", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_atrophy_aura_temp", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_atrophy_aura_permanent", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_atrophy_aura_scepter_aura", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_atrophy_aura_scepter_buff", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_atrophy_aura_active_buff", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)

function imba_abyssal_underlord_atrophy_aura:IsHiddenWhenStolen() 		return false end
function imba_abyssal_underlord_atrophy_aura:IsRefreshable() 			return true end
function imba_abyssal_underlord_atrophy_aura:IsStealable() 				return true end
function imba_abyssal_underlord_atrophy_aura:IsNetherWardStealable()	return true end
function imba_abyssal_underlord_atrophy_aura:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_abyssal_underlord_atrophy_aura:GetIntrinsicModifierName() return "modifier_imba_atrophy_aura_passive" end

function imba_abyssal_underlord_atrophy_aura:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	local stacks = (caster:GetModifierStackCount("modifier_imba_atrophy_aura_temp", nil) + caster:GetModifierStackCount("modifier_imba_atrophy_aura_permanent", nil)) / 2
	local ally = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	for i=1, #ally do
		if not ally[i]:HasModifier("modifier_imba_atrophy_aura_passive") then
			local buff = ally[i]:AddNewModifier(caster, self, "modifier_imba_atrophy_aura_active_buff", {duration = self:GetSpecialValueFor("active_duration")})
			buff:SetStackCount(stacks)
		end
	end
	caster:EmitSound("Hero_Spirit_Breaker.Bulldoze.Cast")
end

modifier_imba_atrophy_aura_passive = class({})

function modifier_imba_atrophy_aura_passive:IsDebuff()			return false end
function modifier_imba_atrophy_aura_passive:IsHidden() 			return true end
function modifier_imba_atrophy_aura_passive:IsPurgable() 		return false end
function modifier_imba_atrophy_aura_passive:IsPurgeException()	return false end
function modifier_imba_atrophy_aura_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end

function modifier_imba_atrophy_aura_passive:IsAura() return not self:GetParent():PassivesDisabled() end
function modifier_imba_atrophy_aura_passive:GetAuraDuration() return 0.1 end
function modifier_imba_atrophy_aura_passive:GetModifierAura() return "modifier_imba_atrophy_aura_debuff" end
function modifier_imba_atrophy_aura_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_atrophy_aura_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_atrophy_aura_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_atrophy_aura_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imba_atrophy_aura_passive:OnDeath(keys)
	if not IsServer() then
		return
	end
	local unit = keys.unit
	local caster = self:GetParent()
	if IsEnemy(unit, caster) and caster:IsAlive() and not caster:IsIllusion() and (unit:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("radius") then
		local ability = self:GetAbility()
		local duration = caster:HasScepter() and ability:GetSpecialValueFor("bonus_damage_duration_scepter") or ability:GetSpecialValueFor("bonus_damage_duration")
		if not unit:IsHero() then
			caster:AddNewModifier(caster, ability, "modifier_imba_atrophy_aura_temp", {duration = duration, atk = ability:GetSpecialValueFor("bonus_damage_from_creep")})
		else
			caster:AddNewModifier(caster, ability, "modifier_imba_atrophy_aura_temp", {duration = duration, atk = ability:GetSpecialValueFor("bonus_damage_from_hero")})
			local buff = caster:FindModifierByName("modifier_imba_atrophy_aura_permanent")
			if not buff then
				buff = caster:AddNewModifier(caster, ability, "modifier_imba_atrophy_aura_permanent", {})
				buff:SetStackCount(ability:GetSpecialValueFor("permanent_bonus") + caster:GetTalentValue("special_bonus_imba_abyssal_underlord_4"))
			else
				buff:SetStackCount(buff:GetStackCount() + ability:GetSpecialValueFor("permanent_bonus") + caster:GetTalentValue("special_bonus_imba_abyssal_underlord_4"))
			end
		end
	end
end

function modifier_imba_atrophy_aura_passive:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_atrophy_aura_passive:OnIntervalThink()
	if self.caster:HasScepter() and not self.caster:IsIllusion() and not self.caster:HasModifier("modifier_imba_atrophy_aura_scepter_aura") then
		self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_imba_atrophy_aura_scepter_aura", {})
	else
		self.caster:RemoveModifierByName("modifier_imba_atrophy_aura_scepter_aura")
	end
end

modifier_imba_atrophy_aura_temp = class({})

function modifier_imba_atrophy_aura_temp:IsDebuff()			return false end
function modifier_imba_atrophy_aura_temp:IsHidden() 		return false end
function modifier_imba_atrophy_aura_temp:IsPurgable() 		return false end
function modifier_imba_atrophy_aura_temp:IsPurgeException()	return false end
function modifier_imba_atrophy_aura_temp:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_atrophy_aura_temp:GetModifierPreAttack_BonusDamage() return self:GetParent():PassivesDisabled() and 0 or self:GetStackCount() end

function modifier_imba_atrophy_aura_temp:OnCreated(keys)
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_atrophy_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 2, Vector(120, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self.atk_table = {}
		self:AddStack(keys.atk)
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_atrophy_aura_temp:OnRefresh(keys)
	if IsServer() then
		self:AddStack(keys.atk)
	end
end

function modifier_imba_atrophy_aura_temp:AddStack(iStack)
	if not self.atk_table[GameRules:GetGameTime()] then
		self.atk_table[GameRules:GetGameTime()] = iStack
	else
		self.atk_table[GameRules:GetGameTime() + RandomFloat(0.0000000001, 0.0001)] = iStack
	end
end

function modifier_imba_atrophy_aura_temp:OnIntervalThink()
	local stacks = 0
	for k, v in pairs(self.atk_table) do
		if k + self:GetDuration() < GameRules:GetGameTime() then
			self.atk_table[k] = nil
		else
			stacks = stacks + v
		end
	end
	self:SetStackCount(stacks)
end

function modifier_imba_atrophy_aura_temp:OnDestroy() self.atk_table = nil end

modifier_imba_atrophy_aura_permanent = class({})

function modifier_imba_atrophy_aura_permanent:IsDebuff()			return false end
function modifier_imba_atrophy_aura_permanent:IsHidden() 			return false end
function modifier_imba_atrophy_aura_permanent:IsPurgable() 			return false end
function modifier_imba_atrophy_aura_permanent:IsPurgeException()	return false end
function modifier_imba_atrophy_aura_permanent:RemoveOnDeath() return false end
function modifier_imba_atrophy_aura_permanent:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_atrophy_aura_permanent:GetModifierPreAttack_BonusDamage() return self:GetParent():PassivesDisabled() and 0 or self:GetStackCount() end

function modifier_imba_atrophy_aura_permanent:OnCreated(keys)
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_atrophy_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 2, Vector(120, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_imba_atrophy_aura_debuff = class({})

function modifier_imba_atrophy_aura_debuff:IsDebuff()			return true end
function modifier_imba_atrophy_aura_debuff:IsHidden() 			return false end
function modifier_imba_atrophy_aura_debuff:IsPurgable() 		return false end
function modifier_imba_atrophy_aura_debuff:IsPurgeException()	return false end
function modifier_imba_atrophy_aura_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_atrophy_aura_debuff:GetModifierBaseDamageOutgoing_Percentage() return 0 - self:GetAbility():GetSpecialValueFor("damage_reduction_pct") end

modifier_imba_atrophy_aura_active_buff = class({})

function modifier_imba_atrophy_aura_active_buff:IsDebuff()			return false end
function modifier_imba_atrophy_aura_active_buff:IsHidden() 			return false end
function modifier_imba_atrophy_aura_active_buff:IsPurgable() 		return false end
function modifier_imba_atrophy_aura_active_buff:IsPurgeException()	return false end
function modifier_imba_atrophy_aura_active_buff:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_atrophy_aura_active_buff:GetModifierPreAttack_BonusDamage() return self:GetStackCount() end

modifier_imba_atrophy_aura_scepter_aura = class({})

function modifier_imba_atrophy_aura_scepter_aura:IsDebuff()			return false end
function modifier_imba_atrophy_aura_scepter_aura:IsHidden() 		return true end
function modifier_imba_atrophy_aura_scepter_aura:IsPurgable() 		return false end
function modifier_imba_atrophy_aura_scepter_aura:IsPurgeException()	return false end

function modifier_imba_atrophy_aura_scepter_aura:IsAura() return not self:GetParent():PassivesDisabled() end
function modifier_imba_atrophy_aura_scepter_aura:GetAuraDuration() return 0.1 end
function modifier_imba_atrophy_aura_scepter_aura:GetModifierAura() return "modifier_imba_atrophy_aura_scepter_buff" end
function modifier_imba_atrophy_aura_scepter_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_atrophy_aura_scepter_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_atrophy_aura_scepter_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_atrophy_aura_scepter_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_atrophy_aura_scepter_aura:GetAuraEntityReject(unit) return unit:HasModifier("modifier_imba_atrophy_aura_scepter_aura") end

modifier_imba_atrophy_aura_scepter_buff = class({})

function modifier_imba_atrophy_aura_scepter_buff:IsDebuff()			return false end
function modifier_imba_atrophy_aura_scepter_buff:IsHidden() 		return false end
function modifier_imba_atrophy_aura_scepter_buff:IsPurgable() 		return false end
function modifier_imba_atrophy_aura_scepter_buff:IsPurgeException()	return false end
function modifier_imba_atrophy_aura_scepter_buff:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_atrophy_aura_scepter_buff:GetModifierPreAttack_BonusDamage() return (self:GetCaster():GetModifierStackCount("modifier_imba_atrophy_aura_temp", nil) + self:GetCaster():GetModifierStackCount("modifier_imba_atrophy_aura_permanent", nil)) / 2 end

imba_abyssal_underlord_dark_rift = class({})

LinkLuaModifier("modifier_imba_double_gate", "hero/hero_abyssal_underlord.lua", LUA_MODIFIER_MOTION_NONE)

function imba_abyssal_underlord_dark_rift:IsHiddenWhenStolen() 		return false end
function imba_abyssal_underlord_dark_rift:IsRefreshable() 			return true end
function imba_abyssal_underlord_dark_rift:IsStealable() 			return true end
function imba_abyssal_underlord_dark_rift:IsNetherWardStealable()	return false end
function imba_abyssal_underlord_dark_rift:GetAssociatedSecondaryAbilities() return "imba_abyssal_underlord_cancel_dark_rift" end
function imba_abyssal_underlord_dark_rift:GetCastRange(vLocation, hTarget)
	if IsClient() then
		return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus()
	else
		return 0
	end
end

function imba_abyssal_underlord_dark_rift:OnSpellStart()
	local target = self:GetCursorTarget()
	local pos = self:GetCursorPosition()
	local caster = self:GetCaster()
	if not target then
		local unit = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
		for i=1, #unit do
			if not unit[i]:IsCourier() then
				target = unit[i]
				break
			end
		end
	end
	if target == caster then
		target = CDOTAGamerules.IMBA_FOUNTAIN[caster:GetTeamNumber()]
	end
	caster:AddNewModifier(caster, self, "modifier_imba_double_gate", {duration = self:GetSpecialValueFor("teleport_delay"), target = target:entindex()})
end

modifier_imba_double_gate = class({})

function modifier_imba_double_gate:IsDebuff()			return false end
function modifier_imba_double_gate:IsHidden() 			return false end
function modifier_imba_double_gate:IsPurgable() 		return false end
function modifier_imba_double_gate:IsPurgeException()	return false end

function modifier_imba_double_gate:OnCreated(keys)
	if IsServer() then
		self.target = EntIndexToHScript(keys.target)
		local pfx_caster = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx_caster, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx_caster, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
		self:AddParticle(pfx_caster, false, false, 15, false, false)
		local pfx_target = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
		self:AddParticle(pfx_target, false, false, 15, false, false)
		self:GetParent():EmitSound("Hero_AbyssalUnderlord.DarkRift.Cast")
		self.target:EmitSound("Hero_AbyssalUnderlord.DarkRift.Target")
		self:GetParent():SwapAbilities("imba_abyssal_underlord_dark_rift", "imba_abyssal_underlord_cancel_dark_rift", false, true)
	end
end

function modifier_imba_double_gate:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_AbyssalUnderlord.DarkRift.Cast")
		self.target:StopSound("Hero_AbyssalUnderlord.DarkRift.Target")
		local max_times = 1
		if self:GetElapsedTime() >= self:GetDuration() then
			self:GetParent():EmitSound("Hero_AbyssalUnderlord.DarkRift.Complete")
			self:GetParent():EmitSound("Hero_AbyssalUnderlord.DarkRift.Aftershock")
			local unit = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
			if self:GetCaster():HasScepter() then
				max_times = #unit
			end
			for i=1, #unit do
				FindClearSpaceForUnit(unit[i], self.target:GetAbsOrigin(), true)
			end
		else
			self:GetParent():EmitSound("Hero_AbyssalUnderlord.DarkRift.Cancel")
		end
		self:GetParent():SwapAbilities("imba_abyssal_underlord_dark_rift", "imba_abyssal_underlord_cancel_dark_rift", true, false)
		local firestorm = self:GetCaster():FindAbilityByName("imba_abyssal_underlord_firestorm")
		local pit = self:GetCaster():FindAbilityByName("imba_abyssal_underlord_pit_of_malice")
		if firestorm and firestorm:GetLevel() > 0 then
			self:GetCaster():SetCursorPosition(self:GetParent():GetAbsOrigin())
			for i=1, max_times do
				firestorm:OnSpellStart()
			end
		end
		if pit and pit:GetLevel() > 0 then
			self:GetCaster():SetCursorPosition(self:GetParent():GetAbsOrigin())
			pit:OnSpellStart()
		end
		self.target = nil
	end
end

imba_abyssal_underlord_cancel_dark_rift = class({})

function imba_abyssal_underlord_cancel_dark_rift:IsHiddenWhenStolen() 		return false end
function imba_abyssal_underlord_cancel_dark_rift:IsRefreshable() 			return true end
function imba_abyssal_underlord_cancel_dark_rift:IsStealable() 				return true end
function imba_abyssal_underlord_cancel_dark_rift:IsNetherWardStealable()	return false end
function imba_abyssal_underlord_cancel_dark_rift:IsHiddenWhenStolen() return true end
function imba_abyssal_underlord_cancel_dark_rift:IsTalentAbility() return true end
function imba_abyssal_underlord_cancel_dark_rift:GetAssociatedPrimaryAbilities() return "imba_abyssal_underlord_dark_rift" end

function imba_abyssal_underlord_cancel_dark_rift:OnSpellStart()
	self:GetCaster():RemoveModifierByName("modifier_imba_double_gate")
end