CreateEmptyTalents("crystal_maiden")

imba_crystal_maiden_crystal_nova = class({})

LinkLuaModifier("modifier_imba_crystal_nova_slow", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_crystal_nova_thinker", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_crystal_nova_snowfield_buff", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)

function imba_crystal_maiden_crystal_nova:IsHiddenWhenStolen() 		return false end
function imba_crystal_maiden_crystal_nova:IsRefreshable() 			return true  end
function imba_crystal_maiden_crystal_nova:IsStealable() 			return true  end
function imba_crystal_maiden_crystal_nova:IsNetherWardStealable()	return true end

function imba_crystal_maiden_crystal_nova:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_crystal_maiden_crystal_nova:OnAbilityPhaseStart()
	EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "hero_Crystal.CrystalNovaCast", self:GetCaster())
	return true
end

function imba_crystal_maiden_crystal_nova:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:SetParticleControl(pfx, 1, Vector(radius * 1.3, 3, radius * 1.3))
	ParticleManager:ReleaseParticleIndex(pfx)
	EmitSoundOnLocationWithCaster(pos, "Hero_Crystal.CrystalNova", caster)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = self:GetSpecialValueFor("damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		enemy:AddNewModifier(caster, self, "modifier_imba_crystal_nova_slow", {duration = self:GetSpecialValueFor("duration")})
	end
	AddFOWViewer(caster:GetTeamNumber(), pos, radius, self:GetSpecialValueFor("vision_duration"), false)
	CreateModifierThinker(caster, self, "modifier_imba_crystal_nova_thinker", {duration = self:GetSpecialValueFor("vision_duration")}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_crystal_nova_slow = class({})

function modifier_imba_crystal_nova_slow:IsDebuff()				return true end
function modifier_imba_crystal_nova_slow:IsHidden() 			return false end
function modifier_imba_crystal_nova_slow:IsPurgable() 			return true end
function modifier_imba_crystal_nova_slow:IsPurgeException() 	return true end

function modifier_imba_crystal_nova_slow:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end

function modifier_imba_crystal_nova_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_imba_crystal_nova_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("movespeed_slow")) end
function modifier_imba_crystal_nova_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attackspeed_slow")) end

modifier_imba_crystal_nova_thinker = class({})

function modifier_imba_crystal_nova_thinker:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_crystal_nova_thinker:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("snowfield_damage") / (1.0 / self:GetAbility():GetSpecialValueFor("damage_interval"))
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = self:GetCaster(),
							damage = dmg,
							damage_type = self:GetAbility():GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
	end
end

function modifier_imba_crystal_nova_thinker:IsAura() return true end
function modifier_imba_crystal_nova_thinker:GetAuraDuration() return 0.1 end
function modifier_imba_crystal_nova_thinker:GetModifierAura() return "modifier_imba_crystal_nova_snowfield_buff" end
function modifier_imba_crystal_nova_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_crystal_nova_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_crystal_nova_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_imba_crystal_nova_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_crystal_nova_snowfield_buff = class({})

function modifier_imba_crystal_nova_snowfield_buff:IsDebuff()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return true
	else
		return false
	end
end

function modifier_imba_crystal_nova_snowfield_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_imba_crystal_nova_snowfield_buff:GetModifierMoveSpeedBonus_Percentage()
	local spd_pct = self:GetAbility():GetSpecialValueFor("movespeed_aura_change")
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return (0 - spd_pct)
	else
		return spd_pct
	end
end

function modifier_imba_crystal_nova_snowfield_buff:GetModifierIncomingDamage_Percentage()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() and self:GetCaster():HasTalent("special_bonus_imba_crystal_maiden_1") then
		return (0 - self:GetCaster():GetTalentValue("special_bonus_imba_crystal_maiden_1"))
	end
	return 0
end

imba_crystal_maiden_frostbite = class({})

LinkLuaModifier("modifier_imba_frostbite_root", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_frostbite_passive", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_frostbite_passive_cooldown", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)

function imba_crystal_maiden_frostbite:IsHiddenWhenStolen() 	return false end
function imba_crystal_maiden_frostbite:IsRefreshable() 			return true  end
function imba_crystal_maiden_frostbite:IsStealable() 			return true  end
function imba_crystal_maiden_frostbite:IsNetherWardStealable()	return true end

function imba_crystal_maiden_frostbite:GetIntrinsicModifierName() return "modifier_imba_frostbite_passive" end

function imba_crystal_maiden_frostbite:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf",
		iMoveSpeed = 4000,
		vSourceLoc= caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = false,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 2,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
	local debuff_duration = self:GetSpecialValueFor("duration")
	if target:IsCreep() and not target:IsAncient() then
		debuff_duration = self:GetSpecialValueFor("creep_duration")
	end
	target:Interrupt()
	target:AddNewModifier(caster, self, "modifier_imba_frostbite_root", {duration = debuff_duration})
end

modifier_imba_frostbite_root = class({})

function modifier_imba_frostbite_root:IsDebuff()			return true end
function modifier_imba_frostbite_root:IsHidden() 			return false end
function modifier_imba_frostbite_root:IsPurgable() 			return true end
function modifier_imba_frostbite_root:IsPurgeException() 	return true end

function modifier_imba_frostbite_root:GetEffectName() return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf" end
function modifier_imba_frostbite_root:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_frostbite_root:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("hero_Crystal.frostbite")
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
	end
end

function modifier_imba_frostbite_root:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = false, [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true}
end

function modifier_imba_frostbite_root:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("damage_per_second_tooltip") / (1.0 / self:GetAbility():GetSpecialValueFor("damage_interval"))
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

modifier_imba_frostbite_passive = class({})
modifier_imba_frostbite_passive_cooldown = class({})

function modifier_imba_frostbite_passive:IsHidden()
	if self:GetCaster():HasModifier("modifier_imba_frostbite_passive_cooldown") then
		return true
	else
		return false
	end
end

function modifier_imba_frostbite_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_imba_frostbite_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	if self:GetParent():HasModifier("modifier_imba_frostbite_passive_cooldown") or self:GetParent():IsIllusion() or keys.attacker:IsMagicImmune() or keys.attacker:IsBuilding() or keys.attacker:IsOther() or self:GetParent():PassivesDisabled() then
		return
	end
	if keys.attacker:IsHero() then
		keys.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_stunned", {duration = 0.01})
		keys.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_frostbite_root", {duration = self:GetAbility():GetSpecialValueFor("duration")})
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_frostbite_passive_cooldown", {duration = self:GetAbility():GetSpecialValueFor("hero_cooldown")})
	elseif PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("creep_chance")) then
		keys.attacker:Interrupt()
		if not keys.attacker:IsAncient() then
			keys.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_frostbite_root", {duration = self:GetAbility():GetSpecialValueFor("creep_duration")})
		else
			keys.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_frostbite_root", {duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
	end
