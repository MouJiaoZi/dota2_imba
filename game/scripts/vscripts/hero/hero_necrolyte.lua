

CreateEmptyTalents("necrolyte")


imba_necrolyte_death_pulse = class({})

LinkLuaModifier("modifier_death_pulse_thinker", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)

function imba_necrolyte_death_pulse:IsHiddenWhenStolen() 	return false end
function imba_necrolyte_death_pulse:IsRefreshable() 		return true end
function imba_necrolyte_death_pulse:IsStealable() 			return true end
function imba_necrolyte_death_pulse:IsNetherWardStealable()	return false end
function imba_necrolyte_death_pulse:GetCastRange() return self:GetSpecialValueFor("area_of_effect") - self:GetCaster():GetCastRangeBonus() end
function imba_necrolyte_death_pulse:GetIntrinsicModifierName() return "modifier_death_pulse_thinker" end
function imba_necrolyte_death_pulse:GetManaCost(i) return self:GetCaster():GetModifierStackCount("modifier_death_pulse_thinker", self:GetCaster()) == 1 and self:GetSpecialValueFor("toggle_mana_cost") or self:GetSpecialValueFor("cast_mana") end

function imba_necrolyte_death_pulse:OnToggle()
	local buff = self:GetCaster():FindModifierByName("modifier_death_pulse_thinker")
	if self:GetToggleState() then
		buff:SetStackCount(1)
		buff:OnIntervalThink(true)
		buff:StartIntervalThink(1.0)
		self:StartCooldown(self:GetSpecialValueFor("toggle_cooldown"))
	else
		buff:SetStackCount(0)
		buff:StartIntervalThink(-1)
		self:StartCooldown(self:GetSpecialValueFor("cooldown"))
	end
end

function imba_necrolyte_death_pulse:CreateHealProjectile(caster, victim, heal_number, bAlly)
	local pfxname = bAlly and "particles/units/heroes/hero_necrolyte/necrolyte_pulse_friend.vpcf" or "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf"
	local info = 
	{
		Target = caster,
		Source = victim,
		Ability = self,	
		EffectName = pfxname,
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		vSourceLoc = victim:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = false,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		ExtraData = {heal = heal_number}
	}
	projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function imba_necrolyte_death_pulse:OnProjectileHit_ExtraData(target, location, keys)
	self:GetCaster():Heal(keys.heal, self)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, keys.heal, nil)
	return true
end



modifier_death_pulse_thinker = class({})

function modifier_death_pulse_thinker:IsDebuff()			return false end
function modifier_death_pulse_thinker:IsHidden() 			return true end
function modifier_death_pulse_thinker:IsPurgable() 			return false end
function modifier_death_pulse_thinker:IsPurgeException() 	return false end

