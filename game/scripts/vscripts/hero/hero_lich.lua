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
	if not self:GetParent():IsAlive() then
		return
	end
	if self:GetParent():IsHero() then
		if math.random(1,100) <= self:GetAbility():GetSpecialValueFor("proc_chance") then
			Lich_Frost_Nova_Blast(self:GetCaster(), self:GetParent(), self:GetAbility(), false)
		end
	else
		if math.random(1,100) <= self:GetAbility():GetSpecialValueFor("proc_chance_creep") then
			Lich_Frost_Nova_Blast(self:GetCaster(), self:GetParent(), self:GetAbility(), false)
		end
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
	target:RemoveModifierByName("modifier_imba_frost_armor")
	target:AddNewModifier(caster, self, "modifier_imba_frost_armor", {duration = self:GetSpecialValueFor("duration")})
	target:EmitSound("Imba.Hero_Lich.Frost_Armor")
end

modifier_imba_frost_armor = class({})

function modifier_imba_frost_armor:IsDebuff()			return false end
function modifier_imba_frost_armor:IsHidden() 			return false end
function modifier_imba_frost_armor:IsPurgable() 		return true end
function modifier_imba_frost_armor:IsPurgeException() 	return true end
function modifier_imba_frost_armor:GetStatusEffectName() return "particles/status_fx/status_effect_frost_armor.vpcf" end
function modifier_imba_frost_armor:StatusEffectPriority() return 10 end
function modifier_imba_frost_armor:DestroyOnExpire() return self:GetStackCount() <= 0 end
function modifier_imba_frost_armor:GetEffectName() return "particles/hero/lich/lich_frost_armor.vpcf" end
function modifier_imba_frost_armor:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_frost_armor:ShouldUseOverheadOffset() return true end
function modifier_imba_frost_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_frost_armor:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor_bonus") end

function modifier_imba_frost_armor:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and keys.attacker:IsHero() and self:GetStackCount() == 0 and (self:GetParent():GetAbsOrigin() - keys.attacker:GetAbsOrigin()):Length2D() < self:GetAbility():GetSpecialValueFor("blast_radius") then
		local parent = self:GetParent()
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("blast_duration"))
		self:StartIntervalThink(1.0)
		self:GetParent():EmitSound("Hero_Lich.IceAge")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_age.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(pfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetAbility():GetSpecialValueFor("blast_radius"),self:GetAbility():GetSpecialValueFor("blast_radius"),self:GetAbility():GetSpecialValueFor("blast_radius")))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_frost_armor:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	self:SetStackCount(self:GetStackCount() - 1)
	parent:EmitSound("Hero_Lich.IceAge.Tick")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_age_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(pfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 2, Vector(ability:GetSpecialValueFor("blast_radius"),ability:GetSpecialValueFor("blast_radius"),ability:GetSpecialValueFor("blast_radius")))
	ParticleManager:ReleaseParticleIndex(pfx)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, ability:GetSpecialValueFor("blast_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		enemy[i]:AddNewModifier(caster, ability, "modifier_imba_frost_armor_slow", {duration = ability:GetSpecialValueFor("slow_duration")})
		enemy[i]:EmitSound("Hero_Lich.IceAge.Damage")
		ApplyDamage({victim = enemy[i], attacker = caster, damage = ability:GetSpecialValueFor("blast_damage"), damage_type = ability:GetAbilityDamageType()})
	end
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

modifier_imba_frost_armor_slow = class({})

function modifier_imba_frost_armor_slow:IsDebuff()			return true end
function modifier_imba_frost_armor_slow:IsHidden() 			return false end
function modifier_imba_frost_armor_slow:IsPurgable() 		return true end
function modifier_imba_frost_armor_slow:IsPurgeException() 	return true end
function modifier_imba_frost_armor_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_imba_frost_armor_slow:StatusEffectPriority() return 15 end
function modifier_imba_frost_armor_slow:GetEffectName() return "particles/units/heroes/hero_lich/lich_ice_age_debuff.vpcf" end
function modifier_imba_frost_armor_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_frost_armor_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_frost_armor_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_movement_speed")) end
function modifier_imba_frost_armor_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("slow_attack_speed")) end

