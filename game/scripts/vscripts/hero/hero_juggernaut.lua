CreateEmptyTalents("juggernaut")

--models/items/juggernaut/arcana/juggernaut_arcana_front_page.vmdl

imba_juggernaut_blade_fury = class({})

LinkLuaModifier("modifier_imba_juggernaut_blade_fury", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_juggernaut_blade_fury_debuff", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)

function imba_juggernaut_blade_fury:IsHiddenWhenStolen() 	return false end
function imba_juggernaut_blade_fury:IsRefreshable() 		return true end
function imba_juggernaut_blade_fury:IsStealable() 			return true end
function imba_juggernaut_blade_fury:IsNetherWardStealable() return true end

function imba_juggernaut_blade_fury:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("effect_radius") - self:GetCaster():GetCastRangeBonus() end

function imba_juggernaut_blade_fury:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_imba_juggernaut_blade_fury", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
end

modifier_imba_juggernaut_blade_fury = class({})

function modifier_imba_juggernaut_blade_fury:IsDebuff()				return false end
function modifier_imba_juggernaut_blade_fury:IsHidden() 			return false end
function modifier_imba_juggernaut_blade_fury:IsPurgable() 			return false end
function modifier_imba_juggernaut_blade_fury:IsPurgeException() 	return false end
function modifier_imba_juggernaut_blade_fury:CheckState() return {[MODIFIER_STATE_MAGIC_IMMUNE] = true} end
function modifier_imba_juggernaut_blade_fury:IsAura() return true end
function modifier_imba_juggernaut_blade_fury:GetAuraDuration() return 0.1 end
function modifier_imba_juggernaut_blade_fury:GetModifierAura() return "modifier_imba_juggernaut_blade_fury_debuff" end
function modifier_imba_juggernaut_blade_fury:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("effect_radius") end
function modifier_imba_juggernaut_blade_fury:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_juggernaut_blade_fury:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_juggernaut_blade_fury:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_juggernaut_blade_fury:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_juggernaut_blade_fury:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_1 end

function modifier_imba_juggernaut_blade_fury:OnCreated()
	if IsServer() then
		self:GetCaster():Purge(false, true, false, false, false)
		if HeroItems:UnitHasItem(self:GetCaster(), "juggernaut_arcana") then
			local pfx_dragon = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_blade_fury.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			self:AddParticle(pfx_dragon, false, false, 15, false, false)
		end
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(pfx, 5, Vector(self:GetAbility():GetSpecialValueFor("effect_radius") + 100, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_tick"))
	end
end

function modifier_imba_juggernaut_blade_fury:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("damage_per_sec") / (1.0 / self:GetAbility():GetSpecialValueFor("damage_tick"))
	local caster = self:GetParent()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("effect_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = self:GetParent(),
							damage = dmg,
							damage_type = self:GetAbility():GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
		EmitSoundOnLocationWithCaster(enemy:GetAbsOrigin(), "Hero_Juggernaut.BladeFury.Impact", enemy)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_tgt.vpcf", PATTACH_POINT_FOLLOW, enemy)
		ParticleManager:SetParticleControlEnt(pfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function modifier_imba_juggernaut_blade_fury:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		EmitSoundOn("Hero_Juggernaut.BladeFuryStop", caster)
		StopSoundOn("Hero_Juggernaut.BladeFuryStart", caster)
	end
end

modifier_imba_juggernaut_blade_fury_debuff = class({})

function modifier_imba_juggernaut_blade_fury_debuff:IsDebuff()			return true end
function modifier_imba_juggernaut_blade_fury_debuff:IsHidden() 			return false end
function modifier_imba_juggernaut_blade_fury_debuff:IsPurgable() 		return false end
function modifier_imba_juggernaut_blade_fury_debuff:IsPurgeException() 	return false end

function modifier_imba_juggernaut_blade_fury_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_juggernaut_blade_fury_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("ms_slow_tooltip")) end

imba_juggernaut_healing_ward = class({})

function imba_juggernaut_healing_ward:IsHiddenWhenStolen() 		return false end
function imba_juggernaut_healing_ward:IsRefreshable() 			return true end
function imba_juggernaut_healing_ward:IsStealable() 			return true end
function imba_juggernaut_healing_ward:IsNetherWardStealable() 	return false end

function imba_juggernaut_healing_ward:GetAOERadius() return self:GetSpecialValueFor("heal_radius") end

function imba_juggernaut_healing_ward:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local health = self:GetSpecialValueFor("health")
	local unit = CreateUnitByName("npc_imba_juggernaut_healing_ward", pos, true, caster, caster, caster:GetTeamNumber())
	SetCreatureHealth(unit, health, true)
	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	unit:SetControllableByPlayer(caster:GetPlayerID(), true)
	Timers:CreateTimer(0.1, function()
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		unit:MoveToNPC(caster)
	end)
	local ability = unit:FindAbilityByName("imba_juggernaut_healing_ward_passive")
	local ability2 = unit:FindAbilityByName("imba_juggernaut_healing_ward_upgrade")
	if ability then
		ability:SetLevel(self:GetLevel())
		unit:AddNewModifier(unit, ability, "modifier_imba_healing_ward_passive", {duration = self:GetSpecialValueFor("duration")})
	end
	local a = ability2 and ability2:SetLevel(self:GetLevel()) or 1
	unit:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Juggernaut.HealingWard.Cast", unit)
end

imba_juggernaut_healing_ward_passive = class({})

LinkLuaModifier("modifier_imba_healing_ward_passive", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_healing_ward_buff", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)

function imba_juggernaut_healing_ward_passive:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("heal_radius") end

modifier_imba_healing_ward_passive = class({})

function modifier_imba_healing_ward_passive:IsDebuff()			return false end
function modifier_imba_healing_ward_passive:IsHidden() 			return true end
function modifier_imba_healing_ward_passive:IsPurgable() 		return false end
function modifier_imba_healing_ward_passive:IsPurgeException() 	return false end
function modifier_imba_healing_ward_passive:RemoveOnDeath() 	return true end
function modifier_imba_healing_ward_passive:IsAura() return true end
function modifier_imba_healing_ward_passive:GetAuraDuration() return 2.5 end
function modifier_imba_healing_ward_passive:GetModifierAura() return "modifier_imba_healing_ward_buff" end
function modifier_imba_healing_ward_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("heal_radius") end
function modifier_imba_healing_ward_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_healing_ward_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_healing_ward_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imba_healing_ward_passive:OnCreated()
	if IsServer() then
		EmitSoundOn("Hero_Juggernaut.HealingWard.Loop", self:GetParent())
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("heal_radius"), 0, -1 * self:GetAbility():GetSpecialValueFor("heal_radius")))
		ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "flame_attachment", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_healing_ward_passive:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_imba_healing_ward_passive:GetModifierHPRegenAmplify_Percentage() return -100 end
function modifier_imba_healing_ward_passive:GetModifierIncomingDamage_Percentage() return -10000 end
function modifier_imba_healing_ward_passive:OnAttackLanded(keys)
	if not IsServer() or keys.target ~= self:GetParent() then
		return
	end
	local dmg = 1
	if keys.attacker:IsRealHero() or keys.attacker:IsBuilding() then
		dmg = 3
	end
	if self:GetParent():GetHealth() - dmg <= 0 then
		self:Destroy()
		self:GetParent():Kill(nil, keys.attacker)
	else
		self:GetParent():SetHealth(self:GetParent():GetHealth() - dmg)
	end
end

function modifier_imba_healing_ward_passive:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Juggernaut.HealingWard.Loop", self:GetParent())
		EmitSoundOn("Hero_Juggernaut.HealingWard.Stop", self:GetParent())
	end
end

modifier_imba_healing_ward_buff = class({})

function modifier_imba_healing_ward_buff:IsDebuff()			return false end
function modifier_imba_healing_ward_buff:IsHidden() 		return false end
function modifier_imba_healing_ward_buff:IsPurgable() 		return false end
function modifier_imba_healing_ward_buff:IsPurgeException() return false end

function modifier_imba_healing_ward_buff:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end
function modifier_imba_healing_ward_buff:GetModifierHealthRegenPercentage()
	if not self:GetAbility() then
		self:Destroy()
	else
		return self:GetAbility():GetSpecialValueFor("heal_per_sec")
	end
end

imba_juggernaut_healing_ward_upgrade = class({})

LinkLuaModifier("modifier_imba_healing_totem_passive", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_healing_totem_buff", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)

function imba_juggernaut_healing_ward_upgrade:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("heal_radius") end

function imba_juggernaut_healing_ward_upgrade:OnSpellStart()
	local caster = self:GetCaster():GetOwnerEntity()
	local pos = self:GetCaster():GetAbsOrigin()
	local health = self:GetSpecialValueFor("health")
	local unit = CreateUnitByName("npc_imba_juggernaut_healing_totem", pos, true, caster, caster, caster:GetTeamNumber())
	SetCreatureHealth(unit, health, true)
	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	unit:SetControllableByPlayer(caster:GetPlayerID(), true)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward_eruption.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:ReleaseParticleIndex(pfx)
	local ability = unit:FindAbilityByName("imba_juggernaut_healing_totem_passive")
	if ability then
		ability:SetLevel(self:GetLevel())
		unit:AddNewModifier(unit, ability, "modifier_imba_healing_totem_passive", {duration = self:GetCaster():FindModifierByName("modifier_kill"):GetRemainingTime()})
	end
	unit:AddNewModifier(unit, self, "modifier_kill", {duration = self:GetCaster():FindModifierByName("modifier_kill"):GetRemainingTime()})
	StopSoundOn("Hero_Juggernaut.HealingWard.Loop", self:GetCaster())
	if self:GetCaster():FindModifierByName("modifier_imba_healing_ward_passive") then
		self:GetCaster():FindModifierByName("modifier_imba_healing_ward_passive"):Destroy()
	end
	self:GetCaster():Kill(nil, self:GetCaster())
end

modifier_imba_healing_totem_passive = class({})

function modifier_imba_healing_totem_passive:IsDebuff()			return false end
function modifier_imba_healing_totem_passive:IsHidden() 		return true end
function modifier_imba_healing_totem_passive:IsPurgable() 		return false end
function modifier_imba_healing_totem_passive:IsPurgeException() return false end
function modifier_imba_healing_totem_passive:RemoveOnDeath() 	return true end
function modifier_imba_healing_totem_passive:IsAura() return true end
function modifier_imba_healing_totem_passive:GetAuraDuration() return 2.5 end
function modifier_imba_healing_totem_passive:GetModifierAura() return "modifier_imba_healing_totem_buff" end
function modifier_imba_healing_totem_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("heal_radius") end
function modifier_imba_healing_totem_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_healing_totem_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_healing_totem_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imba_healing_totem_passive:OnCreated()
	if IsServer() then
		EmitSoundOn("Hero_Juggernaut.HealingWard.Loop", self:GetParent())
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("heal_radius"), 0, -1 * self:GetAbility():GetSpecialValueFor("heal_radius")))
		ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "flame_attachment", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_healing_totem_passive:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_imba_healing_totem_passive:GetModifierHPRegenAmplify_Percentage() return -100 end
function modifier_imba_healing_totem_passive:GetModifierIncomingDamage_Percentage() return -10000 end
function modifier_imba_healing_totem_passive:OnAttackLanded(keys)
	if not IsServer() or keys.target ~= self:GetParent() then
		return
	end
	local dmg = 1
	if keys.attacker:IsRealHero() or keys.attacker:IsBuilding() then
		dmg = 3
	end
	if self:GetParent():GetHealth() - dmg <= 0 then
		self:Destroy()
		self:GetParent():Kill(nil, keys.attacker)
	else
		self:GetParent():SetHealth(self:GetParent():GetHealth() - dmg)
	end
end

function modifier_imba_healing_totem_passive:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Juggernaut.HealingWard.Loop", self:GetParent())
		EmitSoundOn("Hero_Juggernaut.HealingWard.Stop", self:GetParent())
	end
end

modifier_imba_healing_totem_buff = class({})

function modifier_imba_healing_totem_buff:IsDebuff()		return false end
function modifier_imba_healing_totem_buff:IsHidden() 		return false end
function modifier_imba_healing_totem_buff:IsPurgable() 		return false end
function modifier_imba_healing_totem_buff:IsPurgeException() return false end

function modifier_imba_healing_totem_buff:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end
function modifier_imba_healing_totem_buff:GetModifierHealthRegenPercentage()
	if not self:GetAbility() then
		self:Destroy()
	else
		return self:GetAbility():GetSpecialValueFor("heal_per_sec")
	end
end

imba_juggernaut_blade_dance = class({})

LinkLuaModifier("modifier_imba_blade_dance_passive", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_blade_dance_check", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_blade_dance_stacks", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)

function imba_juggernaut_blade_dance:GetIntrinsicModifierName() return "modifier_imba_blade_dance_passive" end

modifier_imba_blade_dance_check = class({})

function modifier_imba_blade_dance_check:IsHidden()			return true end
function modifier_imba_blade_dance_check:IsDebuff()			return false end
function modifier_imba_blade_dance_check:IsPurgable() 		return false end
function modifier_imba_blade_dance_check:IsPurgeException() return false end

modifier_imba_blade_dance_passive = class({})

function modifier_imba_blade_dance_passive:IsHidden()			return true end
function modifier_imba_blade_dance_passive:IsDebuff()			return false end
function modifier_imba_blade_dance_passive:IsPurgable() 		return false end
function modifier_imba_blade_dance_passive:IsPurgeException() 	return false end

function modifier_imba_blade_dance_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE} end

function modifier_imba_blade_dance_passive:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() and keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():PassivesDisabled() and self:GetParent().splitattack then
		if PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("crit_chance")) then
			self:GetParent():EmitSound("Hero_Juggernaut.BladeDance")
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_blade_dance_check", {})
			return self:GetAbility():GetSpecialValueFor("crit_damage")
		else
			self:GetParent():RemoveModifierByName("modifier_imba_blade_dance_check")
			return 0
		end
	end
