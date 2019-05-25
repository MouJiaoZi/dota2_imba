CreateEmptyTalents("axe")

imba_axe_berserkers_call = class({})
LinkLuaModifier("modifier_axe_berserkers_call_as", "hero/hero_axe", LUA_MODIFIER_MOTION_NONE)
-- modifier_axe_berserkers_call

function imba_axe_berserkers_call:IsHiddenWhenStolen() 		return false end
function imba_axe_berserkers_call:IsRefreshable() 			return true end
function imba_axe_berserkers_call:IsStealable() 			return true end
function imba_axe_berserkers_call:IsNetherWardStealable() 	return true end

function imba_axe_berserkers_call:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_axe_berserkers_call:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Axe.BerserkersCall.Start")
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	return true
end

function imba_axe_berserkers_call:OnAbilityPhaseInterrupted() self:GetCaster():FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1) end

function imba_axe_berserkers_call:OnSpellStart()
	self:GetCaster():EmitSound("Hero_Axe.Berserkers_Call")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_berserkers_call_armor", {duration = self:GetSpecialValueFor("duration")})
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
									self:GetCaster():GetAbsOrigin(),
									nil,
									self:GetSpecialValueFor("radius"),
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
									FIND_ANY_ORDER,
									false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_axe_berserkers_call", {duration = self:GetSpecialValueFor("duration")})
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_axe_berserkers_call_as", {duration = self:GetSpecialValueFor("duration")})
	end
	local pfx = ParticleManager:CreateParticle("particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_mouth")))
	ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("radius"), 0, 0))
end

modifier_axe_berserkers_call_as = class({})

function modifier_axe_berserkers_call_as:IsDebuff()				return true end
function modifier_axe_berserkers_call_as:IsHidden() 			return true end
function modifier_axe_berserkers_call_as:IsPurgable() 			return false end
function modifier_axe_berserkers_call_as:IsPurgeException() 	return false end

function modifier_axe_berserkers_call_as:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,}
	return funcs
end

function modifier_axe_berserkers_call_as:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end

imba_axe_battle_hunger = class({})

LinkLuaModifier("modifier_imba_axe_battle_hunger_caster", "hero/hero_axe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_axe_battle_hunger_enemy", "hero/hero_axe", LUA_MODIFIER_MOTION_NONE)

function imba_axe_battle_hunger:IsHiddenWhenStolen() 		return false end
function imba_axe_battle_hunger:IsRefreshable() 			return true end
function imba_axe_battle_hunger:IsStealable() 				return true end
function imba_axe_battle_hunger:IsNetherWardStealable() 	return true end

function imba_axe_battle_hunger:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	return true
end

function imba_axe_battle_hunger:OnAbilityPhaseInterrupted() self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_2) end

function imba_axe_battle_hunger:GetIntrinsicModifierName() return "modifier_imba_axe_battle_hunger_caster" end

function imba_axe_battle_hunger:OnSpellStart()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_imba_axe_battle_hunger_enemy", {})
	EmitSoundOnLocationWithCaster(self:GetCursorTarget():GetAbsOrigin(), "Hero_Axe.Battle_Hunger", self:GetCaster())
end

modifier_imba_axe_battle_hunger_caster =class({})

function modifier_imba_axe_battle_hunger_caster:IsDebuff()				return false end
function modifier_imba_axe_battle_hunger_caster:IsPurgable() 			return false end
function modifier_imba_axe_battle_hunger_caster:IsPurgeException() 		return false end
function modifier_imba_axe_battle_hunger_caster:IsHidden()
	if self:GetStackCount() > 0 then
		return false
	end
	return true
end

function modifier_imba_axe_battle_hunger_caster:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_imba_axe_battle_hunger_caster:GetModifierMoveSpeedBonus_Percentage() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("speed_bonus")) end

modifier_imba_axe_battle_hunger_enemy = class({})

function modifier_imba_axe_battle_hunger_enemy:IsDebuff()				return true end
function modifier_imba_axe_battle_hunger_enemy:IsPurgable() 			return true end
function modifier_imba_axe_battle_hunger_enemy:IsPurgeException() 		return true end
function modifier_imba_axe_battle_hunger_enemy:IsHidden()				return false end

function modifier_imba_axe_battle_hunger_enemy:GetEffectName() return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf" end
function modifier_imba_axe_battle_hunger_enemy:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_axe_battle_hunger_enemy:ShouldUseOverheadOffset() return true end

function modifier_imba_axe_battle_hunger_enemy:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_EVENT_ON_DEATH,}
end

function modifier_imba_axe_battle_hunger_enemy:GetModifierMoveSpeedBonus_Percentage() return (0-self:GetAbility():GetSpecialValueFor("speed_bonus")) end

function modifier_imba_axe_battle_hunger_enemy:OnDeath(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.unit:IsIllusion() then
		return
	end
	self:Destroy()
end

function modifier_imba_axe_battle_hunger_enemy:OnCreated()
	if not IsServer() then
		return 
	end
	if self:GetCaster():HasModifier("modifier_imba_axe_battle_hunger_caster") then
		self:GetCaster():FindModifierByName("modifier_imba_axe_battle_hunger_caster"):IncrementStackCount()
	end
	self:StartIntervalThink(1.0)
end

function modifier_imba_axe_battle_hunger_enemy:OnIntervalThink()
	if IsNearEnemyFountain(self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), 1100) then
		self:Destroy()
	end
	local dmg = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("extra_damage") / 100)
	local damageTable = {
							victim = self:GetParent(),
							attacker = self:GetCaster(),
							damage = dmg,
							damage_type = self:GetAbility():GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
							ability = self:GetAbility(), --Optional.
							}
	ApplyDamage(damageTable)