imba_lich_sinister_gaze = class({})

LinkLuaModifier("modifier_imba_sinister_gaze_caster", "hero/hero_lich.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_sinister_gaze_target", "hero/hero_lich.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lich_sinister_gaze:IsHiddenWhenStolen() 		return false end
function imba_lich_sinister_gaze:IsRefreshable() 			return true end
function imba_lich_sinister_gaze:IsStealable() 				return true end
function imba_lich_sinister_gaze:IsNetherWardStealable()	return true end
function imba_lich_sinister_gaze:GetCastRange() return self:GetSpecialValueFor("cast_range") end

function imba_lich_sinister_gaze:OnSpellStart()
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	if self.target:TriggerStandardTargetSpell(self) then
		return
	end
	caster:EmitSound("Hero_Lich.SinisterGaze.Cast")
	caster:AddNewModifier(caster, self, "modifier_imba_sinister_gaze_caster", {})
	self.target:EmitSound("Hero_Lich.SinisterGaze.Target")
	self.target:RemoveModifierByName("modifier_imba_sinister_gaze_target")
	self.target:AddNewModifier(caster, self, "modifier_imba_sinister_gaze_target", {})
end

function imba_lich_sinister_gaze:OnChannelThink(flInterval)
	if not self.target:HasModifier("modifier_imba_sinister_gaze_target") then
		self:EndChannel(false)
	end
end

function imba_lich_sinister_gaze:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	caster:StopSound("Hero_Lich.SinisterGaze.Cast")
	caster:RemoveModifierByName("modifier_imba_sinister_gaze_caster")
	self.target:StopSound("Hero_Lich.SinisterGaze.Target")
	self.target:RemoveModifierByName("modifier_imba_sinister_gaze_target")
	if not bInterrupted then
		self.target:SetModifierStackCount("modifier_imba_frost_nova_aura", nil, self.target:GetModifierStackCount("modifier_imba_frost_nova_aura", nil) + self:GetSpecialValueFor("frost_nova_stack"))
	end
end

modifier_imba_sinister_gaze_caster = class({})

function modifier_imba_sinister_gaze_caster:IsDebuff()			return false end
function modifier_imba_sinister_gaze_caster:IsHidden() 			return true end
function modifier_imba_sinister_gaze_caster:IsPurgable() 		return false end
function modifier_imba_sinister_gaze_caster:IsPurgeException() 	return false end
function modifier_imba_sinister_gaze_caster:GetEffectName() return "particles/units/heroes/hero_lich/lich_gaze_eyes.vpcf" end
function modifier_imba_sinister_gaze_caster:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_imba_sinister_gaze_target = class({})

function modifier_imba_sinister_gaze_target:IsDebuff()			return true end
function modifier_imba_sinister_gaze_target:IsHidden() 			return false end
function modifier_imba_sinister_gaze_target:IsPurgable() 		return true end
function modifier_imba_sinister_gaze_target:IsPurgeException() 	return true end
function modifier_imba_sinister_gaze_target:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true} end

function modifier_imba_sinister_gaze_target:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_gaze.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_portrait", self:GetCaster():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_sinister_gaze_target:OnIntervalThink()
	local direction = GetDirection2D(self.caster:GetAbsOrigin(), self.parent:GetAbsOrigin())
	local distance = self.ability:GetSpecialValueFor("destination") / (1.0 / FrameTime())
	local next_pos = GetGroundPosition(self.parent:GetAbsOrigin() + direction * distance, self.parent)
	self.parent:SetForwardVector(direction)
	self.parent:SetOrigin(next_pos)
end

function modifier_imba_sinister_gaze_target:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self.parent:GetAbsOrigin(), 200, false)
		FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
		self.caster = nil
		self.parent = nil
		self.ability = nil
	end
end

