CreateEmptyTalents("abaddon")

imba_abaddon_death_coil = class({})

function imba_abaddon_death_coil:IsHiddenWhenStolen() 		return false end
function imba_abaddon_death_coil:IsRefreshable() 			return true end
function imba_abaddon_death_coil:IsStealable() 				return true end
function imba_abaddon_death_coil:IsNetherWardStealable()	return true end

function imba_abaddon_death_coil:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		vSourceLoc = caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
	caster:Heal(self:GetSpecialValueFor("self_heal"), caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, self:GetSpecialValueFor("self_heal"), nil)
end

function imba_abaddon_death_coil:OnProjectileHit(target, location)
	if not target then
		return
	end
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Abaddon.DeathCoil.Target", target)
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local debuff = target:FindModifierByName("modifier_frostmourne_debuff")
	local buff = target:FindModifierByName("modifier_frostmourne_buff")
	if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		target:Heal(self:GetSpecialValueFor("target_damage"), self:GetCaster())
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, self:GetSpecialValueFor("target_damage"), nil)
		if buff then
			buff:SetStackCount(math.min(buff:GetStackCount() + 1, buff:GetAbility():GetSpecialValueFor("max_stacks")))
			buff:SetDuration(buff:GetDuration(), true)
		end
	else
		if target:IsMagicImmune() then
			return true
		end
		local damageTable = {
							victim = target,
							attacker = self:GetCaster(),
							damage = self:GetSpecialValueFor("target_damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		if debuff then
			debuff:SetStackCount(math.min(debuff:GetStackCount() + 1, debuff:GetAbility():GetSpecialValueFor("max_stacks")))
			debuff:SetDuration(debuff:GetDuration(), true)
		end
	end
	return true
end

imba_abaddon_aphotic_shield = class({})

LinkLuaModifier("modifier_imba_aphotic_shield", "hero/hero_abaddon", LUA_MODIFIER_MOTION_NONE)

function imba_abaddon_aphotic_shield:IsHiddenWhenStolen() 		return false end
function imba_abaddon_aphotic_shield:IsRefreshable() 			return true end
function imba_abaddon_aphotic_shield:IsStealable() 				return true end
function imba_abaddon_aphotic_shield:IsNetherWardStealable()	return true end
function imba_abaddon_aphotic_shield:GetCooldown(i) return self:GetSpecialValueFor("charge_cooldown") end

function imba_abaddon_aphotic_shield:OnUpgrade()
	AbilityChargeController:AbilityChargeInitialize(self, self:GetSpecialValueFor("charge_cooldown"), self:GetSpecialValueFor("max_charges"), 1, true, true)
end

function imba_abaddon_aphotic_shield:OnSpellStart()
	local target = self:GetCursorTarget()
	local buff = target:FindModifierByName("modifier_imba_aphotic_shield")
	if buff then
		buff:SetStackCount(0)
		buff:Destroy()
	end
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_aphotic_shield", {duration = self:GetSpecialValueFor("duration")})
	target:Purge(false, true, false, true, true)
end

modifier_imba_aphotic_shield = class({})

function modifier_imba_aphotic_shield:IsDebuff()			return false end
function modifier_imba_aphotic_shield:IsHidden() 			return false end
function modifier_imba_aphotic_shield:IsPurgable() 			return true end
function modifier_imba_aphotic_shield:IsPurgeException() 	return true end

function modifier_imba_aphotic_shield:OnCreated()
	self:SetAbilityKV()
	self:SetStackCount(self:GetAbilityKV("damage_absorb") + self:GetCaster():GetTalentValue("special_bonus_imba_abaddon_1"))
	if IsClient() then
		EmitSoundOn("Hero_Abaddon.AphoticShield.Loop", self:GetParent())
		EmitSoundOn("Hero_Abaddon.AphoticShield.Cast", self:GetParent())
	end
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		local ex = self:GetParent():GetModelScale() * 100
		ParticleManager:SetParticleControl(pfx, 1, Vector(ex,ex,ex))
		ParticleManager:SetParticleControl(pfx, 2, Vector(ex,ex,ex))
		ParticleManager:SetParticleControl(pfx, 4, Vector(ex,ex,ex))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_aphotic_shield:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE,}
	return funcs
end

function modifier_imba_aphotic_shield:OnTakeDamage(keys)
	if keys.unit ~= self:GetParent() then
		return 
	end
	if IsServer() then
		if keys.damage < self:GetStackCount() then
			self:GetParent():SetHealth(self:GetParent():GetHealth() + keys.damage)
			self:SetStackCount(self:GetStackCount() - keys.damage)
		else
			self:GetParent():SetHealth(self:GetParent():GetHealth() + self:GetStackCount())
			self:SetStackCount(0)
			self:Destroy()
		end
	end
end

function modifier_imba_aphotic_shield:OnDestroy()
	if IsClient() then
		StopSoundOn("Hero_Abaddon.AphoticShield.Loop", self:GetParent())
		EmitSoundOn("Hero_Abaddon.AphoticShield.Destroy", self:GetParent())
	end
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		local pos = self:GetParent():GetAttachmentOrigin(self:GetParent():ScriptLookupAttachment("attach_hitloc"))
		ParticleManager:SetParticleControl(pfx, 0, pos)
		ParticleManager:SetParticleControl(pfx, 5, pos)
		ParticleManager:ReleaseParticleIndex(pfx)

		local damage = self:GetAbilityKV("damage_absorb") - self:GetStackCount()
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
											self:GetParent():GetAbsOrigin(),
											nil,
											self:GetAbilityKV("radius"),
											DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
											DOTA_UNIT_TARGET_FLAG_NONE,
											FIND_ANY_ORDER,
											false)
		for _, enemy in pairs(enemies) do
			local debuff = enemy:FindModifierByName("modifier_frostmourne_debuff")
			if debuff then
				debuff:SetStackCount(math.min(debuff:GetStackCount() + 1, debuff:GetAbility():GetSpecialValueFor("max_stacks")))
				debuff:SetDuration(debuff:GetDuration(), true)
			end
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = damage,
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
		end
	end
