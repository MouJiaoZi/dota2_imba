
---------------------------------


--models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl
-- EmitSound("Imba.WarlockYouFaceJaraxxus")

CreateEmptyTalents("warlock")


imba_warlock_fatal_bonds = class({})

LinkLuaModifier("modifier_imba_fetal_bonds_caster", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fetal_bonds_target", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fetal_bonds_refresh_cooldown", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)

function imba_warlock_fatal_bonds:IsHiddenWhenStolen() 		return false end
function imba_warlock_fatal_bonds:IsRefreshable() 			return true end
function imba_warlock_fatal_bonds:IsStealable() 			return true end
function imba_warlock_fatal_bonds:IsNetherWardStealable()	return true end
function imba_warlock_fatal_bonds:GetAOERadius() return self:GetSpecialValueFor("search_aoe") end
function imba_warlock_fatal_bonds:GetCastRange() return self.BaseClass.GetCastRange(self, Vector(0,0,0), self:GetCaster()) end

function imba_warlock_fatal_bonds:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("Hero_Warlock.FatalBonds")
	local linkTarget = {target, }
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("search_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	for i=1, self:GetSpecialValueFor("count") do
		if enemies[i] and enemies[i] ~= target then
			linkTarget[#linkTarget + 1] = enemies[i]
		end
	end
	local casterBuff = caster:AddNewModifier(caster, self, "modifier_imba_fetal_bonds_caster", {duration = self:GetSpecialValueFor("duration") + 0.1})
	casterBuff.targets = {}
	for i=1, #linkTarget do
		local targetBuff = linkTarget[i]:AddNewModifier(caster, self, "modifier_imba_fetal_bonds_target", {duration = self:GetSpecialValueFor("duration")})
		targetBuff.buff = casterBuff
		casterBuff.targets[#casterBuff.targets + 1] = linkTarget[i]
	end
end

modifier_imba_fetal_bonds_caster = class({})

function modifier_imba_fetal_bonds_caster:IsDebuff()			return false end
function modifier_imba_fetal_bonds_caster:IsHidden() 			return true end
function modifier_imba_fetal_bonds_caster:IsPurgable() 			return false end
function modifier_imba_fetal_bonds_caster:IsPurgeException() 	return false end
function modifier_imba_fetal_bonds_caster:RemoveOnDeath() return false end
function modifier_imba_fetal_bonds_caster:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_fetal_bonds_caster:FetalBond(fDamage, hUnit, hAttacker)
	if not IsServer() then
		return
	end
	hUnit:EmitSound("Hero_Warlock.FatalBondsDamage")
	for i=1, #self.targets do
		if self.targets[i] and self.targets[i] ~= hUnit then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(pfx, 0, hUnit, PATTACH_POINT_FOLLOW, "attach_hitloc", hUnit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, self.targets[i], PATTACH_POINT_FOLLOW, "attach_hitloc", self.targets[i]:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx)
			ApplyDamage({attacker = hAttacker, victim = self.targets[i], damage = fDamage * (self:GetAbility():GetSpecialValueFor("damage_share_percentage") / 100), damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, ability = self:GetAbility()})
			self.targets[i]:EmitSound("Hero_Warlock.FatalBondsDamage")
		end
	end
end

function modifier_imba_fetal_bonds_caster:OnDestroy()
	if IsServer() then
		self.targets = nil
	end
end

modifier_imba_fetal_bonds_target = class({})

function modifier_imba_fetal_bonds_target:IsDebuff()			return true end
function modifier_imba_fetal_bonds_target:IsHidden() 			return false end
function modifier_imba_fetal_bonds_target:IsPurgable() 			return true end
function modifier_imba_fetal_bonds_target:IsPurgeException() 	return true end
function modifier_imba_fetal_bonds_target:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_fetal_bonds_target:GetEffectName() return "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf" end
function modifier_imba_fetal_bonds_target:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_fetal_bonds_target:ShouldUseOverheadOffset() return true end
function modifier_imba_fetal_bonds_target:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_DEATH} end

function modifier_imba_fetal_bonds_target:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() or bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION or not self.buff then
		return
	end
	self.buff:FetalBond(keys.damage, self:GetParent(), keys.attacker)
end

function modifier_imba_fetal_bonds_target:OnDeath(keys)
	if not IsServer() or keys.unit ~= self:GetParent() or not self:GetParent():IsTrueHero() or self:GetCaster():HasModifier("modifier_imba_fetal_bonds_refresh_cooldown") then
		return
	end
	self:GetAbility():EndCooldown()
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_fetal_bonds_refresh_cooldown", {duration = (self:GetAbility():GetSpecialValueFor("refresh_cooldown") + self:GetCaster():GetTalentValue("special_bonus_imba_warlock_2"))})
end

function modifier_imba_fetal_bonds_target:OnDestroy()
	if IsServer() then
		if self.buff and self.buff.targets then
			for i=1, #self.buff.targets do
				if self.buff.targets[i] == self:GetParent() then
					self.buff.targets[i] = nil
				end
			end
			self.buff = nil
		end
	end
end

modifier_imba_fetal_bonds_refresh_cooldown = class({})

function modifier_imba_fetal_bonds_refresh_cooldown:IsDebuff()			return false end
function modifier_imba_fetal_bonds_refresh_cooldown:IsHidden() 			return false end
function modifier_imba_fetal_bonds_refresh_cooldown:IsPurgable() 		return false end
function modifier_imba_fetal_bonds_refresh_cooldown:IsPurgeException() 	return false end

imba_warlock_shadow_word = class({})

LinkLuaModifier("modifier_imba_shadow_word_buff", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_word_debuff", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)

function imba_warlock_shadow_word:IsHiddenWhenStolen() 		return false end
function imba_warlock_shadow_word:IsRefreshable() 			return true end
function imba_warlock_shadow_word:IsStealable() 			return true end
function imba_warlock_shadow_word:IsNetherWardStealable()	return true end

function imba_warlock_shadow_word:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	if IsEnemy(caster, target) then
		target:EmitSound("Hero_Warlock.ShadowWordCastBad")
		local buff = target:AddNewModifier(caster, self, "modifier_imba_shadow_word_debuff", {duration = self:GetSpecialValueFor("duration")})
		buff:SetStackCount(0)
	else
		target:EmitSound("Hero_Warlock.ShadowWordCastGood")
		local buff =target:AddNewModifier(caster, self, "modifier_imba_shadow_word_buff", {duration = self:GetSpecialValueFor("duration")})
		buff:SetStackCount(0)
	end
	caster:EmitSound("Hero_Warlock.Incantations")
end

modifier_imba_shadow_word_buff = class({})

function modifier_imba_shadow_word_buff:IsDebuff()			return false end
function modifier_imba_shadow_word_buff:IsHidden() 			return false end
function modifier_imba_shadow_word_buff:IsPurgable() 		return true end
function modifier_imba_shadow_word_buff:IsPurgeException() 	return true end
function modifier_imba_shadow_word_buff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_shadow_word_buff:GetModifierMoveSpeedBonus_Percentage() return (math.min((self:GetElapsedTime() / self:GetDuration()), 1.0) * self:GetAbility():GetSpecialValueFor("max_ms")) end
function modifier_imba_shadow_word_buff:GetModifierAttackSpeedBonus_Constant() return (math.min((self:GetElapsedTime() / self:GetDuration()), 1.0) * self:GetAbility():GetSpecialValueFor("max_as")) end
function modifier_imba_shadow_word_buff:GetModifierBaseDamageOutgoing_Percentage() return (math.min((self:GetElapsedTime() / self:GetDuration()), 1.0) * self:GetAbility():GetSpecialValueFor("max_damage")) end
function modifier_imba_shadow_word_buff:GetEffectName() return "particles/units/heroes/hero_warlock/warlock_shadow_word_buff.vpcf" end
function modifier_imba_shadow_word_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_shadow_word_buff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
		self:GetParent():EmitSound("Hero_Warlock.ShadowWord")
	end
end

function modifier_imba_shadow_word_buff:OnIntervalThink()
	local heal = self:GetAbility():GetSpecialValueFor("damage_per_second") / (1.0 / self:GetAbility():GetSpecialValueFor("tick_interval"))
	heal = (1 + self:GetCaster():GetSpellAmplification(false)) * heal
	self:GetParent():Heal(heal, self:GetAbility())
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), heal, nil)
end

function modifier_imba_shadow_word_buff:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Warlock.ShadowWord")
		if self:GetStackCount() >= 0 then
			self:GetParent():EmitSound("Imba.WarlockShadowWordExplosion")
			local pfx = ParticleManager:CreateParticle("particles/hero/warlock/shadow_word_explosion_good.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:ReleaseParticleIndex(pfx)
			local unit = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("spread_aoe"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for i=1, #unit do
				if self:GetParent() ~= unit[i] then
					if IsEnemy(self:GetCaster(), unit[i]) then
						unit[i]:EmitSound("Hero_Warlock.ShadowWordCastBad")
						local buff = unit[i]:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_shadow_word_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
						buff:SetStackCount(-1)
					else
						unit[i]:EmitSound("Hero_Warlock.ShadowWordCastGood")
						local buff = unit[i]:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_shadow_word_buff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
						buff:SetStackCount(-1)
					end
				end
			end
		end
	end
end

modifier_imba_shadow_word_debuff = class({})

function modifier_imba_shadow_word_debuff:IsDebuff()			return true end
function modifier_imba_shadow_word_debuff:IsHidden() 			return false end
function modifier_imba_shadow_word_debuff:IsPurgable() 			return true end
function modifier_imba_shadow_word_debuff:IsPurgeException() 	return true end
function modifier_imba_shadow_word_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_shadow_word_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - (math.min((self:GetElapsedTime() / self:GetDuration()), 1.0) * self:GetAbility():GetSpecialValueFor("max_ms"))) end
function modifier_imba_shadow_word_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - (math.min((self:GetElapsedTime() / self:GetDuration()), 1.0) * self:GetAbility():GetSpecialValueFor("max_as"))) end
function modifier_imba_shadow_word_debuff:GetModifierBaseDamageOutgoing_Percentage() return (0 - (math.min((self:GetElapsedTime() / self:GetDuration()), 1.0) * self:GetAbility():GetSpecialValueFor("max_damage"))) end
function modifier_imba_shadow_word_debuff:GetEffectName() return "particles/units/heroes/hero_warlock/warlock_shadow_word_debuff.vpcf" end
function modifier_imba_shadow_word_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_shadow_word_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
		self:GetParent():EmitSound("Hero_Warlock.ShadowWord")
	end
end

function modifier_imba_shadow_word_debuff:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("damage_per_second") / (1.0 / self:GetAbility():GetSpecialValueFor("tick_interval"))
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType()})
end