end

function modifier_imba_frostbite_passive_cooldown:IsDebuff()			return true end
function modifier_imba_frostbite_passive_cooldown:IsHidden() 			return false end
function modifier_imba_frostbite_passive_cooldown:IsPurgable() 			return false end
function modifier_imba_frostbite_passive_cooldown:IsPurgeException() 	return false end
function modifier_imba_frostbite_passive_cooldown:RemoveOnDeath()		return false end

imba_crystal_maiden_brilliance_aura = class({})

LinkLuaModifier("modifier_imba_brilliance_aura_passive", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_brilliance_aura_effect", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)

function imba_crystal_maiden_brilliance_aura:GetIntrinsicModifierName() return "modifier_imba_brilliance_aura_passive" end

modifier_imba_brilliance_aura_passive = class({})

function modifier_imba_brilliance_aura_passive:IsHidden() return true end
function modifier_imba_brilliance_aura_passive:IsAura() return true end
function modifier_imba_brilliance_aura_passive:GetAuraDuration() return 0.1 end
function modifier_imba_brilliance_aura_passive:GetModifierAura() return "modifier_imba_brilliance_aura_effect" end
function modifier_imba_brilliance_aura_passive:GetAuraRadius() return 50000 end
function modifier_imba_brilliance_aura_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_brilliance_aura_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_brilliance_aura_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_brilliance_aura_effect = class({})

function modifier_imba_brilliance_aura_effect:IsDebuff()			return false end
function modifier_imba_brilliance_aura_effect:IsHidden() 			return false end
function modifier_imba_brilliance_aura_effect:IsPurgable() 			return false end
function modifier_imba_brilliance_aura_effect:IsPurgeException() 	return false end

function modifier_imba_brilliance_aura_effect:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE}
end