function modifier_death_pulse_thinker:OnIntervalThink(bFirst)
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		if caster:GetMana() < ability:GetManaCost(ability:GetLevel()-1) then
			ability:ToggleAbility()
			return
		end
		caster:SpendMana(ability:GetManaCost(ability:GetLevel()-1), ability)
		caster:EmitSound("Hero_Necrolyte.DeathPulse")
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("area_of_effect"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("area_of_effect"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local pct = (bFirst and ability:GetSpecialValueFor("base_heal_pct") or ability:GetSpecialValueFor("toggle_damage_pct")) / 100
		for _, enemy in pairs(enemies) do
			local dmg = bFirst and ability:GetSpecialValueFor("base_damage") or ability:GetSpecialValueFor("toggle_damage")
			dmg = dmg + enemy:GetMaxHealth() * pct
			local damageTable = {
								victim = enemy,
								attacker = caster,
								damage = dmg,
								damage_type = ability:GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = ability, --Optional.
								}
			ApplyDamage(damageTable)
			local caster_heal = caster:GetMaxHealth() * ((enemy:IsHero() and ability:GetSpecialValueFor("self_heal_hero_pct") or ability:GetSpecialValueFor("self_heal_creep_pct")) / 100)
			ability:CreateHealProjectile(caster, enemy, caster_heal, false)
		end
		for _, ally in pairs(allies) do
			local heal = bFirst and ability:GetSpecialValueFor("base_heal") or ability:GetSpecialValueFor("toggle_heal")
			heal = heal + ally:GetMaxHealth() * pct
			ally:Heal(heal, self:GetAbility())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, heal, nil)
			local caster_heal = caster:GetMaxHealth() * ((ally:IsHero() and ability:GetSpecialValueFor("self_heal_hero_pct") or ability:GetSpecialValueFor("self_heal_creep_pct")) / 100)
			ability:CreateHealProjectile(caster, ally, caster_heal, true)
		end
	end
end


imba_necrolyte_heartstopper_aura = class({})

LinkLuaModifier("modifier_imba_heartstopper_passive", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_heartstopper_aura", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)

function imba_necrolyte_heartstopper_aura:GetCastRange() return self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus() end
function imba_necrolyte_heartstopper_aura:GetIntrinsicModifierName() return "modifier_imba_heartstopper_passive" end

modifier_imba_heartstopper_passive = class({})

function modifier_imba_heartstopper_passive:IsDebuff()			return false end
function modifier_imba_heartstopper_passive:IsHidden() 			return true end
function modifier_imba_heartstopper_passive:IsPurgable() 		return false end
function modifier_imba_heartstopper_passive:IsPurgeException() 	return false end
function modifier_imba_heartstopper_passive:IsAura()
	if self:GetCaster():PassivesDisabled() or self:GetCaster():IsIllusion() then
		return false
	end
	return true
end
function modifier_imba_heartstopper_passive:GetAuraDuration() return 0.5 end
function modifier_imba_heartstopper_passive:GetModifierAura() return "modifier_imba_heartstopper_aura" end
function modifier_imba_heartstopper_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_heartstopper_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_heartstopper_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_imba_heartstopper_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_heartstopper_aura = class({})

function modifier_imba_heartstopper_aura:IsHidden() 		return false end
function modifier_imba_heartstopper_aura:IsPurgable() 		return false end
function modifier_imba_heartstopper_aura:IsPurgeException() return false end
function modifier_imba_heartstopper_aura:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_heartstopper_aura:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_imba_heartstopper_aura:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_heartstopper_aura:OnIntervalThink()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		local damageTable = {
							victim = self:GetParent(),
							attacker = self:GetCaster(),
							damage = self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("aura_damage") / 100),
							damage_type = DAMAGE_TYPE_PURE,
							damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
	end
	self:SetStackCount(math.min(self:GetStackCount() + 1, self:GetAbility():GetSpecialValueFor("max_stacks")))
end

function modifier_imba_heartstopper_aura:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end

function modifier_imba_heartstopper_aura:GetModifierMagicalResistanceBonus()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stacks_tooltip"))
	else
		return 0
	end
end

function modifier_imba_heartstopper_aura:GetIMBAModifierIncomingHealAmp_Percentage()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stacks_heal_pct")
	else
		return 0
	end
end

imba_necrolyte_sadist = class({})

LinkLuaModifier("modifier_imba_sadist_stack", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_sadist_effect", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)

function imba_necrolyte_sadist:GetIntrinsicModifierName() return "modifier_imba_sadist_stack" end

modifier_imba_sadist_stack = class({})

function modifier_imba_sadist_stack:IsDebuff()			return false end
function modifier_imba_sadist_stack:IsPurgable() 		return false end
function modifier_imba_sadist_stack:IsPurgeException() 	return false end
function modifier_imba_sadist_stack:IsHidden()
	if self:GetStackCount() == 0 then
		return true
	else
		return false
	end
end

function modifier_imba_sadist_stack:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_sadist_stack:OnIntervalThink()
	local buffs = self:GetParent():FindAllModifiersByName("modifier_imba_sadist_effect")
	self:SetStackCount(#buffs)
	if self:GetStackCount() == 0 and self:GetParent() ~= self:GetCaster() then
		self:Destroy()
	end
end

function modifier_imba_sadist_stack:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_sadist_stack:OnDeath(keys)
	if not IsServer() then
		return
	end
	if self:GetParent() ~= self:GetCaster() or self:GetCaster():PassivesDisabled() or keys.attacker ~= self:GetCaster() then
		return
	end
	local stack = keys.unit:IsRealHero() and self:GetAbility():GetSpecialValueFor("hero_multiplier") or 1
	for i=1,stack do
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_sadist_effect", {duration = self:GetAbility():GetSpecialValueFor("regen_duration")})
	end
end

function modifier_imba_sadist_stack:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent() ~= self:GetCaster() or self:GetCaster():PassivesDisabled() or keys.attacker ~= self:GetCaster() or not keys.target:IsHero() then
		return
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_sadist_effect", {duration = self:GetAbility():GetSpecialValueFor("regen_duration")})
end

modifier_imba_sadist_effect = class({})

function modifier_imba_sadist_effect:IsDebuff()			return false end
function modifier_imba_sadist_effect:IsPurgable() 		return false end
function modifier_imba_sadist_effect:IsPurgeException() return false end
function modifier_imba_sadist_effect:IsHidden()			return true end
function modifier_imba_sadist_effect:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_sadist_effect:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_imba_sadist_effect:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_imba_sadist_effect:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("health_regen") end

imba_necrolyte_reapers_scythe = class({})

LinkLuaModifier("modifier_imba_reapers_scythe", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reapers_scythe_stundummy", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reapers_scythe_permanent", "hero/hero_necrolyte", LUA_MODIFIER_MOTION_NONE)

function imba_necrolyte_reapers_scythe:IsHiddenWhenStolen() 	return false end
function imba_necrolyte_reapers_scythe:IsRefreshable() 			return true end
function imba_necrolyte_reapers_scythe:IsStealable() 			return true end
function imba_necrolyte_reapers_scythe:IsNetherWardStealable()	return true end

function imba_necrolyte_reapers_scythe:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:AddNewModifier(caster, self, "modifier_imba_reapers_scythe_stundummy", {duration = self:GetSpecialValueFor("stun_duration") + FrameTime() * 3})
	target:AddNewModifier(caster, self, "modifier_imba_reapers_scythe", {duration = self:GetSpecialValueFor("stun_duration")})
	caster:EmitSound("Hero_Necrolyte.ReapersScythe.Cast")
end

modifier_imba_reapers_scythe = class({})

function modifier_imba_reapers_scythe:IsDebuff()			return true end
function modifier_imba_reapers_scythe:IsPurgable() 			return false end
function modifier_imba_reapers_scythe:IsPurgeException() 	return false end
function modifier_imba_reapers_scythe:IsHidden()			return false end
function modifier_imba_reapers_scythe:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_reapers_scythe:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_reapers_scythe:RemoveOnDeath() return false end

function modifier_imba_reapers_scythe:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Necrolyte.ReapersScythe.Target")
		local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx1, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx1, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx1)
		local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx2, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx2, false, false, 16, false, false)
		local pfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx3, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx3)

	end
end


function modifier_imba_reapers_scythe:OnDestroy()
	if not IsServer() then
		return
	end
	local dmg = self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("damage") / 100)
	dmg = dmg * (1 + ((self:GetParent():GetMaxHealth() - self:GetParent():GetHealth()) / self:GetParent():GetMaxHealth()) * 3)
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)	-- Force the killer is nec and permanent debuff ---- vscripts/imba.lua
end

