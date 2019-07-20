CreateEmptyTalents("templar_assassin")

imba_templar_assassin_meld = class({})

LinkLuaModifier("modifier_imba_meld_caster", "hero/hero_templar_assassin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_meld_attack", "hero/hero_templar_assassin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_meld_armor_debuff", "hero/hero_templar_assassin.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_meld_vision_debuff", "hero/hero_templar_assassin.lua", LUA_MODIFIER_MOTION_NONE)

function imba_templar_assassin_meld:IsHiddenWhenStolen() 	return false end
function imba_templar_assassin_meld:IsRefreshable() 		return true end
function imba_templar_assassin_meld:IsStealable() 			return true end
function imba_templar_assassin_meld:IsNetherWardStealable()	return false end

function imba_templar_assassin_meld:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_TemplarAssassin.Meld")
	caster:AddNewModifier(caster, self, "modifier_imba_meld_caster", {})
	if caster:HasTalent("special_bonus_imba_templar_assassin_2") then
		caster:Purge(false, true, false, false, false)
	end
end

modifier_imba_meld_caster = class({})

function modifier_imba_meld_caster:IsDebuff()			return false end
function modifier_imba_meld_caster:IsHidden() 			return false end
function modifier_imba_meld_caster:IsPurgable() 		return false end
function modifier_imba_meld_caster:IsPurgeException() 	return false end
function modifier_imba_meld_caster:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_imba_meld_caster:DeclareFunctions() return {MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_EVENT_ON_UNIT_MOVED, MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_imba_meld_caster:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true} end
function modifier_imba_meld_caster:GetModifierInvisibilityLevel() return 1 end
function modifier_imba_meld_caster:GetActivityTranslationModifiers() return "meld" end
function modifier_imba_meld_caster:GetModifierProjectileName() return "particles/units/heroes/hero_templar_assassin/templar_assassin_meld_attack.vpcf" end
function modifier_imba_meld_caster:GetEffectName() return "particles/units/heroes/hero_templar_assassin/templar_assassin_meld.vpcf" end
function modifier_imba_meld_caster:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_meld_caster:OnCreated()
	if IsServer() and HeroItems:UnitHasItem(self:GetCaster(), "psi_blades_immortal") then
		local pfx = ParticleManager:CreateParticle("particles/econ/items/templar_assassin/templar_assassin_focal/templar_assassin_meld_focal_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function modifier_imba_meld_caster:OnUnitMoved(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then
		return
	end
	self:GetParent():EmitSound("Hero_TemplarAssassin.Meld.Move")
	self:Destroy()
end

function modifier_imba_meld_caster:OnAttack(keys)
	if not IsServer() or keys.attacker ~= self:GetParent() then
		return
	end
	if keys.target:IsUnit() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_meld_attack", {duration = 20.0, record = keys.record})
	end
	self:Destroy()
end

modifier_imba_meld_attack = class({})

function modifier_imba_meld_attack:IsDebuff()			return false end
function modifier_imba_meld_attack:IsHidden() 			return true end
function modifier_imba_meld_attack:IsPurgable() 		return false end
function modifier_imba_meld_attack:IsPurgeException() 	return false end
function modifier_imba_meld_attack:RemoveOnDeath()		return false end
function modifier_imba_meld_attack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_meld_attack:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_meld_attack:OnCreated(keys)
	if IsServer() then
		self.record = keys.record
	end
end

function modifier_imba_meld_attack:OnAttackLanded(keys)
	if IsServer() and keys.record == self.record then
		local target = keys.target
		target:EmitSound("Hero_TemplarAssassin.Meld.Attack")
		local dmg = ApplyDamage({victim = target, attacker = self:GetParent(), ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType(), damage = self:GetAbility():GetSpecialValueFor("bonus_damage"), damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, dmg, nil)
		target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_meld_armor_debuff", {duration = self:GetAbility():GetSpecialValueFor("armor_duration")})
		target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_meld_vision_debuff", {duration = self:GetAbility():GetSpecialValueFor("vision_duration")})
		if self:GetCaster():HasTalent("special_bonus_imba_templar_assassin_1") then
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_bashed", {duration = self:GetCaster():GetTalentValue("special_bonus_imba_templar_assassin_1")})
		end
		self:Destroy()
	end
end

function modifier_imba_meld_attack:OnDestroy() self.record = nil end

modifier_imba_meld_armor_debuff = class({})

function modifier_imba_meld_armor_debuff:IsDebuff()				return true end
function modifier_imba_meld_armor_debuff:IsHidden() 			return false end
function modifier_imba_meld_armor_debuff:IsPurgable() 			return false end
function modifier_imba_meld_armor_debuff:IsPurgeException() 	return false end
function modifier_imba_meld_armor_debuff:GetEffectName() return "particles/units/heroes/hero_templar_assassin/templar_meld_overhead.vpcf" end
function modifier_imba_meld_armor_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_meld_armor_debuff:ShouldUseOverheadOffset() return true end
function modifier_imba_meld_armor_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_meld_armor_debuff:GetModifierPhysicalArmorBonus() return (0 - self:GetAbility():GetSpecialValueFor("armor_reduction")) end

function modifier_imba_meld_armor_debuff:OnCreated()
	if IsServer() and HeroItems:UnitHasItem(self:GetCaster(), "psi_blades_immortal") then
		--[[local pfx = ParticleManager:CreateParticle("particles/econ/items/templar_assassin/templar_assassin_focal/templar_meld_focal_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)]]
	end
end

modifier_imba_meld_vision_debuff = class({})

function modifier_imba_meld_vision_debuff:IsDebuff()			return true end
function modifier_imba_meld_vision_debuff:IsHidden() 			return false end
function modifier_imba_meld_vision_debuff:IsPurgable() 			return false end
function modifier_imba_meld_vision_debuff:IsPurgeException() 	return false end
function modifier_imba_meld_vision_debuff:GetEffectName() return "particles/units/heroes/hero_templar_assassin/templar_assassin_meld_armor.vpcf" end
function modifier_imba_meld_vision_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_meld_vision_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE, MODIFIER_PROPERTY_DONT_GIVE_VISION_OF_ATTACKER} end
function modifier_imba_meld_vision_debuff:GetModifierNoVisionOfAttacker() return 1 end
function modifier_imba_meld_vision_debuff:GetBonusVisionPercentage() return (0 - self:GetAbility():GetSpecialValueFor("vision_pct")) end

imba_templar_assassin_psionic_trap = class({})

LinkLuaModifier("modifier_imba_psionic_trap_counter", "hero/hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_psionic_trap_timer", "hero/hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_psionic_trap_slow", "hero/hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_templar_assassin_psionic_trap:IsHiddenWhenStolen() 		return false end
function imba_templar_assassin_psionic_trap:IsRefreshable() 			return true end
function imba_templar_assassin_psionic_trap:IsStealable() 				return true end
function imba_templar_assassin_psionic_trap:IsNetherWardStealable()		return false end
function imba_templar_assassin_psionic_trap:GetAssociatedSecondaryAbilities() return "imba_templar_assassin_trap" end
function imba_templar_assassin_psionic_trap:GetAOERadius() return self:GetSpecialValueFor("aoe_radius") end
function imba_templar_assassin_psionic_trap:GetIntrinsicModifierName() return "modifier_imba_psionic_trap_counter" end

function imba_templar_assassin_psionic_trap:CastFilterResultLocation(loc)
	if self:GetCaster():GetModifierStackCount("modifier_imba_psionic_trap_counter", nil) >= self:GetSpecialValueFor("max_traps") then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function imba_templar_assassin_psionic_trap:GetCustomCastErrorLocation(loc)
	if self:GetCaster():GetModifierStackCount("modifier_imba_psionic_trap_counter", nil) >= self:GetSpecialValueFor("max_traps") then
		return "#IMBA_HUD_ERROR_PSI_TRAP_MAX"
	end
end

function imba_templar_assassin_psionic_trap:OnUpgrade()
	self:GetCaster():FindAbilityByName("imba_templar_assassin_trap"):SetLevel(self:GetLevel())
end

function imba_templar_assassin_psionic_trap:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local trap = CreateUnitByName("npc_dota_templar_assassin_psionic_trap", pos, false, caster, caster, caster:GetTeamNumber())
	caster:EmitSound("Hero_TemplarAssassin.Trap.Cast")
	trap:EmitSound("Hero_TemplarAssassin.Trap")
	trap:EmitSound("Hero_TemplarAssassin.Trap.Trigger")
	trap:SetControllableByPlayer(caster:GetPlayerID(), true)
	trap:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("trap_duration")})
	trap:AddNewModifier(caster, self, "modifier_imba_psionic_trap_timer", {})
	trap:FindAbilityByName("imba_templar_assassin_trap"):SetLevel(self:GetLevel())
	caster:FindModifierByName("modifier_imba_psionic_trap_counter"):SetStackCount(caster:FindModifierByName("modifier_imba_psionic_trap_counter"):GetStackCount() + 1)
end

imba_templar_assassin_trap = class({})

function imba_templar_assassin_trap:IsHiddenWhenStolen() 		return false end
function imba_templar_assassin_trap:IsRefreshable() 			return true end
function imba_templar_assassin_trap:IsStealable() 				return false end
function imba_templar_assassin_trap:IsNetherWardStealable()		return false end
function imba_templar_assassin_trap:GetAssociatedPrimaryAbilities() return "imba_templar_assassin_psionic_trap" end

function imba_templar_assassin_trap:OnSpellStart()
	local pos = self:GetCaster():GetAbsOrigin()
	local traps = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), pos, nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for _, trap in pairs(traps) do
		if trap:GetUnitName() == "npc_dota_templar_assassin_psionic_trap" and trap:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
			trap:ForceKill(false)
			break
		end
	end
end

modifier_imba_psionic_trap_counter = class({})

function modifier_imba_psionic_trap_counter:IsDebuff()			return false end
function modifier_imba_psionic_trap_counter:IsHidden() 			return false end
function modifier_imba_psionic_trap_counter:IsPurgable() 		return false end
function modifier_imba_psionic_trap_counter:IsPurgeException() 	return false end
function modifier_imba_psionic_trap_counter:RemoveOnDeath() return self:GetParent():IsIllusion() end

modifier_imba_psionic_trap_timer = class({})

function modifier_imba_psionic_trap_timer:IsDebuff()			return false end
function modifier_imba_psionic_trap_timer:IsHidden() 			return true end
function modifier_imba_psionic_trap_timer:IsPurgable() 			return false end
function modifier_imba_psionic_trap_timer:IsPurgeException() 	return false end
function modifier_imba_psionic_trap_timer:GetEffectName() return "particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf" end
function modifier_imba_psionic_trap_timer:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_psionic_trap_timer:CheckState()
	if self:GetElapsedTime() >= self:GetAbility():GetSpecialValueFor("trap_fade_time") then
		return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true}
	end
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true}
end

