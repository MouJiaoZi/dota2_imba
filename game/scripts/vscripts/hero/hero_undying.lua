CreateEmptyTalents("undying")

imba_undying_tombstone = class({})

LinkLuaModifier("modifier_imba_tombstone_npc", "hero/hero_undying.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_tombstone_radius", "hero/hero_undying.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_tombstone_enemy", "hero/hero_undying.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_tombstone_enemy_radius", "hero/hero_undying.lua", LUA_MODIFIER_MOTION_NONE)

function imba_undying_tombstone:IsHiddenWhenStolen() 	return false end
function imba_undying_tombstone:IsRefreshable() 		return true end
function imba_undying_tombstone:IsStealable() 			return true end
function imba_undying_tombstone:IsNetherWardStealable()	return false end
function imba_undying_tombstone:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_undying_tombstone:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local tombstone = CreateUnitByName("npc_dota_unit_tombstone1", pos, true, caster, caster, caster:GetTeamNumber())
	SetCreatureHealth(tombstone, (self:GetSpecialValueFor("hits_to_destroy") + caster:GetTalentValue("special_bonus_imba_undying_2")) * 2, true)
	tombstone:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	tombstone:AddNewModifier(caster, self, "modifier_imba_tombstone_npc", {duration = self:GetSpecialValueFor("duration")})
	tombstone:AddNewModifier(caster, self, "modifier_imba_tombstone_radius", {duration = self:GetSpecialValueFor("duration")})
	GridNav:DestroyTreesAroundPoint(tombstone:GetAbsOrigin(), 300, false)
	tombstone:EmitSound("Hero_Undying.Tombstone")
end

modifier_imba_tombstone_radius = class({})

function modifier_imba_tombstone_radius:IsDebuff()			return false end
function modifier_imba_tombstone_radius:IsHidden() 			return true end
function modifier_imba_tombstone_radius:IsPurgable() 		return false end
function modifier_imba_tombstone_radius:IsPurgeException() 	return false end
function modifier_imba_tombstone_radius:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_tombstone_radius:IsAura() return true end
function modifier_imba_tombstone_radius:GetAuraDuration() return 0.1 end
function modifier_imba_tombstone_radius:GetModifierAura() return "modifier_imba_tombstone_enemy_radius" end
function modifier_imba_tombstone_radius:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_tombstone_radius:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_imba_tombstone_radius:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_tombstone_radius:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imba_tombstone_radius:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and not keys.reincarnate then
		self:Destroy()
	end
end

modifier_imba_tombstone_npc = class({})

function modifier_imba_tombstone_npc:IsDebuff()			return false end
function modifier_imba_tombstone_npc:IsHidden() 		return true end
function modifier_imba_tombstone_npc:IsPurgable() 		return false end
function modifier_imba_tombstone_npc:IsPurgeException() return false end
function modifier_imba_tombstone_npc:CheckState() return {[MODIFIER_STATE_MAGIC_IMMUNE] = true} end
function modifier_imba_tombstone_npc:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE, MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_tombstone_npc:GetAbsoluteNoDamageMagical() return 1 end
function modifier_imba_tombstone_npc:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_imba_tombstone_npc:GetAbsoluteNoDamagePure() return 1 end

function modifier_imba_tombstone_npc:IsAura() return true end
function modifier_imba_tombstone_npc:GetAuraDuration() return 100000 end
function modifier_imba_tombstone_npc:GetModifierAura() return "modifier_imba_tombstone_enemy" end
function modifier_imba_tombstone_npc:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_tombstone_npc:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_imba_tombstone_npc:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_tombstone_npc:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imba_tombstone_npc:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and not keys.reincarnate then
		self:Destroy()
	end
end

function modifier_imba_tombstone_npc:OnAttackLanded(keys)
	if not IsServer() or keys.target ~= self:GetParent() then
		return
	end
	local damage = 2
	if not keys.attacker:IsTrueHero() and not keys.attacker:IsTower() and not keys.attacker:IsBoss() then
		damage = 1
	end
	local health = self:GetParent():GetHealth()
	if health - damage <= 0 then
		self:GetParent():Kill(self:GetAbility(), keys.attacker)
	else
		self:GetParent():SetHealth(health - damage)
	end
end

modifier_imba_tombstone_enemy_radius = class({})

function modifier_imba_tombstone_enemy_radius:IsDebuff()			return false end
function modifier_imba_tombstone_enemy_radius:IsHidden() 			return true end
function modifier_imba_tombstone_enemy_radius:IsPurgable() 			return false end
function modifier_imba_tombstone_enemy_radius:IsPurgeException() 	return false end

modifier_imba_tombstone_enemy = class({})

function modifier_imba_tombstone_enemy:IsDebuff()			return true end
function modifier_imba_tombstone_enemy:IsHidden() 			return false end
function modifier_imba_tombstone_enemy:IsPurgable() 		return false end
function modifier_imba_tombstone_enemy:IsPurgeException() 	return false end
function modifier_imba_tombstone_enemy:GetEffectName() return "particles/hero/undying/undying_tombstone_debuff.vpcf" end
function modifier_imba_tombstone_enemy:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_tombstone_enemy:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_tombstone_enemy:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP} end
function modifier_imba_tombstone_enemy:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("stack_ms") * self:GetStackCount()) end
function modifier_imba_tombstone_enemy:OnTooltip() return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("stack_damage") + self:GetCaster():GetTalentValue("special_bonus_imba_undying_3")) end

function modifier_imba_tombstone_enemy:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("stack_interval"))
	end
end

function modifier_imba_tombstone_enemy:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local dmg = (ability:GetSpecialValueFor("stack_damage") + self:GetCaster():GetTalentValue("special_bonus_imba_undying_3")) * self:GetStackCount()
	if parent:HasModifier("modifier_imba_tombstone_enemy_radius") and self:GetAuraOwner() and not self:GetAuraOwner():IsNull() and self:GetAuraOwner():IsAlive() then
		self:SetStackCount(self:GetStackCount() + 1)
		ApplyDamage({victim = parent, attacker = self:GetCaster(), damage = dmg, damage_type = ability:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
	else
		self:SetStackCount(self:GetStackCount() - 1)
		ApplyDamage({victim = parent, attacker = self:GetCaster(), damage = dmg, damage_type = ability:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
	end
	if self:GetStackCount() <= 0 then
		self:Destroy()
		return
	end
	if parent:GetHealth() <= ability:GetSpecialValueFor("health_threshold") or parent:GetHealthPercent() <= ability:GetSpecialValueFor("health_threshold_pct") then
		self:StartIntervalThink(ability:GetSpecialValueFor("low_interval"))
	else
		self:StartIntervalThink(ability:GetSpecialValueFor("stack_interval"))
	end
end

-------------------------
-- Talent: Tombstone On Death
-------------------------

function modifier_special_bonus_imba_undying_1:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end

function modifier_special_bonus_imba_undying_1:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and self:GetParent():IsTrueHero() then
		local ability = self:GetParent():FindAbilityByName("imba_undying_tombstone")
		if ability and ability:GetLevel() > 0 then
			self:GetParent():SetCursorPosition(self:GetParent():GetAbsOrigin())
			ability:OnSpellStart()
		end
	end
end