function modifier_imba_shadow_word_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Warlock.ShadowWord")
		if self:GetStackCount() >= 0 then
			self:GetParent():EmitSound("Imba.WarlockShadowWordExplosion")
			local pfx = ParticleManager:CreateParticle("particles/hero/warlock/shadow_word_explosion_bad.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:ReleaseParticleIndex(pfx)
			local unit = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("spread_aoe"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for i=1, #unit do
				if self:GetParent() ~= unit[i] then
					if IsEnemy(self:GetCaster(), unit[i]) then
						unit[i]:EmitSound("Hero_Warlock.ShadowWordCastBad")
						local buff = unit[i]:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_shadow_word_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
						buff:SetStackCount(-1)
					else
						unit[i]:EmitSound("Hero_Warlock.ShadowWordCastGood")
						local buff = unit[i]:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_shadow_word_buff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
						buff:SetStackCount(-1)
					end
				end
			end
		end
	end
end

imba_warlock_upheaval = class({})

LinkLuaModifier("modifier_imba_upheaval_npc", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_upheaval_aura_debuff", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)

function imba_warlock_upheaval:IsHiddenWhenStolen() 	return false end
function imba_warlock_upheaval:IsRefreshable() 			return true end
function imba_warlock_upheaval:IsStealable() 			return true end
function imba_warlock_upheaval:IsNetherWardStealable()	return false end
function imba_warlock_upheaval:GetAOERadius() return self:GetSpecialValueFor("slow_radius") end

function imba_warlock_upheaval:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local npc = CreateUnitByName("npc_imba_warlock_upheaval_tower", pos, false, caster, caster, caster:GetTeamNumber())
	FindClearSpaceForUnit(npc, pos, true)
	npc:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	npc:AddNewModifier(caster, self, "modifier_imba_upheaval_npc", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_upheaval_npc = class({})

function modifier_imba_upheaval_npc:IsDebuff()			return false end
function modifier_imba_upheaval_npc:IsHidden() 			return true end
function modifier_imba_upheaval_npc:IsPurgable() 		return false end
function modifier_imba_upheaval_npc:IsPurgeException() 	return false end
function modifier_imba_upheaval_npc:CheckState() return {[MODIFIER_STATE_MAGIC_IMMUNE] = true} end
function modifier_imba_upheaval_npc:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_HEALING} end
function modifier_imba_upheaval_npc:GetDisableHealing() return 1 end

function modifier_imba_upheaval_npc:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() or keys.target ~= self:GetParent() or keys.original_damage <= 0 then
		return
	end
	local damage = self:GetAbility():GetSpecialValueFor("hero_damage")
	if not keys.attacker:IsTrueHero() and not keys.attacker:IsTower() and not keys.attacker:IsBoss() then
		damage = 1
	end
	local health = self:GetParent():GetHealth()
	if health - damage <= 0 then
		self:GetParent():Kill(self:GetAbility(), keys.attacker)
	else
		self:GetParent():SetHealth(health - damage)
	end
	return -1000000
end

function modifier_imba_upheaval_npc:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Warlock.Upheaval")
		SetCreatureHealth(self:GetParent(), self:GetAbility():GetSpecialValueFor("health"), true)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_upheaval.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("slow_radius"),self:GetAbility():GetSpecialValueFor("slow_radius"),self:GetAbility():GetSpecialValueFor("slow_radius")))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	end
end

function modifier_imba_upheaval_npc:OnIntervalThink()
	if not self:GetParent():IsAlive() then
		self:Destroy()
		return
	end
	self:SetStackCount(self:GetStackCount() + 1)
	local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("slow_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		local buff = enemy[i]:FindModifierByName("modifier_imba_upheaval_aura_debuff")
		if buff then
			buff:SetStackCount(self:GetStackCount())
		end
	end
end

function modifier_imba_upheaval_npc:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Warlock.Upheaval")
	end
end

function modifier_imba_upheaval_npc:IsAura() return true end
function modifier_imba_upheaval_npc:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("slow_duration") end
function modifier_imba_upheaval_npc:GetModifierAura() return "modifier_imba_upheaval_aura_debuff" end
function modifier_imba_upheaval_npc:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("slow_radius") end
function modifier_imba_upheaval_npc:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_upheaval_npc:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_upheaval_npc:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_upheaval_aura_debuff = class({})

function modifier_imba_upheaval_aura_debuff:IsDebuff()			return true end
function modifier_imba_upheaval_aura_debuff:IsHidden() 			return false end
function modifier_imba_upheaval_aura_debuff:IsPurgable() 		return false end
function modifier_imba_upheaval_aura_debuff:IsPurgeException() 	return false end
function modifier_imba_upheaval_aura_debuff:GetEffectName() return "particles/units/heroes/hero_warlock/warlock_upheaval_debuff.vpcf" end
function modifier_imba_upheaval_aura_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_upheaval_aura_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_upheaval_aura_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - (self:GetStackCount() / (1.0 / self:GetAbility():GetSpecialValueFor("tick_interval"))) * self:GetAbility():GetSpecialValueFor("move_slow_tooltip")) end
function modifier_imba_upheaval_aura_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - (self:GetStackCount() / (1.0 / self:GetAbility():GetSpecialValueFor("tick_interval"))) * self:GetAbility():GetSpecialValueFor("move_slow_tooltip")) end