function modifier_imba_psionic_trap_timer:OnDestroy()
	if IsServer() then
		self:GetCaster():FindModifierByName("modifier_imba_psionic_trap_counter"):SetStackCount(self:GetCaster():FindModifierByName("modifier_imba_psionic_trap_counter"):GetStackCount() - 1)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_TemplarAssassin.Trap.Explode")
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("aoe_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		local illu = true
		for _, enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("trap_bonus_damage"), ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_psionic_trap_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
			if enemy:IsHero() and illu then
				local illusion = IllusionManager:CreateIllusion(self:GetCaster(), self:GetParent():GetAbsOrigin(), (enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized(), self:GetAbility():GetSpecialValueFor("illusion_dmg_out"), self:GetAbility():GetSpecialValueFor("illusion_dmg_in"), 0, math.min(self:GetElapsedTime(), self:GetAbility():GetSpecialValueFor("trap_max_charge_duration")), self:GetCaster(), nil)
				illusion:SetForceAttackTarget(enemy)
				illu = false
			end
		end
	end
end

modifier_imba_psionic_trap_slow = class({})

function modifier_imba_psionic_trap_slow:IsDebuff()			return true end
function modifier_imba_psionic_trap_slow:IsHidden() 		return false end
function modifier_imba_psionic_trap_slow:IsPurgable() 		return true end
function modifier_imba_psionic_trap_slow:IsPurgeException() return true end
function modifier_imba_psionic_trap_slow:GetStatusEffectName() return "particles/status_fx/status_effect_templar_slow.vpcf" end
function modifier_imba_psionic_trap_slow:StatusEffectPriority() return 15 end
function modifier_imba_psionic_trap_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_psionic_trap_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("ms_slow")) end

imba_templar_assassin_psionic_projection = class({})

LinkLuaModifier("modifier_imba_psionic_projection_layout", "hero/hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_psionic_projection_model", "hero/hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_psionic_projection_attack", "hero/hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_templar_assassin_psionic_projection:IsHiddenWhenStolen() 		return false end
function imba_templar_assassin_psionic_projection:IsRefreshable() 			return true end
function imba_templar_assassin_psionic_projection:IsStealable() 			return false end
function imba_templar_assassin_psionic_projection:IsNetherWardStealable()	return false end
function imba_templar_assassin_psionic_projection:IsTalentAbility() 		return true end
function imba_templar_assassin_psionic_projection:GetIntrinsicModifierName() return "modifier_imba_psionic_projection_layout" end
function imba_templar_assassin_psionic_projection:GetBehavior() return self:GetCaster():GetModifierStackCount("modifier_imba_psionic_trap_counter", nil) <= 0 and (DOTA_ABILITY_BEHAVIOR_NO_TARGET) or self.BaseClass.GetBehavior(self) end

function imba_templar_assassin_psionic_projection:CastFilterResult(loc)
	if self:GetCaster():GetModifierStackCount("modifier_imba_psionic_trap_counter", nil) <= 0 then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function imba_templar_assassin_psionic_projection:GetCustomCastError(loc)
	if self:GetCaster():GetModifierStackCount("modifier_imba_psionic_trap_counter", nil) <= 0 then
		return "#IMBA_HUD_ERROR_NO_PSI_TRAP"
	end
end

function imba_templar_assassin_psionic_projection:OnSpellStart()
	self.pos = self:GetCursorPosition()
	self.thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_imba_psionic_projection_model", {duration = 2.0}, self.pos, self:GetCaster():GetTeamNumber(), false)
	local ability = self:GetCaster():FindAbilityByName("imba_templar_assassin_meld")
	if ability and ability:GetLevel() > 0 then
		ability:OnSpellStart()
	end
end

function imba_templar_assassin_psionic_projection:OnChannelThink(flInterval)
	local pos = self.pos
	local traps = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), pos, nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for _, trap in pairs(traps) do
		if trap:GetUnitName() == "npc_dota_templar_assassin_psionic_trap" and trap:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
			if self.thinker and not self.thinker:IsNull() then
				self.thinker:SetOrigin(trap:GetAbsOrigin())
			end
			return
		end
	end
	self:GetCaster():InterruptChannel()
end

function imba_templar_assassin_psionic_projection:OnChannelFinish(bInterrupted)
	if self.thinker and not self.thinker:IsNull() then
		self.thinker:ForceKill(false)
	end
	if bInterrupted then
		return
	end
	local pos = self.pos
	local traps = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), pos, nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for _, trap in pairs(traps) do
		if trap:GetUnitName() == "npc_dota_templar_assassin_psionic_trap" and trap:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
			FindClearSpaceForUnit(self:GetCaster(), trap:GetAbsOrigin(), true)
			self.trap = trap
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_psionic_projection_attack", {})
			return
		end
	end