end

function modifier_imba_blade_dance_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or keys.target:IsOther() or keys.target:IsBuilding() or not keys.target:IsAlive() then
		return
	end
	if self:GetParent():HasModifier("modifier_imba_blade_dance_check") then
		self:GetParent():RemoveModifierByName("modifier_imba_blade_dance_check")
		self:GetParent():AddModifierStacks(self:GetParent(), self:GetAbility(), "modifier_imba_blade_dance_stacks", {duration = self:GetAbility():GetSpecialValueFor("bonus_duration")}, 1, false, true)
		if HeroItems:UnitHasItem(self:GetCaster(), "juggernaut_arcana") then
			local pfx_crit = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_crit_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
			ParticleManager:SetParticleControlEnt(pfx_crit, 1, keys.target, PATTACH_ABSORIGIN_FOLLOW, "", keys.target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx_crit)
		end
	end
	local buff = self:GetParent():FindModifierByName("modifier_imba_blade_dance_stacks")
	if buff then
		buff:SetDuration(buff:GetDuration(), true)
	end
end

modifier_imba_blade_dance_stacks = class({})

function modifier_imba_blade_dance_stacks:IsHidden()			return false end
function modifier_imba_blade_dance_stacks:IsDebuff()			return false end
function modifier_imba_blade_dance_stacks:IsPurgable() 			return true end
function modifier_imba_blade_dance_stacks:IsPurgeException() 	return true end
function modifier_imba_blade_dance_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_blade_dance_stacks:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetParent():PassivesDisabled() then
		return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_ms"))
	else
		return nil
	end