function modifier_imba_brilliance_aura_effect:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent() == self:GetCaster() and self:GetCaster():GetMana() == self:GetCaster():GetMaxMana() and not self:GetCaster():PassivesDisabled() then
		return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	else
		return 0
	end
end

function modifier_imba_brilliance_aura_effect:GetModifierBonusStats_Intellect()
	if self:GetCaster():PassivesDisabled() then
		return 0
	end
	if self:GetParent() == self:GetCaster() then
		return (2 * self:GetAbility():GetSpecialValueFor("bonus_int"))
	else
		return self:GetAbility():GetSpecialValueFor("bonus_int")
	end
end

function modifier_imba_brilliance_aura_effect:GetModifierTotalPercentageManaRegen()
	if self:GetCaster():PassivesDisabled() then
		return 0
	end
	if self:GetParent() == self:GetCaster() then
		return (2 * self:GetAbility():GetSpecialValueFor("mana_regen"))
	else
		return self:GetAbility():GetSpecialValueFor("mana_regen")
	end
end


imba_crystal_maiden_freezing_field = class({})

LinkLuaModifier("modifier_imba_freezing_field_particle", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_freezing_field_thinker", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_freezing_field_debuff", "hero/hero_crystal_maiden", LUA_MODIFIER_MOTION_NONE)

function imba_crystal_maiden_freezing_field:IsHiddenWhenStolen() 	return false end
function imba_crystal_maiden_freezing_field:IsRefreshable() 		return true  end
function imba_crystal_maiden_freezing_field:IsStealable() 			return true  end
function imba_crystal_maiden_freezing_field:IsNetherWardStealable()	return true end

function imba_crystal_maiden_freezing_field:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("radius")
	else
		return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() + self:GetCaster():GetTalentValue("special_bonus_imba_crystal_maiden_2")
	end
end

function imba_crystal_maiden_freezing_field:GetChannelTime() return self:GetSpecialValueFor("duration") end

function imba_crystal_maiden_freezing_field:GetAOERadius() return self:GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_crystal_maiden_2") end

function imba_crystal_maiden_freezing_field:GetBehavior()
	if not self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_AOE
	end
end

function imba_crystal_maiden_freezing_field:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local scepter = caster:HasScepter()
	caster:AddNewModifier(caster, self, "modifier_imba_freezing_field_particle", {duration = self:GetSpecialValueFor("duration")})
	if not scepter then
		pos = caster:GetAbsOrigin()
		self.thinker = caster:AddNewModifier(caster, self, "modifier_imba_freezing_field_thinker", {duration = self:GetSpecialValueFor("duration") + 0.1})
	else
		self.thinker = CreateModifierThinker(caster, self, "modifier_imba_freezing_field_thinker", {duration = self:GetSpecialValueFor("duration") + 0.1}, pos, caster:GetTeamNumber(), false)
	end
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local frostbite = caster:FindAbilityByName("imba_crystal_maiden_frostbite")
	if frostbite and frostbite:GetLevel() > 0 then
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, frostbite, "modifier_imba_frostbite_root", {duration = self:GetSpecialValueFor("frostbite_duration")})
			enemy:Interrupt()
		end
	end
end

