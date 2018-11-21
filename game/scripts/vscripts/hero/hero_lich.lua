CreateEmptyTalents("lich")

imba_lich_frost_nova = class({})

LinkLuaModifier("modifier_imba_frost_nova_slow", "hero/hero_lich", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_frost_nova_aura", "hero/hero_lich", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_frost_nova_passvie", "hero/hero_lich", LUA_MODIFIER_MOTION_NONE)

function imba_lich_frost_nova:IsHiddenWhenStolen() 		return false end
function imba_lich_frost_nova:IsRefreshable() 			return true  end
function imba_lich_frost_nova:IsStealable() 			return true  end
function imba_lich_frost_nova:IsNetherWardStealable()	return true end
function imba_lich_frost_nova:GetIntrinsicModifierName() return "modifier_imba_frost_nova_passvie" end
function imba_lich_frost_nova:GetAOERadius() return self:GetSpecialValueFor("radius") end
 
function imba_lich_frost_nova:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	Lich_Frost_Nova_Blast(caster, target, self, true)
end

function Lich_Frost_Nova_Blast(caster, target, ability, bPrime)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_nova.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(ability:GetSpecialValueFor("radius"), ability:GetSpecialValueFor("radius"), ability:GetSpecialValueFor("radius")))
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = ability:GetSpecialValueFor("aoe_damage"),
							damage_type = ability:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = ability, --Optional.
							}
		ApplyDamage(damageTable)
		enemy:AddNewModifier(caster, ability, "modifier_imba_frost_nova_slow", {duration = ability:GetSpecialValueFor("slow_duration")})
	end
	if bPrime then
		local damageTable = {
							victim = target,
							attacker = caster,
							damage = ability:GetSpecialValueFor("target_damage"),
							damage_type = ability:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = ability, --Optional.
							}
		ApplyDamage(damageTable)
	end
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Ability.FrostNova", target)
end

modifier_imba_frost_nova_slow = class({})

function modifier_imba_frost_nova_slow:IsDebuff()			return true end
function modifier_imba_frost_nova_slow:IsHidden() 			return false end
function modifier_imba_frost_nova_slow:IsPurgable() 		return true end
function modifier_imba_frost_nova_slow:IsPurgeException() 	return true end
function modifier_imba_frost_nova_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost_lich.vpcf" end
function modifier_imba_frost_nova_slow:StatusEffectPriority() return 15 end
function modifier_imba_frost_nova_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_frost_nova_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_movement_speed")) end
function modifier_imba_frost_nova_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("slow_attack_speed")) end

modifier_imba_frost_nova_passvie = class({})

function modifier_imba_frost_nova_passvie:IsDebuff()			return false end
function modifier_imba_frost_nova_passvie:IsHidden() 			return true end
function modifier_imba_frost_nova_passvie:IsPurgable() 			return false end
function modifier_imba_frost_nova_passvie:IsPurgeException() 	return false end
function modifier_imba_frost_nova_passvie:IsAura() return true end
function modifier_imba_frost_nova_passvie:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("aura_stickyness") end
function modifier_imba_frost_nova_passvie:GetModifierAura() return "modifier_imba_frost_nova_aura" end
function modifier_imba_frost_nova_passvie:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_aoe") end
function modifier_imba_frost_nova_passvie:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_frost_nova_passvie:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_frost_nova_passvie:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_frost_nova_aura = class({})

function modifier_imba_frost_nova_aura:IsDebuff()			return true end
function modifier_imba_frost_nova_aura:IsHidden() 			return false end
function modifier_imba_frost_nova_aura:IsPurgable() 		return false end
function modifier_imba_frost_nova_aura:IsPurgeException() 	return false end
function modifier_imba_frost_nova_aura:GetEffectName() return "particles/units/heroes/hero_tusk/tusk_frozen_sigil_status.vpcf" end
function modifier_imba_frost_nova_aura:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_frost_nova_aura:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_frost_nova_aura:GetModifierMoveSpeedBonus_Percentage() return (0 - (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("slow_per_stack") + self:GetAbility():GetSpecialValueFor("base_slow"))) end

function modifier_imba_frost_nova_aura:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("stack_interval"))
	end
end

function modifier_imba_frost_nova_aura:OnIntervalThink()
	self:IncrementStackCount()
	if math.random(1,100) <= self:GetAbility():GetSpecialValueFor("proc_chance") then
		Lich_Frost_Nova_Blast(self:GetCaster(), self:GetParent(), self:GetAbility(), false)
	end