end

imba_abaddon_frostmourne = class({})

LinkLuaModifier("modifier_frostmourne_debuff", "hero/hero_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frostmourne_buff", "hero/hero_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frostmourne", "hero/hero_abaddon", LUA_MODIFIER_MOTION_NONE)

function imba_abaddon_frostmourne:GetIntrinsicModifierName() return "modifier_frostmourne" end

modifier_frostmourne = class({})

function modifier_frostmourne:IsHidden() return true end

function modifier_frostmourne:DeclareFunctions()
	local funcs = {
					MODIFIER_EVENT_ON_ATTACK_LANDED,
				}
	return funcs
end

function modifier_frostmourne:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetCaster():IsIllusion() then
		return
	end
	if keys.attacker ~= self:GetCaster() then
		return
	end
	if keys.target:IsOther() or keys.target:GetTeamNumber() == self:GetCaster():GetTeamNumber() or not keys.target:IsAlive() then
		return
	end
	if keys.target:HasModifier("modifier_frostmourne_debuff") then
		local debuff = keys.target:FindModifierByName("modifier_frostmourne_debuff")
		debuff:SetStackCount(math.min(debuff:GetStackCount()+1, self:GetAbility():GetSpecialValueFor("max_stacks")))
		debuff:SetDuration(debuff:GetDuration(), true)
	else
		local debuff = keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_frostmourne_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
		debuff:SetStackCount(1)
	end
	local buff = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_frostmourne_buff", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
	buff:SetStackCount( keys.target:FindModifierByName("modifier_frostmourne_debuff"):GetStackCount())
end

modifier_frostmourne_debuff = class({})
modifier_frostmourne_buff = class({})

function modifier_frostmourne_debuff:IsDebuff()				return true end
function modifier_frostmourne_debuff:IsHidden() 			return false end
function modifier_frostmourne_debuff:IsPurgable() 			return true end
function modifier_frostmourne_debuff:IsPurgeException() 	return true end
function modifier_frostmourne_debuff:GetEffectName()		return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf" end

function modifier_frostmourne_debuff:DeclareFunctions()
	local funcs = {
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_EVENT_ON_ATTACK_LANDED,
					}
	return funcs
end

function modifier_frostmourne_debuff:GetModifierMoveSpeedBonus_Percentage() return ((0 - self:GetAbility():GetSpecialValueFor("debuff_slow")) * self:GetStackCount()) end

function modifier_frostmourne_debuff:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.target ~= self:GetParent() or not keys.target:IsAlive() or not keys.attacker:IsAlive() then
		return
	end
	if keys.attacker:IsBuilding() or keys.attacker:IsOther() or keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return
	end
	local buff = keys.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_frostmourne_buff", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
	buff:SetStackCount(self:GetStackCount())
end

function modifier_frostmourne_buff:IsDebuff()				return false end
function modifier_frostmourne_buff:IsHidden() 				return false end
function modifier_frostmourne_buff:IsPurgable() 			return true end
function modifier_frostmourne_buff:IsPurgeException() 		return true end
function modifier_frostmourne_buff:GetEffectName()			return "particles/units/heroes/hero_abaddon/abaddon_frost_buff.vpcf" end

function modifier_frostmourne_buff:DeclareFunctions()
	local funcs = {
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					}
	return funcs
end

function modifier_frostmourne_buff:GetModifierMoveSpeedBonus_Percentage() return (self:GetAbility():GetSpecialValueFor("buff_ms") * self:GetStackCount()) end

function modifier_frostmourne_buff:GetModifierAttackSpeedBonus_Constant() return (self:GetAbility():GetSpecialValueFor("buff_as") * self:GetStackCount()) end


imba_abaddon_borrowed_time = class({})

LinkLuaModifier("modifier_borrowed_time", "hero/hero_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_borrowed_time_allies", "hero/hero_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_borrowed_time_autocast", "hero/hero_abaddon", LUA_MODIFIER_MOTION_NONE)

function imba_abaddon_borrowed_time:IsHiddenWhenStolen() 		return false end
function imba_abaddon_borrowed_time:IsRefreshable() 			return true  end
function imba_abaddon_borrowed_time:IsStealable() 				return true  end
function imba_abaddon_borrowed_time:IsNetherWardStealable()		return true end