modifier_imba_freezing_field_particle = class({})
function modifier_imba_freezing_field_particle:IsDebuff()			return false end
function modifier_imba_freezing_field_particle:IsHidden() 			return true end
function modifier_imba_freezing_field_particle:IsPurgable() 		return false end
function modifier_imba_freezing_field_particle:IsPurgeException() 	return false end
function modifier_imba_freezing_field_particle:GetEffectName()		return "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_caster.vpcf" end
function modifier_imba_freezing_field_particle:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_imba_freezing_field_thinker = class({})

function modifier_imba_freezing_field_thinker:IsThinker() 			return true end -- use this to know it's a modifier or an unit thinker
function modifier_imba_freezing_field_thinker:IsDebuff()			return false end
function modifier_imba_freezing_field_thinker:IsHidden() 			return true end
function modifier_imba_freezing_field_thinker:IsPurgable() 			return false end
function modifier_imba_freezing_field_thinker:IsPurgeException() 	return false end
function modifier_imba_freezing_field_thinker:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_freezing_field_thinker:OnCreated()
	if IsServer() then
		if RollPercentage(80) then
			self:GetParent():EmitSound("hero_Crystal.freezingField.wind")
		else
			self:GetParent():EmitSound("Imba.CrystalMaidenLetItGo0"..RandomInt(1, 3))
		end
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("explosion_interval"))
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_crystal_maiden_2"), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_freezing_field_thinker:OnIntervalThink()
	if not self:GetAbility():IsChanneling() then
		self:StartIntervalThink(-1)
		return
	end
	local center_point = self:GetParent():GetAbsOrigin()
	local max_distance = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_crystal_maiden_2")
	local point = GetGroundPosition(GetRandomPosition2D(center_point, max_distance), self:GetCaster())
	local sound = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_dummy_thinker", {duration = 0.1}, point, self:GetCaster():GetTeamNumber(), false)
	sound:EmitSound("hero_Crystal.freezingField.explosion")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, point)
	ParticleManager:ReleaseParticleIndex(pfx)
	local dmg = self:GetAbility():GetSpecialValueFor("damage")
	if self:GetCaster():HasScepter() then
		dmg = self:GetAbility():GetSpecialValueFor("damage_scepter")
	end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, self:GetAbility():GetSpecialValueFor("explosion_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = self:GetCaster(),
							damage = dmg,
							damage_type = self:GetAbility():GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
	end
end

function modifier_imba_freezing_field_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn("hero_Crystal.freezingField.wind", self:GetParent())
	end
end

function modifier_imba_freezing_field_thinker:IsAura() return true end
function modifier_imba_freezing_field_thinker:GetAuraDuration() return 1.0 end
function modifier_imba_freezing_field_thinker:GetModifierAura() return "modifier_imba_freezing_field_debuff" end
function modifier_imba_freezing_field_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_freezing_field_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_freezing_field_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_freezing_field_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_freezing_field_debuff = class({})

function modifier_imba_freezing_field_debuff:IsDebuff()				return true end
function modifier_imba_freezing_field_debuff:IsHidden() 			return false end
function modifier_imba_freezing_field_debuff:IsPurgable() 			return false end
function modifier_imba_freezing_field_debuff:IsPurgeException() 	return false end
function modifier_imba_freezing_field_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_frost_lich.vpcf" end
function modifier_imba_freezing_field_debuff:StatusEffectPriority() return 15 end
function modifier_imba_freezing_field_debuff:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end


function modifier_imba_freezing_field_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_imba_freezing_field_debuff:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():HasScepter() then
		return (0 - self:GetAbility():GetSpecialValueFor("attack_slow_scepter"))
	else
		return (0 - self:GetAbility():GetSpecialValueFor("attack_slow"))
	end
end

function modifier_imba_freezing_field_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetCaster():HasScepter() then
		return (0 - self:GetAbility():GetSpecialValueFor("movespeed_slow_scepter"))
	else
		return (0 - self:GetAbility():GetSpecialValueFor("movespeed_slow"))
	end
end