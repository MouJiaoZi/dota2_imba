CreateEmptyTalents("enigma")

imba_enigma_malefice = class({})

LinkLuaModifier("modifier_imba_enigma_malefice", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)

function imba_enigma_malefice:IsHiddenWhenStolen() 		return false end
function imba_enigma_malefice:IsRefreshable() 			return true  end
function imba_enigma_malefice:IsStealable() 			return true  end
function imba_enigma_malefice:IsNetherWardStealable() 	return true end

function imba_enigma_malefice:GetAOERadius() return self:GetSpecialValueFor("glitch_radius") end

function imba_enigma_malefice:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:AddNewModifier(caster, self, "modifier_imba_enigma_malefice", {duration = self:GetSpecialValueFor("total_duration") + caster:GetTalentValue("special_bonus_imba_enigma_1")})
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Enigma.Malefice", target)
end

modifier_imba_enigma_malefice = class({})

function modifier_imba_enigma_malefice:IsDebuff()			return true end
function modifier_imba_enigma_malefice:IsHidden() 			return false end
function modifier_imba_enigma_malefice:IsPurgable() 		return true end
function modifier_imba_enigma_malefice:IsPurgeException() 	return true end
function modifier_imba_enigma_malefice:GetStatusEffectName() return "particles/status_fx/status_effect_enigma_malefice.vpcf" end
function modifier_imba_enigma_malefice:StatusEffectPriority() return 15 end
function modifier_imba_enigma_malefice:GetEffectName() return "particles/units/heroes/hero_enigma/enigma_malefice.vpcf" end
function modifier_imba_enigma_malefice:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_enigma_malefice:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
		self:OnIntervalThink()
	end
end