end
function modifier_imba_blade_dance_stacks:GetModifierBonusStats_Agility()
	if not self:GetParent():PassivesDisabled() then
		return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_agi"))
	else
		return nil
	end
end

imba_juggernaut_omni_slash = class({})

LinkLuaModifier("modifier_imba_omni_slash_caster", "hero/hero_juggernaut", LUA_MODIFIER_MOTION_NONE)

function imba_juggernaut_omni_slash:IsHiddenWhenStolen() 		return false end
function imba_juggernaut_omni_slash:IsRefreshable() 			return true end
function imba_juggernaut_omni_slash:IsStealable() 				return true end
function imba_juggernaut_omni_slash:IsNetherWardStealable() 	return true end
function imba_juggernaut_omni_slash:GetCooldown(i) return (self:GetCaster():HasScepter() and self:GetSpecialValueFor("cooldown_scepter") or self.BaseClass.GetCooldown(self, i)) end

function imba_juggernaut_omni_slash:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_imba_omni_slash_caster") then
		caster:FindModifierByName("modifier_imba_omni_slash_caster"):Destroy()
	end
	local target = self:GetCursorTarget()
	target:TriggerSpellAbsorb(self)
	target:TriggerSpellReflect(self)
	local attacks = self:GetSpecialValueFor("jump_amount") + math.floor(caster:GetAgility() / self:GetSpecialValueFor("agi_per_jump"))
	local buff = caster:AddNewModifier(caster, self, "modifier_imba_omni_slash_caster", {target = target:entindex(), stack = attacks})
	buff:SetStackCount(attacks)
	if HeroItems:UnitHasItem(self:GetCaster(), "juggernaut_arcana") then
		local pfx_dash = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_dash.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx_dash, 0, caster, PATTACH_ABSORIGIN, nil, caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx_dash, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx_dash, 2, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx_dash)
	end