modifier_imba_reapers_scythe_permanent = class({})

function modifier_imba_reapers_scythe_permanent:IsDebuff()			return true end --added by vscripts/events.lua // also scepter effect
function modifier_imba_reapers_scythe_permanent:IsPurgable() 		return false end
function modifier_imba_reapers_scythe_permanent:IsPurgeException() 	return false end
function modifier_imba_reapers_scythe_permanent:IsHidden()			return false end
function modifier_imba_reapers_scythe_permanent:RemoveOnDeath()		return false end
function modifier_imba_reapers_scythe_permanent:IsPermanent()		return true end
function modifier_imba_reapers_scythe_permanent:OnRefresh()
	if self:GetStackCount() > 0 then
		self:OnCreated()
	end
end
function modifier_imba_reapers_scythe_permanent:OnCreated() self:SetStackCount(self:GetStackCount() + 1) end
function modifier_imba_reapers_scythe_permanent:DeclareFunctions() return {MODIFIER_PROPERTY_RESPAWNTIME_STACKING} end
function modifier_imba_reapers_scythe_permanent:GetModifierStackingRespawnTime() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("respawn_stack")) end

modifier_imba_reapers_scythe_stundummy = class({})

function modifier_imba_reapers_scythe_stundummy:IsDebuff()			return true end
function modifier_imba_reapers_scythe_stundummy:IsPurgable() 		return false end
function modifier_imba_reapers_scythe_stundummy:IsPurgeException() 	return false end
function modifier_imba_reapers_scythe_stundummy:IsHidden()			return true end
function modifier_imba_reapers_scythe_stundummy:RemoveOnDeath() 	return false end
function modifier_imba_reapers_scythe_stundummy:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_reapers_scythe_stundummy:DeclareFunctions() return {MODIFIER_PROPERTY_RESPAWNTIME_STACKING} end
function modifier_imba_reapers_scythe_stundummy:GetModifierStackingRespawnTime() return self:GetAbility():GetSpecialValueFor("respawn_base") end