end

imba_lich_frost_armor = class({})

LinkLuaModifier("modifier_imba_frost_armor", "hero/hero_lich", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_frost_armor_slow", "hero/hero_lich", LUA_MODIFIER_MOTION_NONE)

function imba_lich_frost_armor:IsHiddenWhenStolen() 	return false end
function imba_lich_frost_armor:IsRefreshable() 			return true  end
function imba_lich_frost_armor:IsStealable() 			return true  end
function imba_lich_frost_armor:IsNetherWardStealable()	return true end

function imba_lich_frost_armor:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_imba_frost_armor", {duration = self:GetSpecialValueFor("tooltip_duration")}) 
end

modifier_imba_frost_armor = class({})

function modifier_imba_frost_armor:IsDebuff()			return false end
function modifier_imba_frost_armor:IsHidden() 			return false end
function modifier_imba_frost_armor:IsPurgable() 		return true end
function modifier_imba_frost_armor:IsPurgeException() 	return true end
function modifier_imba_frost_armor:GetStatusEffectName() return "particles/status_fx/status_effect_frost_armor.vpcf" end
function modifier_imba_frost_armor:StatusEffectPriority() return 10 end
function modifier_imba_frost_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_frost_armor:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor_bonus") end

function modifier_imba_frost_armor:OnCreated()
	if IsServer() then
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Lich.FrostArmor", self:GetParent())
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_armor.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetModifierPhysicalArmorBonus(), self:GetModifierPhysicalArmorBonus(), self:GetModifierPhysicalArmorBonus()))
		ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, true)
	end
end

function modifier_imba_frost_armor:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() or keys.attacker:IsBuilding() or keys.attacker:IsOther() then
		return
	end
	keys.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_frost_armor_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
	EmitSoundOnLocationWithCaster(keys.attacker:GetAbsOrigin(), "Hero_Lich.FrostArmorDamage", keys.attacker)
end

modifier_imba_frost_armor_slow = class({})

function modifier_imba_frost_armor_slow:IsDebuff()			return true end
function modifier_imba_frost_armor_slow:IsHidden() 			return false end
function modifier_imba_frost_armor_slow:IsPurgable() 		return true end
function modifier_imba_frost_armor_slow:IsPurgeException() 	return true end
function modifier_imba_frost_armor_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_imba_frost_armor_slow:StatusEffectPriority() return 15 end
function modifier_imba_frost_armor_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_frost_armor_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_movement_speed")) end
function modifier_imba_frost_armor_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("slow_attack_speed")) end


imba_lich_dark_ritual = class({})

function imba_lich_dark_ritual:IsHiddenWhenStolen() 	return false end
function imba_lich_dark_ritual:IsRefreshable() 			return true  end
function imba_lich_dark_ritual:IsStealable() 			return true  end
function imba_lich_dark_ritual:IsNetherWardStealable()	return false end

function imba_lich_dark_ritual:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local XP = target:GetDeathXP()
	caster:AddExperience(XP, DOTA_ModifyXP_CreepKill, false, false)
	local mana_gain = target:GetHealth()
	local current_mana = caster:GetMana()
	local max_mana = caster:GetMaxMana()
	if max_mana - current_mana >= mana_gain then
		caster:SetMana(current_mana + mana_gain)
	else
		caster:SetMana(max_mana)
		caster:Heal(mana_gain - (max_mana - current_mana), caster)
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_dark_ritual.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	target:Kill(self, caster)
	caster:EmitSound("Ability.DarkRitual")
end

imba_lich_chain_frost = class({})

LinkLuaModifier("modifier_imba_chain_frost", "hero/hero_lich", LUA_MODIFIER_MOTION_NONE)

function imba_lich_chain_frost:IsHiddenWhenStolen() 	return false end
function imba_lich_chain_frost:IsRefreshable() 			return true  end
function imba_lich_chain_frost:IsStealable() 			return true  end
function imba_lich_chain_frost:IsNetherWardStealable()	return true end