end

modifier_imba_psionic_projection_layout = class({})

function modifier_imba_psionic_projection_layout:IsDebuff()			return false end
function modifier_imba_psionic_projection_layout:IsHidden() 		return true end
function modifier_imba_psionic_projection_layout:IsPurgable() 		return false end
function modifier_imba_psionic_projection_layout:IsPurgeException() return false end

function modifier_imba_psionic_projection_layout:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_psionic_projection_layout:OnIntervalThink() self:GetAbility():SetHidden(not self:GetCaster():HasScepter()) end

modifier_imba_psionic_projection_model = class({})

function modifier_imba_psionic_projection_model:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticleForTeam("particles/hero/templar_assassin/teleport_image.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 4, Vector(1.0, 0, 0))
		ParticleManager:SetParticleControlEnt(pfx, 5, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_imba_psionic_projection_attack = class({})

function modifier_imba_psionic_projection_attack:IsDebuff()			return false end
function modifier_imba_psionic_projection_attack:IsHidden() 		return true end
function modifier_imba_psionic_projection_attack:IsPurgable() 		return false end
function modifier_imba_psionic_projection_attack:IsPurgeException() return false end

function modifier_imba_psionic_projection_attack:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_psionic_projection_attack:OnIntervalThink()
	if not self:GetParent():IsInvisible() then
		self:Destroy()
	end
end

function modifier_imba_psionic_projection_attack:OnDestroy()
	if IsServer() then
		local trap = self:GetAbility().trap
		if trap and not trap:IsNull() then
			trap:ForceKill(false)
		end
	end
end