end

modifier_imba_omni_slash_caster = class({})

function modifier_imba_omni_slash_caster:IsHidden()				return false end
function modifier_imba_omni_slash_caster:IsDebuff()				return false end
function modifier_imba_omni_slash_caster:IsPurgable() 			return false end
function modifier_imba_omni_slash_caster:IsPurgeException() 	return false end
function modifier_imba_omni_slash_caster:GetStatusEffectName()  return "particles/status_fx/status_effect_omnislash.vpcf" end
function modifier_imba_omni_slash_caster:StatusEffectPriority() return 16 end
function modifier_imba_omni_slash_caster:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_TETHERED] = true} end
function modifier_imba_omni_slash_caster:DeclareFunctions() return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_omni_slash_caster:GetModifierBaseAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_omni_slash_caster:GetModifierMoveSpeed_Absolute() return 1 end
function modifier_imba_omni_slash_caster:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_4 end

function modifier_imba_omni_slash_caster:OnCreated(keys)
	if IsServer() then
		local stacks = keys.stack
		self.attacks = 0
		self.first_target = EntIndexToHScript(keys.target)
		self.bFirstJump = true
		self.target = self.first_target
		self.delay = self:GetAbility():GetSpecialValueFor("bounce_delay")
		local total_duration = (stacks - 1) * self:GetAbility():GetSpecialValueFor("bounce_delay")
		local max_duration = self:GetAbility():GetSpecialValueFor("max_duration")
		if total_duration > max_duration then
			self.delay = max_duration / (stacks - 1)
		end
		self.tick = 0
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_omni_slash_caster:OnIntervalThink()
	if self.bFirstJump then
		self.bFirstJump = false
		self:JumpAndSlash(self.first_target)
		return
	end
	if self.tick <= self.delay and self.delay <= (self.tick + FrameTime()) then
		self.tick = 0
		local radius = self:GetParent():HasScepter() and self:GetAbility():GetSpecialValueFor("bounce_range_scepter") or self:GetAbility():GetSpecialValueFor("bounce_range")
		local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
		if #units == 0 then
			self:Destroy()
			return
		end
		self:JumpAndSlash(units[1])
		return
	end
	self.tick = self.tick + FrameTime()
	if self.target:IsAlive() and self.target:IsRealHero() then
		local pos = GetRandomPosition2D(self.target:GetAbsOrigin(), 128)
		local direction = (self.target:GetAbsOrigin() - pos):Normalized()
		local parent = self:GetParent()
		self:GetParent():SetAbsOrigin(pos)
		self:GetParent():SetForwardVector(direction)
		self:GetParent():SetAttacking(self.target)
		self:GetParent():SetForceAttackTarget(self.target)
		Timers:CreateTimer(0.01, function()
			parent:SetForceAttackTarget(nil)
		end)
	end