function imba_abaddon_borrowed_time:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("redirect_range") - self:GetCaster():GetCastRangeBonus() end

function imba_abaddon_borrowed_time:GetIntrinsicModifierName() return "modifier_borrowed_time_autocast" end

function imba_abaddon_borrowed_time:OnSpellStart()
	EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_Abaddon.BorrowedTime", self:GetCaster())
	self:GetCaster():Purge(false, true, false, true, true)
	if self:GetCaster():HasScepter() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_borrowed_time", {duration = self:GetSpecialValueFor("duration_scepter")})
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_borrowed_time", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_borrowed_time_autocast = class({})

function modifier_borrowed_time_autocast:IsDebuff()				return false end
function modifier_borrowed_time_autocast:IsHidden() 			return true end
function modifier_borrowed_time_autocast:IsPurgable() 			return false end
function modifier_borrowed_time_autocast:IsPurgeException() 	return false end

function modifier_borrowed_time_autocast:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return funcs
end

function modifier_borrowed_time_autocast:OnCreated() self:SetAbilityKV() end

function modifier_borrowed_time_autocast:OnRefresh() self:OnCreated() end

function modifier_borrowed_time_autocast:OnTakeDamage(keys)
	if keys.unit ~= self:GetParent() then
		return 
	end
	if IsServer() then
		if self:GetParent():GetHealth() <= self:GetAbilityKV("hp_threshold") and not self:GetParent():PassivesDisabled() and not self:GetParent():IsIllusion() and self:GetAbility():IsCooldownReady() then
			self:GetAbility():OnSpellStart()
			self:GetAbility():UseResources(false, false, true)
		end
	end
end

modifier_borrowed_time = class({})
modifier_borrowed_time_allies = class({})

function modifier_borrowed_time:IsDebuff()			return false end
function modifier_borrowed_time:IsHidden() 			return false end
function modifier_borrowed_time:IsPurgable() 		return false end
function modifier_borrowed_time:IsPurgeException() 	return false end

function modifier_borrowed_time:GetEffectName() return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf" end
function modifier_borrowed_time:GetStatusEffectName() return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf" end
function modifier_borrowed_time:StatusEffectPriority() return 15 end

function modifier_borrowed_time:IsAura() return true end
function modifier_borrowed_time:GetAuraDuration() return 0.1 end
function modifier_borrowed_time:GetModifierAura() return "modifier_borrowed_time_allies" end
function modifier_borrowed_time:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("redirect_range") end
function modifier_borrowed_time:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_borrowed_time:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_borrowed_time:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_borrowed_time:GetAuraEntityReject(unit)
	if unit == self:GetParent() then
		return true
	end
	return false
end

function modifier_borrowed_time:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,}
	return funcs
end

function modifier_borrowed_time:GetModifierIncomingDamage_Percentage(keys)
	if IsServer() then
		local dmg = math.max(0, keys.damage)
		if not self:GetCaster():HasScepter() then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx, 1, self:GetCaster():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(pfx)
			self:GetCaster():Heal(math.max(0, dmg), self:GetCaster())
		else
			local allies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
											self:GetCaster():GetAbsOrigin(),
											nil,
											self:GetAbility():GetSpecialValueFor("redirect_range"),
											DOTA_UNIT_TARGET_TEAM_FRIENDLY,
											DOTA_UNIT_TARGET_HERO,
											DOTA_UNIT_TARGET_FLAG_NONE,
											FIND_ANY_ORDER,
											false)
			local heal_num = math.max(0, dmg) / #allies
			local caster = self:GetCaster()
			for _, ally in pairs(allies) do
				local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
				ParticleManager:SetParticleControl(pfx, 0, ally:GetAbsOrigin())
				ParticleManager:SetParticleControl(pfx, 1, ally:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(pfx)
				ally:Heal(heal_num, caster)
			end
		end
		return -10000
	end
end

function modifier_borrowed_time_allies:IsDebuff()				return false end
function modifier_borrowed_time_allies:IsHidden() 				return false end
function modifier_borrowed_time_allies:IsPurgable() 			return false end
function modifier_borrowed_time_allies:IsPurgeException() 		return false end

function modifier_borrowed_time_allies:GetEffectName() return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf" end

function modifier_borrowed_time_allies:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return funcs
end

function modifier_borrowed_time_allies:OnTakeDamage(keys)
	if keys.unit ~= self:GetParent() then
		return 
	end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end
	if IsServer() then
		local dmg_to_abadon = keys.damage * (self:GetAbility():GetSpecialValueFor("redirect") / 100)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		Timers:CreateTimer(FrameTime(), function()
				if parent:IsAlive() then
					parent:SetHealth(parent:GetHealth() + dmg_to_abadon)
				end
				return nil
			end
		)
		local damageTable = {
							victim = self:GetCaster(),
							attacker = self:GetParent(),
							damage = dmg_to_abadon,
							damage_type = DAMAGE_TYPE_PURE,
							damage_flags = DOTA_DAMAGE_FLAG_REFLECTION, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
	end
end