function modifier_special_bonus_imba_lich_4:IsHidden() return false end
function modifier_special_bonus_imba_lich_4:DestroyOnExpire() return false end
function modifier_special_bonus_imba_lich_4:GetTexture() return "lich_sinister_gaze" end
function modifier_special_bonus_imba_lich_4:GetEffectName() return "particles/units/heroes/hero_lich/lich_gaze_eyes.vpcf" end
function modifier_special_bonus_imba_lich_4:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_special_bonus_imba_lich_4:OnCreated()
	if IsServer() then
		if self:GetAbility():IsStolen() then
			self:Destroy()
			return
		end
		self.ability = self:GetParent():FindAbilityByName("imba_lich_sinister_gaze")
		if self.ability and not self:GetParent():IsIllusion() then
			self:SetDuration(self:GetAbility():GetSpecialValueFor("interval"), true)
			self.radius = self:GetAbility():GetSpecialValueFor("radius")
			self.duration = self:GetAbility():GetSpecialValueFor("value")
			self:StartIntervalThink(0.1)
		end
	end
end

function modifier_special_bonus_imba_lich_4:OnIntervalThink()
	if self:GetRemainingTime() <= 0.1 and self:GetParent():IsAlive() and self.ability:GetLevel() > 0 then
		local enemy = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for i=1, #enemy do
			if not enemy[i]:HasModifier("modifier_imba_sinister_gaze_target") then
				enemy[i]:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_sinister_gaze_target", {duration = self.duration})
			end
		end
	end
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
	local pfx_name = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"
	if HeroItems:UnitHasItem(caster, "lich_ti8") then
		pfx_name = "particles/econ/items/lich/lich_ti8_immortal_arms/lich_ti8_chain_frost.vpcf"
	end
	local info = {
				Target = target,
				Source = caster,
				Ability = self,	
				EffectName = pfx_name,
				iMoveSpeed = speed,
				vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
				bDrawsOnMinimap = false,                          -- Optional
				bDodgeable = false,                                -- Optional
				bIsAttack = false,                                -- Optional
				bVisibleToEnemies = true,                         -- Optional
				bReplaceExisting = false,                         -- Optional
				flExpireTime = GameRules:GetGameTime() + 60,      -- Optional but recommended
				bProvidesVision = false,                           -- Optional
				ExtraData = {speed = speed, first = 1, bounces = 0}
				}
	ProjectileManager:CreateTrackingProjectile(info)
	caster:EmitSound("Hero_Lich.ChainFrost")
end

function imba_lich_chain_frost:OnProjectileThink_ExtraData(location, keys)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("vision_radius"), FrameTime(), false)
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
		target:InterruptChannel()
	end
	target:EmitSound("Hero_Lich.ChainFrostImpact.Hero")
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
	if self:GetCaster():HasTalent("special_bonus_imba_lich_3") and not target:IsMagicImmune() then
		target:AddNewModifier(self:GetCaster(), self, "modifier_lich_sinister_gaze", {duration = self:GetCaster():GetTalentValue("special_bonus_imba_lich_3")})
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
			if enemy ~= target and not string.find(enemy:GetUnitName(), "npc_dota_unit_undying_zombie") then
				next_target = enemy
				break
			end
		end
	end
	if next_target then
		local pfx_name = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"
		if HeroItems:UnitHasItem(self:GetCaster(), "lich_ti8") then
			pfx_name = "particles/econ/items/lich/lich_ti8_immortal_arms/lich_ti8_chain_frost.vpcf"
		end
		local info = {
					Target = next_target,
					Source = target,
					Ability = self,	
					EffectName = pfx_name,
					iMoveSpeed = speed,
					vSourceLoc= location,                -- Optional (HOW)
					bDrawsOnMinimap = false,                          -- Optional
					bDodgeable = false,                                -- Optional
					bIsAttack = false,                                -- Optional
					bVisibleToEnemies = true,                         -- Optional
					bReplaceExisting = false,                         -- Optional
					flExpireTime = GameRules:GetGameTime() + 60,      -- Optional but recommended
					bProvidesVision = false,                           -- Optional
					ExtraData = {speed = speed, first = 0, bounces = bounces}
					}
		Timers:CreateTimer(interval, function()
			ProjectileManager:CreateTrackingProjectile(info)
		end)
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