imba_warlock_rain_of_chaos = class({})

LinkLuaModifier("modifier_imba_rain_of_chaos_invul", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rain_of_chaos", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rain_of_chaos_attack_range", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rain_of_chaos_storm", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)

function imba_warlock_rain_of_chaos:IsHiddenWhenStolen() 	return false end
function imba_warlock_rain_of_chaos:IsRefreshable() 		return true end
function imba_warlock_rain_of_chaos:IsStealable() 			return false end
function imba_warlock_rain_of_chaos:IsNetherWardStealable()	return false end

function imba_warlock_rain_of_chaos:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	if RollPercentage(20) then
		caster:EmitSound("Imba.WarlockYouFaceJaraxxus")
	end
	caster:EmitSound("Hero_Warlock.RainOfChaos")
	local pfx_pre = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(pfx_pre, 0, pos)
	ParticleManager:ReleaseParticleIndex(pfx_pre)
	caster:AddNewModifier(caster, self, "modifier_imba_rain_of_chaos_invul", {duration = 0.5})
	Timers:CreateTimer(0.5, function()
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(pfx, 0, pos)
			ParticleManager:SetParticleControl(pfx, 1, Vector(500,0,0))
			ParticleManager:ReleaseParticleIndex(pfx)
			caster:AddNewModifier(caster, self, "modifier_imba_rain_of_chaos", {duration = self:GetSpecialValueFor("duration")})
			if not caster:HasTalent("special_bonus_imba_warlock_1") then
				caster:AddNewModifier(caster, self, "modifier_imba_rain_of_chaos_attack_range", {duration = self:GetSpecialValueFor("duration")})
			end
			return nil
		end
	)
end

modifier_imba_rain_of_chaos_invul = class({})

function modifier_imba_rain_of_chaos_invul:IsDebuff()			return false end
function modifier_imba_rain_of_chaos_invul:IsHidden() 			return true end
function modifier_imba_rain_of_chaos_invul:IsPurgable() 		return false end
function modifier_imba_rain_of_chaos_invul:IsPurgeException() 	return false end
function modifier_imba_rain_of_chaos_invul:GetEffectName() return "particles/hero/warlock/warlock_hands_of_goredan_ring.vpcf" end
function modifier_imba_rain_of_chaos_invul:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rain_of_chaos_invul:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end
function modifier_imba_rain_of_chaos_invul:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE} end
function modifier_imba_rain_of_chaos_invul:GetModifierModelChange() return "models/development/invisiblebox.vmdl" end

