CreateEmptyTalents("templar_assassin")

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
	local ability = self:GetCaster():FindAbilityByName("templar_assassin_meld")
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
				self.thinker:SetAbsOrigin(trap:GetAbsOrigin())
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