function imba_lich_chain_frost:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local speed = self:GetSpecialValueFor("projectile_speed")
	local aura = 0
	if caster:HasTalent("special_bonus_imba_lich_1") and caster:FindAbilityByName("imba_lich_frost_nova") then
		local ability = caster:FindAbilityByName("imba_lich_frost_nova")
		aura = CreateModifierThinker(caster, ability, "modifier_imba_frost_nova_passvie", {}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false):entindex()
	end

	local info = {
				Target = target,
				Source = caster,
				Ability = self,	
				EffectName = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf",
				iMoveSpeed = speed,
				vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
				bDrawsOnMinimap = false,                          -- Optional
				bDodgeable = false,                                -- Optional
				bIsAttack = false,                                -- Optional
				bVisibleToEnemies = true,                         -- Optional
				bReplaceExisting = false,                         -- Optional
				flExpireTime = GameRules:GetGameTime() + 60,      -- Optional but recommended
				bProvidesVision = false,                           -- Optional
				ExtraData = {speed = speed, first = 1, bounces = 0, aura = aura}
				}
	ProjectileManager:CreateTrackingProjectile(info)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Lich.ChainFrost", caster)
end

function imba_lich_chain_frost:OnProjectileThink_ExtraData(location, keys)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("vision_radius"), FrameTime(), false)
	if keys.aura ~= 0 then
		EntIndexToHScript(keys.aura):SetAbsOrigin(location)
	end
end

function imba_lich_chain_frost:OnProjectileHit_ExtraData(target, location, keys)
	local bounces = keys.bounces + 1
	local interval = math.max(self:GetSpecialValueFor("bounce_delay") - 0.01 * bounces, 0)
	local dmg = self:GetCaster():HasScepter() and self:GetSpecialValueFor("damage_scepter") or self:GetSpecialValueFor("damage")
	local speed_increase = self:GetCaster():HasScepter() and self:GetSpecialValueFor("speed_per_bounce_scepter") or self:GetSpecialValueFor("speed_per_bounce")
	local radius = self:GetCaster():HasScepter() and self:GetSpecialValueFor("jump_range_scepter") or self:GetSpecialValueFor("jump_range")
	local speed = keys.speed + speed_increase
	if keys.first == 1 then
		target:TriggerSpellReflect(self)
		target:TriggerSpellAbsorb(self)
		target:Interrupt()
	end
	EmitSoundOnLocationWithCaster(location, "Hero_Lich.ChainFrostImpact.Hero", target)
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_chain_frost", {duration = self:GetSpecialValueFor("slow_duration")})
	if IsNearEnemyFountain(target:GetAbsOrigin(), self:GetCaster():GetTeamNumber(), 1100) then
		speed = self:GetSpecialValueFor("speed_fountain")
	end
	local damageTable = {
						victim = target,
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
	if self:GetCaster():HasTalent("special_bonus_imba_lich_2") then
		target:AddNewModifier(self:GetCaster(), self, "modifier_paralyzed", {duration = self:GetCaster():GetTalentValue("special_bonus_imba_lich_2")})
	end
	local hero_got = false
	local next_target = nil
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= target then
			next_target = enemy
			hero_got = true
			break
		end
	end
	if not hero_got then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= target then
				next_target = enemy
				break
			end
		end
	end
	if next_target then
		local info = {
					Target = next_target,
					Source = target,
					Ability = self,	
					EffectName = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf",
					iMoveSpeed = speed,
					vSourceLoc= location,                -- Optional (HOW)
					bDrawsOnMinimap = false,                          -- Optional
					bDodgeable = false,                                -- Optional
					bIsAttack = false,                                -- Optional
					bVisibleToEnemies = true,                         -- Optional
					bReplaceExisting = false,                         -- Optional
					flExpireTime = GameRules:GetGameTime() + 60,      -- Optional but recommended
					bProvidesVision = false,                           -- Optional
					ExtraData = {speed = speed, first = 0, bounces = bounces, aura = keys.aura}
					}
		Timers:CreateTimer(interval, function()
			ProjectileManager:CreateTrackingProjectile(info)
		end)
		return true
	elseif keys.aura ~= 0 then
		EntIndexToHScript(keys.aura):ForceKill(false)
		return true
	end
end

modifier_imba_chain_frost = class({})

function modifier_imba_chain_frost:IsDebuff()			return true end
function modifier_imba_chain_frost:IsHidden() 			return false end
function modifier_imba_chain_frost:IsPurgable() 		return true end
function modifier_imba_chain_frost:IsPurgeException() 	return true end
function modifier_imba_chain_frost:GetStatusEffectName() return "particles/status_fx/status_effect_frost_lich.vpcf" end
function modifier_imba_chain_frost:StatusEffectPriority() return 15 end
function modifier_imba_chain_frost:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_chain_frost:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_movement_speed")) end
function modifier_imba_chain_frost:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("slow_attack_speed")) end