end

function modifier_imba_axe_battle_hunger_enemy:OnDestroy()
	if not IsServer() then
		return 
	end
	if self:GetCaster():HasModifier("modifier_imba_axe_battle_hunger_caster") then
		self:GetCaster():FindModifierByName("modifier_imba_axe_battle_hunger_caster"):DecrementStackCount()
	end
end

imba_axe_counter_helix = class({})

LinkLuaModifier("modifier_imba_axe_counter_helix", "hero/hero_axe", LUA_MODIFIER_MOTION_NONE)

function imba_axe_counter_helix:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_axe_counter_helix:GetIntrinsicModifierName() return "modifier_imba_axe_counter_helix" end

modifier_imba_axe_counter_helix = class({})

function modifier_imba_axe_counter_helix:IsDebuff()				return false end
function modifier_imba_axe_counter_helix:IsPurgable() 			return false end
function modifier_imba_axe_counter_helix:IsPurgeException() 	return false end
function modifier_imba_axe_counter_helix:IsHidden()				return true end

function modifier_imba_axe_counter_helix:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,}
end

function modifier_imba_axe_counter_helix:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():PassivesDisabled() or not self:GetAbility():IsCooldownReady() or not self:GetParent():IsAlive() then
		return
	end
	if keys.target == self:GetParent() or keys.attacker == self:GetParent() then
		if (keys.attacker == self:GetParent() and not self:GetParent():HasTalent("special_bonus_imba_axe_1") and not keys.target:IsUnit()) then
			return
		end
		if not self:GetAbility():IsCooldownReady() or not self:GetParent():IsAlive() or self:GetParent():IsHexed() or not PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("proc_chance")) then
			return
		end
		local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_counterhelix.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:ReleaseParticleIndex(pfx1)
		ParticleManager:ReleaseParticleIndex(pfx2)
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3)
		self:GetParent():EmitSound("Hero_Axe.CounterHelix_Blood_Chaser")
		if not self:GetParent():IsIllusion() then
			dmg = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetParent():GetStrength() * (self:GetAbility():GetSpecialValueFor("str_as_damage") / 100)
			local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			for _,enemy in pairs(enemies) do
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
		self:GetAbility():UseResources(true, true, true)
	end
end

imba_axe_culling_blade = class({})

LinkLuaModifier("modifier_imba_axe_culling_blade_sprint", "hero/hero_axe", LUA_MODIFIER_MOTION_NONE)

function imba_axe_culling_blade:IsHiddenWhenStolen() 		return false end
function imba_axe_culling_blade:IsRefreshable() 			return true end
function imba_axe_culling_blade:IsStealable() 				return true end
function imba_axe_culling_blade:IsNetherWardStealable() 	return true end

function imba_axe_culling_blade:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
	return true
end

function imba_axe_culling_blade:OnAbilityPhaseInterrupted() self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_4) end

function imba_axe_culling_blade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local kill_threshold = self:GetSpecialValueFor("kill_threshold") + self:GetSpecialValueFor("caster_health_percent") / 100 * caster:GetMaxHealth()
	local buff_duration = self:GetSpecialValueFor("speed_duration")
	if caster:HasScepter() then
		kill_threshold = self:GetSpecialValueFor("kill_threshold") + self:GetSpecialValueFor("caster_health_percent_scepter") / 100 * caster:GetMaxHealth()
		buff_duration = self:GetSpecialValueFor("speed_duration_scepter")
	end
	if target:GetHealth() <= kill_threshold then
		TrueKill(caster, target, self)
		target:EmitSound("Hero_Axe.Culling_Blade_Success")
		local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 3, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlOrientation(culling_kill_particle, 4, caster:GetForwardVector(), Vector(0,0,0), caster:GetUpVector())
		ParticleManager:SetParticleControl(culling_kill_particle, 8, Vector(1,0,0))
		ParticleManager:ReleaseParticleIndex(culling_kill_particle)
		local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("speed_aoe"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, ally in pairs(allies) do
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf", PATTACH_POINT_FOLLOW, ally)
			ParticleManager:SetParticleControlEnt(pfx, 1, ally, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 0, ally, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx)
			ally:AddNewModifier(caster, self, "modifier_imba_axe_culling_blade_sprint", {duration = buff_duration})
		end
		if target:IsRealHero() then
			self:EndCooldown()
		end
	else
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(pfx)
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Axe.Culling_Blade_Fail", caster)
		local damageTable = {
							victim = target,
							attacker = self:GetCaster(),
							damage = self:GetSpecialValueFor("damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
	end
end

modifier_imba_axe_culling_blade_sprint = class({})

function modifier_imba_axe_culling_blade_sprint:IsDebuff()				return false end
function modifier_imba_axe_culling_blade_sprint:IsPurgable() 			return true end
function modifier_imba_axe_culling_blade_sprint:IsPurgeException() 		return true end
function modifier_imba_axe_culling_blade_sprint:IsHidden()				return false end

function modifier_imba_axe_culling_blade_sprint:GetEffectName()	return "particles/units/heroes/hero_axe/axe_cullingblade_sprint.vpcf" end

function modifier_imba_axe_culling_blade_sprint:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_imba_axe_culling_blade_sprint:GetModifierAttackSpeedBonus_Constant()	return self:GetAbility():GetSpecialValueFor("as_bonus") end
function modifier_imba_axe_culling_blade_sprint:GetModifierMoveSpeedBonus_Percentage()	return self:GetAbility():GetSpecialValueFor("speed_bonus") end