modifier_imba_rain_of_chaos = class({})

function modifier_imba_rain_of_chaos:IsDebuff()			return false end
function modifier_imba_rain_of_chaos:IsHidden() 		return false end
function modifier_imba_rain_of_chaos:IsPurgable() 		return false end
function modifier_imba_rain_of_chaos:IsPurgeException() return false end
function modifier_imba_rain_of_chaos:AllowIllusionDuplicate() return false end
function modifier_imba_rain_of_chaos:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_rain_of_chaos:GetModifierModelChange() return "models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl" end 
function modifier_imba_rain_of_chaos:GetEffectName() return "particles/hero/warlock/warlock_hands_of_goredan_ring.vpcf" end
function modifier_imba_rain_of_chaos:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rain_of_chaos:GetModifierPercentageCasttime() return 100 end
function modifier_imba_rain_of_chaos:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("as_bonus") end

function modifier_imba_rain_of_chaos:OnAttackStart(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		self:GetParent():EmitSound("Hero_WarlockGolem.PreAttack")
	end
end

function modifier_imba_rain_of_chaos:OnAttackLanded(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		keys.target:EmitSound("Hero_WarlockGolem.Attack")
	end
end

function modifier_imba_rain_of_chaos:OnCreated()
	if IsServer() then
		local caster = self:GetParent()
		local abilities = {"imba_warlock_liquid_hellfire", "imba_warlock_fire_of_sargeras", }
		for i=0, 1 do
			local ability = caster:AddAbility(abilities[i+1])
			ability:SetLevel(self:GetAbility():GetLevel())
			ability:ToggleAutoCast()
		end
		self:GetParent():StartGesture(ACT_DOTA_SPAWN)
		Timers:CreateTimer(FrameTime(), function()
				local pfx_hand = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_hellsworn_construct/golem_hellsworn_ambient_hands.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControlEnt(pfx_hand, 10, caster, PATTACH_POINT_FOLLOW, "attach_hand_l", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_hand, 11, caster, PATTACH_POINT_FOLLOW, "attach_hand_r", caster:GetAbsOrigin(), true)
				self:AddParticle(pfx_hand, false, false, 15, false, false)
				local pfx_smoke = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_hellsworn_construct/golem_hellsworn_ambient_mouth.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControlEnt(pfx_smoke, 12, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				self:AddParticle(pfx_smoke, false, false, 15, false, false)
				local pfx_mane = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_hellsworn_construct/golem_hellsworn_ambient_mane.vpcf", PATTACH_CUSTOMORIGIN, caster)
				for i=0, 7 do
					ParticleManager:SetParticleControlEnt(pfx_mane, i, caster, PATTACH_POINT_FOLLOW, "attach_mane"..(i+1), caster:GetAbsOrigin(), true)
				end
				self:AddParticle(pfx_mane, false, false, 15, false, false)
				return nil
			end
		)
	end
end

function modifier_imba_rain_of_chaos:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		local abilities = {"imba_warlock_liquid_hellfire", "imba_warlock_fire_of_sargeras", }
		for i=0, 1 do
			caster:RemoveAbility(abilities[i+1])
		end
		for i=1, 3 do
			CreateModifierThinker(caster, self:GetAbility(), "modifier_imba_rain_of_chaos_storm", {duration = (3.0 * i), aoe = self:GetAbility():GetSpecialValueFor("aoe_"..i), damage = self:GetAbility():GetSpecialValueFor("dmg_"..i)}, self:GetParent():GetAbsOrigin(), caster:GetTeamNumber(), false)
		end
	end
end

modifier_imba_rain_of_chaos_attack_range = class({})

function modifier_imba_rain_of_chaos_attack_range:IsDebuff()			return false end
function modifier_imba_rain_of_chaos_attack_range:IsHidden() 			return true end
function modifier_imba_rain_of_chaos_attack_range:IsPurgable() 			return false end
function modifier_imba_rain_of_chaos_attack_range:IsPurgeException() 	return false end
function modifier_imba_rain_of_chaos_attack_range:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_imba_rain_of_chaos_attack_range:GetModifierAttackRangeBonus() return (0 - self:GetStackCount()) end

function modifier_imba_rain_of_chaos_attack_range:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetParent():GetBaseAttackRange() - 150)
		self.attack_cap = self:GetParent():GetAttackCapability()
		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	end
end

function modifier_imba_rain_of_chaos_attack_range:OnDestroy()
	if IsServer() then
		self:GetParent():SetAttackCapability(self.attack_cap)
		self.attack_cap = nil
	end
end

modifier_imba_rain_of_chaos_storm = class({})

function modifier_imba_rain_of_chaos_storm:OnCreated(keys)
	if IsServer() then
		self.aoe = keys.aoe
		self.dmg = keys.damage
		local pfx = ParticleManager:CreateParticle("particles/hero/warlock/warlock_storm_aoe.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self.aoe, 1, 1))
		ParticleManager:SetParticleControl(pfx, 2, Vector(800, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_rain_of_chaos_storm:OnDestroy()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/hero/warlock/warlock_storm_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self.aoe, self.aoe, (self.aoe / 300)))
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("DOTA_Item.MeteorHammer.Impact")
		local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for i=1, #enemy do
			ApplyDamage({victim = enemy[i], attacker = self:GetCaster(), damage = self.dmg, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
		end
		self.aoe = nil
		self.dmg = nil
	end
end

imba_warlock_liquid_hellfire = class({})

LinkLuaModifier("modifier_imba_liquid_hellfire_autocast", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_liquid_hellfire_thinker", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)

function imba_warlock_liquid_hellfire:IsHiddenWhenStolen() 		return false end
function imba_warlock_liquid_hellfire:IsRefreshable() 			return true end
function imba_warlock_liquid_hellfire:IsStealable() 			return false end
function imba_warlock_liquid_hellfire:IsNetherWardStealable()	return false end
function imba_warlock_liquid_hellfire:GetCastRange() return self:GetSpecialValueFor("autocast_range") - self:GetCaster():GetCastRangeBonus() end
function imba_warlock_liquid_hellfire:GetIntrinsicModifierName() return "modifier_imba_liquid_hellfire_autocast" end

function imba_warlock_liquid_hellfire:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local pfx_fly = ParticleManager:CreateParticle("particles/hero/warlock/warlock_liquid_hellfire_fly.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx_fly, 0, caster:GetAbsOrigin() + Vector(0,0,1500))
	ParticleManager:SetParticleControl(pfx_fly, 1, pos)
	ParticleManager:SetParticleControl(pfx_fly, 2, Vector(0.3,0,0))
	ParticleManager:ReleaseParticleIndex(pfx_fly)
	Timers:CreateTimer(0.3, function()
			local buff = caster:FindModifierByName("modifier_imba_rain_of_chaos")
			if buff then
				local thinker = CreateModifierThinker(caster, self, "modifier_imba_liquid_hellfire_thinker", {duration = buff:GetRemainingTime()}, pos, caster:GetTeamNumber(), false)
				thinker:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for i=1, #enemies do
					ApplyDamage({victim = enemies[i], attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
				end
			end
			return nil
		end
	)
end

modifier_imba_liquid_hellfire_autocast = class({})

function modifier_imba_liquid_hellfire_autocast:IsDebuff()			return false end
function modifier_imba_liquid_hellfire_autocast:IsHidden() 			return true end
function modifier_imba_liquid_hellfire_autocast:IsPurgable() 		return false end
function modifier_imba_liquid_hellfire_autocast:IsPurgeException() 	return false end

function modifier_imba_liquid_hellfire_autocast:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_liquid_hellfire_autocast:OnIntervalThink()
	if not self:GetAbility():IsCooldownReady() then
		return
	end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("autocast_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_FARTHEST, false)
	local max_targets = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("lhf_num_scepter") or 1
	for i=1, max_targets do
		if enemies[i] and self:GetAbility():IsFullyCastable() then
			self:GetParent():SetCursorPosition(enemies[i]:GetAbsOrigin())
			self:GetAbility():OnSpellStart()
		end
	end
	if #enemies > 0 then
		self:GetAbility():UseResources(true, true, true)
	end
end

modifier_imba_liquid_hellfire_thinker = class({})

function modifier_imba_liquid_hellfire_thinker:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/hero/warlock/warlock_liquid_hellfire_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetDuration(), 0 ,0))
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 3, self:GetParent():GetAbsOrigin())
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_liquid_hellfire_thinker:OnIntervalThink()
	if not self:GetCaster():HasModifier("modifier_imba_rain_of_chaos") then
		self:Destroy()
	end
	local dmg = self:GetAbility():GetSpecialValueFor("damage_per_second") / (1.0 / 0.2)
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemies do
		ApplyDamage({victim = enemies[i], attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	end
end

imba_warlock_fire_of_sargeras = class({})

LinkLuaModifier("modifier_imba_fire_of_sargeras_passive", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fire_of_sargeras_debuff", "hero/hero_warlock", LUA_MODIFIER_MOTION_NONE)

function imba_warlock_fire_of_sargeras:GetIntrinsicModifierName() return "modifier_imba_fire_of_sargeras_passive" end

modifier_imba_fire_of_sargeras_passive = class({})

function modifier_imba_fire_of_sargeras_passive:IsDebuff()			return false end
function modifier_imba_fire_of_sargeras_passive:IsHidden() 			return true end
function modifier_imba_fire_of_sargeras_passive:IsPurgable() 		return false end
function modifier_imba_fire_of_sargeras_passive:IsPurgeException() 	return false end
function modifier_imba_fire_of_sargeras_passive:AllowIllusionDuplicate() return false end
function modifier_imba_fire_of_sargeras_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_fire_of_sargeras_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsMagicImmune() or keys.target:IsOther() or keys.target:IsCourier() or self:GetParent():IsIllusion() then
		return
	end
	if keys.target:IsBuilding() and keys.target:HasModifier("modifier_imba_fire_of_sargeras_debuff") then
		return
	end
	keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_fire_of_sargeras_debuff", {duration = self:GetAbility():GetSpecialValueFor("delay")})
end

modifier_imba_fire_of_sargeras_debuff = class({})

function modifier_imba_fire_of_sargeras_debuff:IsDebuff()			return true end
function modifier_imba_fire_of_sargeras_debuff:IsHidden() 			return false end
function modifier_imba_fire_of_sargeras_debuff:IsPurgable() 		return false end
function modifier_imba_fire_of_sargeras_debuff:IsPurgeException() 	return false end
function modifier_imba_fire_of_sargeras_debuff:RemoveOnDeath() return false end
function modifier_imba_fire_of_sargeras_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_fire_of_sargeras_debuff:DestroyOnExpire() return false end

function modifier_imba_fire_of_sargeras_debuff:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/dire_fx/fire_barracks.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("duration") / self:GetAbility():GetSpecialValueFor("interval") + 0)
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_fire_of_sargeras_debuff:OnIntervalThink()
	if not self:GetCaster():HasModifier("modifier_imba_rain_of_chaos") then
		self:Destroy()
	end
	if self:GetElapsedTime() >= self:GetDuration() then
		self:SetStackCount(self:GetStackCount() - 1)
		self:SetDuration(self:GetAbility():GetSpecialValueFor("interval"), true)		
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local damage_main = self:GetAbility():GetSpecialValueFor("main_damage")
		local damage_aoe = self:GetAbility():GetSpecialValueFor("aoe_damage")
		for i=1, #enemies do
			local dmg = damage_aoe
			if enemies[i] == self:GetParent() then
				dmg = damage_main
				if self:GetParent():IsBuilding() then
					dmg = dmg * (self:GetAbility():GetSpecialValueFor("building_pct") / 100)
				end
				ApplyDamage({victim = enemies[i], attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
				self:GetParent():EmitSound("Hero_Invoker.ChaosMeteor.Damage")
			else
				if not enemies[i]:IsBuilding() then
					ApplyDamage({victim = enemies[i], attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
				end
			end
		end
		local pfx = ParticleManager:CreateParticle("particles/hero/warlock/warlock_fire_of_sargeras_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

--particles/dire_fx/fire_barracks.vpcf