end

function modifier_imba_omni_slash_caster:OnAttackLanded(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		self.attacks = self.attacks + 1
	end
end

function modifier_imba_omni_slash_caster:JumpAndSlash(target)
	local caster = self:GetParent()
	self.target = target
	if HeroItems:UnitHasItem(self:GetCaster(), "juggernaut_arcana") then
		local pfx_tgt = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx_tgt, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx_tgt, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx_tgt)
		local pfx_trail = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx_trail, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx_trail, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx_trail)
	else
		local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(pfx1, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx1)
		local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx2, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx2, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx2)
	end
	local target_pos = target:GetAbsOrigin() + (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 100
	caster:SetAbsOrigin(target_pos)
	if not self:GetParent():IsDisarmed() then
		if target:IsRealHero() or target:IsBoss() or target:IsAncient() or target:IsConsideredHero() then
			caster:PerformAttack(target, false, true, true, false, true, false, true)
		else
			target:Kill(self:GetAbility(), caster)
		end
	end
	self:DecrementStackCount()
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end

function modifier_imba_omni_slash_caster:OnDestroy()
	if IsServer() then
		self.first_target = nil
		self.bFirstJump = nil
		self.target = nil
		self.delay = nil
		self.tick = nil
		self:GetParent():SetForceAttackTarget(nil)
		if HeroItems:UnitHasItem(self:GetCaster(), "juggernaut_arcana") then
			local pfx_end = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			for i=0, 3 do
				ParticleManager:SetParticleControlEnt(pfx_end, i, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
			end
			ParticleManager:SetParticleControl(pfx_end, 5, Vector(1,1,1))
			ParticleManager:ReleaseParticleIndex(pfx_end)
		end
		local parent = self:GetParent()
		Timers:CreateTimer(0.1, function()
			parent:SetForceAttackTarget(nil)
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		end)
	end
end