function modifier_imba_enigma_malefice:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("glitch_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local all = Entities:FindAllByNameWithin("npc_dota_thinker", self:GetParent():GetAbsOrigin(), 5000)
	local distance = 5000
	local pulse = nil
	for i=1, #all do
		if all[i]:FindModifierByNameAndCaster("modifier_imba_enigma_midnight_pulse_thinker", self:GetCaster()) and (self:GetParent():GetAbsOrigin() - all[i]:GetAbsOrigin()):Length2D() < distance then
			pulse = all[i]
			distance = (self:GetParent():GetAbsOrigin() - all[i]:GetAbsOrigin()):Length2D()
		end
	end
	local pull_delay = self:GetAbility():GetSpecialValueFor("pull_delay")
	local particle_start = "particles/hero/enigma/malefice_targetstart.vpcf"
	local particle_travel = "particles/hero/enigma/malefice_travel.vpcf"
	local particle_end = "particles/hero/enigma/malefice_targetend.vpcf"
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
		local damageTable = {
							victim = enemy,
							attacker = self:GetCaster(),
							damage = self:GetAbility():GetSpecialValueFor("tick_damage"),
							damage_type = self:GetAbility():GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
		enemy:EmitSound("Hero_Enigma.MaleficeTick")

		local target_pos
		local black_hole = self:GetCaster():FindAbilityByName("imba_enigma_black_hole")
		if black_hole and black_hole:IsChanneling() then
			target_pos = black_hole.pos
		elseif pulse then
			target_pos = pulse:GetAbsOrigin()
		else
			target_pos = self:GetCaster():GetAbsOrigin()
		end
		local direction = (target_pos - enemy:GetAbsOrigin()):Normalized()
		direction.z = 0
		target_pos = enemy:GetAbsOrigin() + direction * self:GetAbility():GetSpecialValueFor("glitch_pull")
		
		-- Draw startpoint particle
		local start_pfx = ParticleManager:CreateParticle(particle_start, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(start_pfx, 0, enemy:GetAbsOrigin())
		ParticleManager:SetParticleControl(start_pfx, 2, Vector(pull_delay, 0, 0))
		Timers:CreateTimer(pull_delay, function()
			ParticleManager:DestroyParticle(start_pfx, false)
			ParticleManager:ReleaseParticleIndex(start_pfx)
		end)

		-- Draw traveling particle
		local travel_pfx = ParticleManager:CreateParticle(particle_travel, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(travel_pfx, 0, enemy:GetAbsOrigin())
		ParticleManager:SetParticleControl(travel_pfx, 2, Vector(pull_delay, 0, 0))
		ParticleManager:SetParticleControl(travel_pfx, 1, target_pos)
		ParticleManager:ReleaseParticleIndex(travel_pfx)
		Timers:CreateTimer(pull_delay, function()
			ParticleManager:DestroyParticle(travel_pfx, false)
			ParticleManager:ReleaseParticleIndex(travel_pfx)
		end)

		-- Draw endpoint particle
		local end_pfx = ParticleManager:CreateParticle(particle_end, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(end_pfx, 1, target_pos)
		ParticleManager:SetParticleControl(end_pfx, 2, Vector(pull_delay, 0, 0))
		ParticleManager:ReleaseParticleIndex(end_pfx)
		Timers:CreateTimer(pull_delay, function()
			ParticleManager:DestroyParticle(end_pfx, false)
			ParticleManager:ReleaseParticleIndex(end_pfx)
			if not enemy:HasModifier("modifier_batrider_flaming_lasso") then
				FindClearSpaceForUnit(enemy, target_pos, true)
			end
		end)
	end
end

imba_enigma_demonic_conversion = class({})

LinkLuaModifier("modifier_imba_enigma_demonic_conversion_attack_count", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_enigma_demonic_conversion_buff", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)

function imba_enigma_demonic_conversion:IsHiddenWhenStolen() 	return false end
function imba_enigma_demonic_conversion:IsRefreshable() 		return true  end
function imba_enigma_demonic_conversion:IsStealable() 			return true  end
function imba_enigma_demonic_conversion:IsNetherWardStealable() return false end

function imba_enigma_demonic_conversion:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Enigma.Demonic_Conversion", target)
	for i=1,self:GetSpecialValueFor("eidolon_count") do
		local unit = CreateUnitByName("npc_imba_enigma_eidolon_"..self:GetLevel(), target:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
		unit:SetControllableByPlayer(caster:GetPlayerID(), false)
		unit:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
		unit:AddNewModifier(caster, self, "modifier_imba_enigma_demonic_conversion_attack_count", {duration = self:GetSpecialValueFor("duration")})
		unit:AddNewModifier(caster, self, "modifier_imba_enigma_demonic_conversion_buff", {duration = self:GetSpecialValueFor("duration")})
		SetCreatureHealth(unit, unit:GetMaxHealth() + caster:GetLevel() * self:GetSpecialValueFor("health_per_level"), true)
	end
	target:Kill(self, caster)
end

modifier_imba_enigma_demonic_conversion_attack_count = class({})

function modifier_imba_enigma_demonic_conversion_attack_count:IsDebuff()			return false end
function modifier_imba_enigma_demonic_conversion_attack_count:IsHidden() 			return true end
function modifier_imba_enigma_demonic_conversion_attack_count:IsPurgable() 			return false end
function modifier_imba_enigma_demonic_conversion_attack_count:IsPurgeException() 	return false end

function modifier_imba_enigma_demonic_conversion_attack_count:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK} end

function modifier_imba_enigma_demonic_conversion_attack_count:OnAttack(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() then
		return
	end
	self:IncrementStackCount()
	if self:GetStackCount() > self:GetAbility():GetSpecialValueFor("attacks_to_split") then
		self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
		self:SetStackCount(0)
		local unit = CreateUnitByName("npc_imba_enigma_eidolon_"..self:GetAbility():GetLevel(), self:GetParent():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), false)
		unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kill", {duration = self:GetAbility():GetSpecialValueFor("child_duration") + self:GetRemainingTime()})
		unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_enigma_demonic_conversion_attack_count", {duration = self:GetAbility():GetSpecialValueFor("child_duration") + self:GetRemainingTime()})
		unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_enigma_demonic_conversion_buff", {duration = self:GetAbility():GetSpecialValueFor("child_duration") + self:GetRemainingTime()})
	end
end

modifier_imba_enigma_demonic_conversion_buff = class({})

function modifier_imba_enigma_demonic_conversion_buff:IsDebuff()			return false end
function modifier_imba_enigma_demonic_conversion_buff:IsHidden() 			return true end
function modifier_imba_enigma_demonic_conversion_buff:IsPurgable() 			return false end
function modifier_imba_enigma_demonic_conversion_buff:IsPurgeException() 	return false end

function modifier_imba_enigma_demonic_conversion_buff:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetCaster():GetLevel())
	end
end

function modifier_imba_enigma_demonic_conversion_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_imba_enigma_demonic_conversion_buff:GetModifierMoveSpeedBonus_Percentage() return (self:GetAbility():GetSpecialValueFor("ms_per_level") * self:GetStackCount()) end
function modifier_imba_enigma_demonic_conversion_buff:GetModifierPreAttack_BonusDamage() return (self:GetAbility():GetSpecialValueFor("damage_per_level") * self:GetStackCount()) end

imba_enigma_midnight_pulse = class({})

LinkLuaModifier("modifier_imba_enigma_midnight_pulse_thinker", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)

function imba_enigma_midnight_pulse:IsHiddenWhenStolen() 	return false end
function imba_enigma_midnight_pulse:IsRefreshable() 		return true  end
function imba_enigma_midnight_pulse:IsStealable() 			return true  end
function imba_enigma_midnight_pulse:IsNetherWardStealable() return true end

function imba_enigma_midnight_pulse:GetAOERadius() return self:GetSpecialValueFor("radius") + self:GetCaster():GetModifierStackCount("modifier_imba_enigma_black_hole_singularity", self:GetCaster()) * self:GetSpecialValueFor("singularity_radius") end

function imba_enigma_midnight_pulse:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	CreateModifierThinker(caster, self, "modifier_imba_enigma_midnight_pulse_thinker", {duration = self:GetSpecialValueFor('duration')}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_enigma_midnight_pulse_thinker = class({})

function modifier_imba_enigma_midnight_pulse_thinker:RemoveOnDeath() return true end

function modifier_imba_enigma_midnight_pulse_thinker:OnCreated()
	if IsServer() then
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Enigma.Midnight_Pulse", self:GetParent())
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetAOERadius(), false)
		self:StartIntervalThink(1.0)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetAOERadius(), self:GetAbility():GetAOERadius(), self:GetAbility():GetAOERadius()))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_enigma_midnight_pulse_thinker:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not enemy:IsBoss() then
			local dmg = enemy:GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("damage_per_tick") / 100)
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = dmg,
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
			if not enemy:HasModifier("modifier_imba_enigma_black_hole_aura") and not enemy:HasModifier("modifier_imba_enigma_black_hole_out_pull") and not enemy:HasModifier("modifier_batrider_flaming_lasso") then
				local direction = (self:GetParent():GetAbsOrigin() - enemy:GetAbsOrigin()):Normalized()
				direction.z = 0.0
				local new_pos = enemy:GetAbsOrigin() + direction * self:GetAbility():GetSpecialValueFor("pull_distance")
				FindClearSpaceForUnit(enemy, new_pos, true)
			end
		end
	end
end

imba_enigma_gravity = class({})

LinkLuaModifier("modifier_imba_enigma_gravity_passive", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_enigma_gravity_aura", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)

function imba_enigma_gravity:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_enigma_gravity:IsTalentAbility() return true end
function imba_enigma_gravity:GetIntrinsicModifierName() return "modifier_imba_enigma_gravity_passive" end

modifier_imba_enigma_gravity_passive = class({})

function modifier_imba_enigma_gravity_passive:IsDebuff()			return false end
function modifier_imba_enigma_gravity_passive:IsHidden() 			return true end
function modifier_imba_enigma_gravity_passive:IsPurgable() 			return false end
function modifier_imba_enigma_gravity_passive:IsPurgeException() 	return false end

function modifier_imba_enigma_gravity_passive:IsAura()
	if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then
		return false
	else
		return true
	end
end
function modifier_imba_enigma_gravity_passive:GetAuraDuration() return 0.1 + self:GetCaster():GetTalentValue("special_bonus_imba_enigma_2") end
function modifier_imba_enigma_gravity_passive:GetModifierAura() return "modifier_imba_enigma_gravity_aura" end
function modifier_imba_enigma_gravity_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_enigma_gravity_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_imba_enigma_gravity_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_enigma_gravity_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_enigma_gravity_aura = class({})

function modifier_imba_enigma_gravity_aura:IsDebuff()			return true end
function modifier_imba_enigma_gravity_aura:IsHidden() 			return false end
function modifier_imba_enigma_gravity_aura:IsPurgable() 		return false end
function modifier_imba_enigma_gravity_aura:IsPurgeException() 	return false end

imba_enigma_black_hole = class({})

LinkLuaModifier("modifier_imba_enigma_black_hole_singularity", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_enigma_black_hole_thinker", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_enigma_black_hole_out_pull", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_enigma_black_hole_aura", "hero/hero_enigma", LUA_MODIFIER_MOTION_NONE)

modifier_imba_enigma_black_hole_singularity = class({})
function modifier_imba_enigma_black_hole_singularity:IsDebuff()			return false end
function modifier_imba_enigma_black_hole_singularity:IsHidden() 		return false end
function modifier_imba_enigma_black_hole_singularity:IsPurgable() 		return false end
function modifier_imba_enigma_black_hole_singularity:IsPurgeException() return false end

function imba_enigma_black_hole:IsHiddenWhenStolen() 	return false end
function imba_enigma_black_hole:IsRefreshable() 		return true  end
function imba_enigma_black_hole:IsStealable() 			return true  end
function imba_enigma_black_hole:IsNetherWardStealable() return true end

function imba_enigma_black_hole:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_enigma_black_hole:GetIntrinsicModifierName() return "modifier_imba_enigma_black_hole_singularity" end

function imba_enigma_black_hole:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	self.pos = pos
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	local buff = caster:FindModifierByName("modifier_imba_enigma_black_hole_singularity")
	buff:SetStackCount(buff:GetStackCount() + #enemies)
	self.thinker = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = self:GetChannelTime() + FrameTime() * 2}, pos, caster:GetTeamNumber(), false)
	self.thinker:AddNewModifier(caster, self, "modifier_imba_enigma_black_hole_thinker", {duration = self:GetChannelTime()})
end

function imba_enigma_black_hole:OnChannelFinish(a)
	if self.thinker and not self.thinker:IsNull() then
		--[[self.thinker:StopSound("Hero_Enigma.Black_Hole")
		self.thinker:StopSound("Hero_Enigma.Black_Hole")
		self.thinker:StopSound("Hero_Enigma.Black_Hole")]]
		local buff = self.thinker:FindModifierByName("modifier_imba_enigma_black_hole_thinker")
		Timers:CreateTimer(FrameTime(), function()
				buff:Destroy()
				return nil
			end
		)
		
		--[[if not self.thinker:IsNull() then
			self.thinker:ForceKill(false)
		end]]
		self.thinker = nil
	end
end

modifier_imba_enigma_black_hole_thinker = class({})

function modifier_imba_enigma_black_hole_thinker:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Enigma.Black_Hole")
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		local enemies2 = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 250000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
		local hole_pfx = "particles/units/heroes/hero_enigma/enigma_blackhole.vpcf"
		if #enemies >= #enemies2 / 2 and enemies2 ~= 0 then
			hole_pfx = "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf"
			EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Imba.EnigmaBlackHoleTobi0"..math.random(1, 5), self:GetParent())
			self:SetStackCount(1)
		end
		local pos = self:GetParent():GetAbsOrigin()
		pos.z = pos.z + 100
		local pfx = ParticleManager:CreateParticle(hole_pfx, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, pos)
		self:AddParticle(pfx, false, false, 15, false, false)

		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_enigma_black_hole_thinker:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local dmg = self:GetAbility():GetSpecialValueFor("damage") / (1.0 / 0.2)
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
		if self:GetCaster():HasScepter() then
			local dmg2 = enemy:GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("damage_scepter") / 100) / (1.0 / 0.2)
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = dmg2,
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
		end
	end


	local out_distance = self:GetAbility():GetSpecialValueFor("base_pull_distance") + self:GetCaster():GetModifierStackCount("modifier_imba_enigma_black_hole_singularity", self:GetCaster()) * self:GetAbility():GetSpecialValueFor("stack_pull_distance")
	local enemies2 = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, out_distance, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies2) do
		if not enemy:HasModifier("modifier_imba_enigma_black_hole_aura") then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_enigma_black_hole_out_pull", {})
		end
	end
end

function modifier_imba_enigma_black_hole_thinker:IsAura() return true end
function modifier_imba_enigma_black_hole_thinker:GetAuraDuration() return 0.1 end
function modifier_imba_enigma_black_hole_thinker:GetModifierAura() return "modifier_imba_enigma_black_hole_aura" end
function modifier_imba_enigma_black_hole_thinker:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function modifier_imba_enigma_black_hole_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_enigma_black_hole_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_enigma_black_hole_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imba_enigma_black_hole_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Enigma.Black_Hole")
		self:GetParent():StopSound("Hero_Enigma.Black_Hole")
		self:GetParent():StopSound("Hero_Enigma.Black_Hole")
		self:GetParent():EmitSound("Hero_Enigma.Black_Hole.Stop")
	end
end

modifier_imba_enigma_black_hole_aura = class({})

function modifier_imba_enigma_black_hole_aura:IsDebuff()			return true end
function modifier_imba_enigma_black_hole_aura:IsHidden() 			return false end
function modifier_imba_enigma_black_hole_aura:IsPurgable() 			return false end
function modifier_imba_enigma_black_hole_aura:IsPurgeException() 	return false end
function modifier_imba_enigma_black_hole_aura:IsStunDebuff()		return true end
function modifier_imba_enigma_black_hole_aura:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end
function modifier_imba_enigma_black_hole_aura:IsMotionController()	return true end

function modifier_imba_enigma_black_hole_aura:OnCreated()
	if IsServer() then
		local a = self:CheckMotionControllers() and self:StartIntervalThink(FrameTime()) or 0
		local pfx = ParticleManager:CreateParticleForPlayer("particles/hero/enigma/screen_blackhole_indicator.vpcf", PATTACH_EYES_FOLLOW, self:GetParent(), PlayerResource:GetPlayer(self:GetParent():GetPlayerID()))
		self:AddParticle(pfx, false, false, 15, false, false)
		if self:GetParent():IsTrueHero() then
			PlayerResource:SetCameraTarget(self:GetParent():GetPlayerOwnerID(), self:GetParent())
		end
	end
end

function modifier_imba_enigma_black_hole_aura:OnIntervalThink()
	self:CheckMotionControllers()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local ability = self:GetAbility()
	local distance = (self:GetParent():GetAbsOrigin() - ability.pos):Length2D()
	local in_pull = 250
	local new_pos = GetGroundPosition(RotatePosition(ability.pos, QAngle(0,1.5,0), self:GetParent():GetAbsOrigin()), self:GetParent())
	if distance > 20 then
		local direction = (ability.pos - new_pos):Normalized()
		direction.z = 0.0
		new_pos = new_pos + direction * in_pull / (1.0 / FrameTime())
	end
	self:GetParent():SetAbsOrigin(new_pos)
end

function modifier_imba_enigma_black_hole_aura:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_imba_enigma_black_hole_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_imba_enigma_black_hole_aura:GetOverrideAnimation() return ACT_DOTA_FLAIL end

function modifier_imba_enigma_black_hole_aura:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		PlayerResource:SetCameraTarget(self:GetParent():GetPlayerID(), nil)
	end
end

modifier_imba_enigma_black_hole_out_pull = class({})

function modifier_imba_enigma_black_hole_out_pull:IsDebuff()			return false end
function modifier_imba_enigma_black_hole_out_pull:IsHidden() 			return false end
function modifier_imba_enigma_black_hole_out_pull:IsPurgable() 			return false end
function modifier_imba_enigma_black_hole_out_pull:IsPurgeException() 	return false end
function modifier_imba_enigma_black_hole_out_pull:IsStunDebuff()		return false end
function modifier_imba_enigma_black_hole_out_pull:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOW end
function modifier_imba_enigma_black_hole_out_pull:IsMotionController()	return true end

function modifier_imba_enigma_black_hole_out_pull:OnCreated()
	if IsServer() then
		self:CheckMotionControllers()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_enigma_black_hole_out_pull:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_imba_enigma_black_hole_aura") then
		self:Destroy()
		return
	end
	local ability = self:GetAbility()
	local out_distance = self:GetAbility():GetSpecialValueFor("base_pull_distance") + self:GetCaster():GetModifierStackCount("modifier_imba_enigma_black_hole_singularity", self:GetCaster()) * self:GetAbility():GetSpecialValueFor("stack_pull_distance")
	if not ability:IsChanneling() or (self:GetParent():GetAbsOrigin() - ability.pos):Length2D() > out_distance or self:GetParent():IsBoss() then
		self:Destroy()
	end
	local out_pull = ability:GetSpecialValueFor("base_pull_speed") + self:GetCaster():GetModifierStackCount("modifier_imba_enigma_black_hole_singularity", self:GetCaster()) * ability:GetSpecialValueFor("stack_pull_speed")
	if self:GetCaster():HasScepter() then
		out_pull = out_pull + self:GetAbility():GetSpecialValueFor("pull_speed_scepter")
	end
	local direction = (ability.pos - self:GetParent():GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local new_pos = self:GetParent():GetAbsOrigin() + direction * (out_pull / (1.0 / FrameTime()))
	self:GetParent():SetAbsOrigin(new_pos)
end

function modifier_imba_enigma_black_hole_out_pull:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_enigma_black_hole_aura") then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end