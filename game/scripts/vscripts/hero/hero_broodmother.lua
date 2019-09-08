CreateEmptyTalents("broodmother")

imba_broodmother_spider_strikes = class({})

LinkLuaModifier("modifier_imba_spider_strikes", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spider_strikes_caster", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spider_strikes_motion", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)

function imba_broodmother_spider_strikes:IsHiddenWhenStolen() 		return false end
function imba_broodmother_spider_strikes:IsRefreshable() 			return true end
function imba_broodmother_spider_strikes:IsStealable() 				return true end
function imba_broodmother_spider_strikes:IsNetherWardStealable()	return false end
function imba_broodmother_spider_strikes:GetCastRange()	return self:GetSpecialValueFor("cast_range") end

function imba_broodmother_spider_strikes:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:AddNewModifier(caster, self, "modifier_imba_spider_strikes_motion", {duration = self:GetSpecialValueFor("strike_duration"), target = target:entindex()})
	caster:EmitSound("Hero_Broodmother.SpawnSpiderlingsCast")
	--caster:EmitSound("Hero_Broodmother.SpawnSpiderlings")
end

modifier_imba_spider_strikes_motion = class({})

function modifier_imba_spider_strikes_motion:IsDebuff()			return false end
function modifier_imba_spider_strikes_motion:IsHidden() 		return true end
function modifier_imba_spider_strikes_motion:IsPurgable() 		return false end
function modifier_imba_spider_strikes_motion:IsPurgeException() return false end
function modifier_imba_spider_strikes_motion:CheckState() return {[MODIFIER_STATE_MAGIC_IMMUNE] = self:GetCaster():HasScepter()} end
function modifier_imba_spider_strikes_motion:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_SCALE} end
function modifier_imba_spider_strikes_motion:GetModifierModelScale() return self:GetParent():HasScepter() and (0 - self:GetAbility():GetSpecialValueFor("model_scale_scepter")) or 0 end
function modifier_imba_spider_strikes_motion:IsMotionController() return true end
function modifier_imba_spider_strikes_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_imba_spider_strikes_motion:OnCreated(keys)
	if IsServer() then
		if self:CheckMotionControllers() then
			self:GetAbility():SetActivated(false)
			self.target = EntIndexToHScript(keys.target)
			self:StartIntervalThink(FrameTime())
		end
	end
end

function modifier_imba_spider_strikes_motion:OnIntervalThink()
	local caster = self:GetParent()
	local target = self.target
	if not target:IsAlive() or caster:IsStunned() or caster:IsHexed() or self:GetRemainingTime() < 0 then
		self:Destroy()
		return
	end
	local dir = target:GetForwardVector()
	dir.z = 0
	local pos = target:GetAttachmentOrigin(target:ScriptLookupAttachment("attach_hitloc")) - dir * (100 * target:GetModelScale())
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0
	local length = (caster:GetAbsOrigin() - pos):Length2D()
	if length > 0 and self:GetRemainingTime() > 0 then
		length = length / (self:GetRemainingTime() / FrameTime())
		local next_pos = GetGroundPosition(caster:GetAbsOrigin(), nil)
		next_pos = next_pos + direction * length
		local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
		local height = 300
		next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
		caster:SetAbsOrigin(next_pos)
		caster:SetForwardVector(direction)
	end
end

function modifier_imba_spider_strikes_motion:OnDestroy()
	if IsServer() then
		self:GetAbility():SetActivated(true)
		local target = self.target
		local caster = self:GetParent()
		if self:GetElapsedTime() >= self:GetDuration() then
			local direction = target:GetForwardVector()
			direction.z = 0
			local pos = target:GetAttachmentOrigin(target:ScriptLookupAttachment("attach_hitloc")) - direction * (100 * target:GetModelScale())
			FindClearSpaceForUnit(caster, pos, true)
				if target:IsAlive() and not target:IsInvulnerable() and not target:IsMagicImmune() then
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_imba_spider_strikes_caster", {duration = self:GetAbility():GetSpecialValueFor("duration")})
				target:AddNewModifier(caster, self:GetAbility(), "modifier_imba_spider_strikes", {duration = self:GetAbility():GetSpecialValueFor("duration")})
				if target:HasModifier("modifier_imba_spin_web_debuff") and target:GetModifierStackCount("modifier_imba_spin_web_debuff", nil) ~= -1 then
					local buff = target:FindModifierByName("modifier_imba_spin_web_debuff")
					buff:SetStackCount(buff:GetStackCount() + self:GetAbility():GetSpecialValueFor("web_duration_bonus") * 10)
				end
			end
		else
			FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		end
		self.target = nil
	end
end

modifier_imba_spider_strikes_caster = class({})

function modifier_imba_spider_strikes_caster:IsDebuff()			return false end
function modifier_imba_spider_strikes_caster:IsHidden() 		return false end
function modifier_imba_spider_strikes_caster:IsPurgable() 		return false end
function modifier_imba_spider_strikes_caster:IsPurgeException() return false end
function modifier_imba_spider_strikes_caster:AllowIllusionDuplicate() return false end
function modifier_imba_spider_strikes_caster:CheckState() return {[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = self:GetCaster():HasScepter()} end
function modifier_imba_spider_strikes_caster:DeclareFunctions() return {MODIFIER_EVENT_ON_ORDER, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MODEL_SCALE} end
function modifier_imba_spider_strikes_caster:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("as_bonus") end
function modifier_imba_spider_strikes_caster:GetModifierModelScale() return self:GetParent():HasScepter() and (0 - self:GetAbility():GetSpecialValueFor("model_scale_scepter")) or 0 end

function modifier_imba_spider_strikes_caster:OnOrder(keys)
	if IsServer() and keys.unit == self:GetParent() then
		if keys.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or keys.order_type == DOTA_UNIT_ORDER_STOP then
			self:GetCaster():GetAttackTarget():RemoveModifierByName("modifier_imba_spider_strikes")
			self:Destroy()
		end
	end
end

function modifier_imba_spider_strikes_caster:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or not keys.target:IsAlive() or keys.target:IsOther() or keys.target:IsBuilding() then
		return
	end
	keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_bashed", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
	keys.target:EmitSound("DOTA_Item.MKB.Minibash")
end

function modifier_imba_spider_strikes_caster:OnCreated()
	if IsServer() then
		self:GetAbility():SetActivated(false)
		if self:GetCaster():HasScepter() then
			local pfx = ParticleManager:CreateParticle("particles/hero/broodmother/spider_strikes_magic_immune.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx, false, false, 15, false, false)
		end
	end
end

function modifier_imba_spider_strikes_caster:OnDestroy()
	if IsServer() then
		self:GetAbility():SetActivated(true)
	end
end

modifier_imba_spider_strikes = class({})

function modifier_imba_spider_strikes:IsDebuff()			return true end
function modifier_imba_spider_strikes:IsHidden() 			return false end
function modifier_imba_spider_strikes:IsPurgable() 			return true end
function modifier_imba_spider_strikes:IsPurgeException() 	return true end

function modifier_imba_spider_strikes:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
		self:GetCaster():PerformAttack(self:GetParent(), false, true, true, false, true, false, false)
	end
end

function modifier_imba_spider_strikes:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	caster:MoveToTargetToAttack(target)
	caster:SetAttacking(target)
	caster:SetForceAttackTarget(target)
	Timers:CreateTimer(FrameTime(), function()
			caster:SetForceAttackTarget(nil)
			return nil
		end
	)
	if not target:IsAlive() or not caster:IsAlive() or target:IsInvulnerable() or target:IsMagicImmune() then
		self:Destroy()
		return
	end
	local pos = target:GetAttachmentOrigin(target:ScriptLookupAttachment("attach_hitloc")) - target:GetForwardVector() * (100 * target:GetModelScale())
	local direction = target:GetForwardVector()
	direction.z = 0
	caster:SetOrigin(pos)
	caster:SetForwardVector(direction)
end

function modifier_imba_spider_strikes:OnDestroy()
	if IsServer() then
		local direction = self:GetParent():GetForwardVector():Normalized()
		direction.z = 0
		self:GetCaster():SetForwardVector(direction)
		self:GetCaster():RemoveModifierByName("modifier_imba_spider_strikes_caster")
	end
end

imba_broodmother_spin_web = class({})

LinkLuaModifier("modifier_imba_spin_web_caster_aura", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spin_web_buff", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spin_web_enemy_aura", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spin_web_debuff", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spin_web_scepter", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)

function imba_broodmother_spin_web:IsHiddenWhenStolen() 	return false end
function imba_broodmother_spin_web:IsRefreshable() 			return true end
function imba_broodmother_spin_web:IsStealable() 			return true end
function imba_broodmother_spin_web:IsNetherWardStealable()	return false end
function imba_broodmother_spin_web:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_broodmother_spin_web:GetCooldown(iLevel) return self:GetSpecialValueFor("charge_restore_time") end
function imba_broodmother_spin_web:OnUpgrade() AbilityChargeController:AbilityChargeInitialize(self, self:GetSpecialValueFor("charge_restore_time"), self:GetSpecialValueFor("max_charges"), 1, true, true) end
function imba_broodmother_spin_web:GetIntrinsicModifierName() return "modifier_imba_spin_web_scepter" end

function imba_broodmother_spin_web:GetCastRange(pos, target)
	if not self.range then
		self.range = 0
	end
	if IsClient() then
		return self.BaseClass.GetCastRange(self, pos, target)
	else
		return self.BaseClass.GetCastRange(self, pos, target) + self.range
	end
end

function imba_broodmother_spin_web:OnSpellStart()
	if not self.webs then
		self.webs = {}
	end
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local found = false
	local web = CreateUnitByName("npc_dota_broodmother_web", pos, true, caster, caster, caster:GetTeamNumber())
	web:FindAbilityByName("broodmother_spin_web_destroy"):SetLevel(1)
	web:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	web:AddNewModifier(caster, nil, "modifier_invulnerable", {})
	web:AddNewModifier(caster, nil, "modifier_magicimmune", {})
	web:AddNewModifier(caster, self, "modifier_imba_spin_web_enemy_aura", {})
	web:EmitSound("Hero_Broodmother.SpinWebCast")
	for i=1, self:GetSpecialValueFor("count") do
		if not self.webs[i] then
			self.webs[i] = web
			web:AddNewModifier(caster, self, "modifier_imba_spin_web_caster_aura", {}):SetStackCount(i)
			found = true
			break
		end
	end
	if not found then
		local eldest = 0
		local time = 100000000
		for i=1, self:GetSpecialValueFor("count") do
			if self.webs[i] and self.webs[i]:GetCreationTime() < time then
				eldest = i
				time = self.webs[i]:GetCreationTime()
			end
		end
		self.webs[eldest]:FindAbilityByName("broodmother_spin_web_destroy"):OnSpellStart()
		self.webs[eldest] = web
		web:AddNewModifier(caster, self, "modifier_imba_spin_web_caster_aura", {}):SetStackCount(eldest)
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spin_web_cast.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, pos)
	ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_imba_spin_web_scepter = class({})

function modifier_imba_spin_web_scepter:IsDebuff()			return false end
function modifier_imba_spin_web_scepter:IsHidden() 			return true end
function modifier_imba_spin_web_scepter:IsPurgable() 		return false end
function modifier_imba_spin_web_scepter:IsPurgeException() 	return false end

function modifier_imba_spin_web_scepter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_spin_web_scepter:OnIntervalThink()
	if self:GetParent():HasScepter() then
		AbilityChargeController:ChangeChargeAbilityConfig(self:GetAbility(), nil, self:GetAbility():GetSpecialValueFor("max_charges_scepter"), nil, nil, nil)
	else
		AbilityChargeController:ChangeChargeAbilityConfig(self:GetAbility(), nil, self:GetAbility():GetSpecialValueFor("max_charges"), nil, nil, nil)
	end
end

modifier_imba_spin_web_caster_aura = class({})

function modifier_imba_spin_web_caster_aura:IsDebuff()			return false end
function modifier_imba_spin_web_caster_aura:IsHidden() 			return true end
function modifier_imba_spin_web_caster_aura:IsPurgable() 		return false end
function modifier_imba_spin_web_caster_aura:IsPurgeException() 	return false end

function modifier_imba_spin_web_caster_aura:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		ability.webs[self:GetStackCount()] = nil
	end
end

function modifier_imba_spin_web_caster_aura:IsAura() return true end
function modifier_imba_spin_web_caster_aura:GetAuraDuration() return 0.1 end
function modifier_imba_spin_web_caster_aura:GetModifierAura() return "modifier_imba_spin_web_buff" end
function modifier_imba_spin_web_caster_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_spin_web_caster_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_spin_web_caster_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_spin_web_caster_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_spin_web_caster_aura:GetAuraEntityReject(unit) return unit ~= self:GetCaster() end

function modifier_imba_spin_web_caster_aura:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_spin_web_caster_aura:OnIntervalThink()
	if self:GetCaster():HasModifier("modifier_imba_insatiable_hunger") then
		local ability = self:GetCaster():FindModifierByName("modifier_imba_insatiable_hunger"):GetAbility()
		if (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= ability:GetSpecialValueFor("web_radius") then
			AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("radius"), 0.2, false)
		end
	end
end

modifier_imba_spin_web_buff = class({})

function modifier_imba_spin_web_buff:IsDebuff()			return false end
function modifier_imba_spin_web_buff:IsHidden() 		return false end
function modifier_imba_spin_web_buff:IsPurgable() 		return false end
function modifier_imba_spin_web_buff:IsPurgeException() return false end
function modifier_imba_spin_web_buff:CheckState()
	if (0 - self:GetStackCount() / 10) >= self:GetAbility():GetSpecialValueFor("fade_time") then
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_INVISIBLE] = true}
	else
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
end
function modifier_imba_spin_web_buff:DeclareFunctions() return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_spin_web_buff:GetModifierInvisibilityLevel()
	if (0 - self:GetStackCount() / 10) >= self:GetAbility():GetSpecialValueFor("fade_time") then
		return 1
	else
		return 0
	end
end
function modifier_imba_spin_web_buff:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("heath_regen") end
function modifier_imba_spin_web_buff:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("bonus_movespeed") end
function modifier_imba_spin_web_buff:GetActivityTranslationModifiers() return "web" end

function modifier_imba_spin_web_buff:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() then
		self:SetStackCount(0)
	end
end

function modifier_imba_spin_web_buff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_spin_web_buff:OnIntervalThink()
	self:SetStackCount(math.max(self:GetStackCount() - 1, 0 - self:GetAbility():GetSpecialValueFor("fade_time") * 10))
	AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), 0.1, false)
end

function modifier_imba_spin_web_buff:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 200, false)
	end
end

modifier_imba_spin_web_enemy_aura = class({})

function modifier_imba_spin_web_enemy_aura:IsDebuff()			return false end
function modifier_imba_spin_web_enemy_aura:IsHidden() 			return true end
function modifier_imba_spin_web_enemy_aura:IsPurgable() 		return false end
function modifier_imba_spin_web_enemy_aura:IsPurgeException() 	return false end
function modifier_imba_spin_web_enemy_aura:IsAura() return true end
function modifier_imba_spin_web_enemy_aura:GetAuraDuration() return 0.1 end
function modifier_imba_spin_web_enemy_aura:GetModifierAura() return "modifier_imba_spin_web_debuff" end
function modifier_imba_spin_web_enemy_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_spin_web_enemy_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_spin_web_enemy_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_spin_web_enemy_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_spin_web_debuff = class({})

function modifier_imba_spin_web_debuff:IsDebuff()			return true end
function modifier_imba_spin_web_debuff:IsHidden() 			return false end
function modifier_imba_spin_web_debuff:IsPurgable() 		return false end
function modifier_imba_spin_web_debuff:IsPurgeException() 	return false end
function modifier_imba_spin_web_debuff:GetEffectName() return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf" end
function modifier_imba_spin_web_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_spin_web_debuff:CheckState()
	if self:GetStackCount() == -1 then
		return {[MODIFIER_STATE_ROOTED] = true}
	end
end

function modifier_imba_spin_web_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_spin_web_debuff:OnIntervalThink()
	if self:GetStackCount() == -1 then
		self:Destroy()
		return
	end
	self:SetStackCount(self:GetStackCount() + 1)
	if self:GetStackCount() / 10 >= self:GetAbility():GetSpecialValueFor("root_delay") then
		self:SetStackCount(-1)
		AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 200, self:GetAbility():GetSpecialValueFor("root_duration"), false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("root_duration"))
	end
end

broodmother_spin_web_destroy = class({})

function broodmother_spin_web_destroy:IsHiddenWhenStolen() 		return false end
function broodmother_spin_web_destroy:IsRefreshable() 			return false end
function broodmother_spin_web_destroy:IsStealable() 			return false end
function broodmother_spin_web_destroy:IsNetherWardStealable()	return false end
function broodmother_spin_web_destroy:OnSpellStart()
	local caster = self:GetCaster()
	for k, v in pairs(caster:FindAllModifiers()) do
		v:Destroy()
	end
	caster:ForceKill(false)
	Timers:CreateTimer(FrameTime(), function()
			if not caster:IsNull() then
				caster:RemoveSelf()
			end
			return nil
		end
	)
end

imba_broodmother_incapacitating_bite = class({})

LinkLuaModifier("modifier_imba_incapacitating_bite", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_incapacitating_bite_buff", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_incapacitating_bite_debuff", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)

function imba_broodmother_incapacitating_bite:GetIntrinsicModifierName() return "modifier_imba_incapacitating_bite" end

modifier_imba_incapacitating_bite = class({})

function modifier_imba_incapacitating_bite:IsDebuff()			return false end
function modifier_imba_incapacitating_bite:IsHidden() 			return true end
function modifier_imba_incapacitating_bite:IsPurgable() 		return false end
function modifier_imba_incapacitating_bite:IsPurgeException() 	return false end
function modifier_imba_incapacitating_bite:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_incapacitating_bite:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or not keys.target:IsAlive() or keys.target:IsOther() or keys.target:IsBuilding() or self:GetParent():IsIllusion() then
		return
	end
	local caster = self:GetCaster()
	local target = keys.target
	local ability = self:GetAbility()
	if target:IsRooted() then
		caster:AddNewModifier(caster, ability, "modifier_imba_incapacitating_bite_buff", {})
	else
		caster:RemoveModifierByName("modifier_imba_incapacitating_bite_buff")
	end
end

function modifier_imba_incapacitating_bite:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or not keys.target:IsAlive() or keys.target:IsOther() or keys.target:IsBuilding() or self:GetParent():IsIllusion() or keys.target:IsMagicImmune() or self:GetParent():PassivesDisabled() then
		return
	end
	local caster = self:GetCaster()
	local target = keys.target
	local ability = self:GetAbility()
	if target:HasModifier("modifier_imba_spin_web_debuff") and target:GetModifierStackCount("modifier_imba_spin_web_debuff", nil) ~= -1 then
		local buff = target:FindModifierByName("modifier_imba_spin_web_debuff")
		local duration = caster:HasModifier("modifier_imba_insatiable_hunger") and (self:GetAbility():GetSpecialValueFor("web_duration_bonus") + 1.0) * 10 or self:GetAbility():GetSpecialValueFor("web_duration_bonus") * 10
		buff:SetStackCount(buff:GetStackCount() + duration)
	end
	target:AddNewModifier(caster, ability, "modifier_imba_incapacitating_bite_debuff", {duration = ability:GetSpecialValueFor("duration")})
end

modifier_imba_incapacitating_bite_buff = class({})

function modifier_imba_incapacitating_bite_buff:IsDebuff()			return false end
function modifier_imba_incapacitating_bite_buff:IsHidden() 			return false end
function modifier_imba_incapacitating_bite_buff:IsPurgable() 		return false end
function modifier_imba_incapacitating_bite_buff:IsPurgeException() 	return false end
function modifier_imba_incapacitating_bite_buff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_incapacitating_bite_buff:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("rooted_as_bonus") end
function modifier_imba_incapacitating_bite_buff:GetStatusEffectName() return "particles/status_fx/status_effect_life_stealer_rage.vpcf" end
function modifier_imba_incapacitating_bite_buff:StatusEffectPriority() return 15 end

function modifier_imba_incapacitating_bite_buff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_incapacitating_bite_buff:OnIntervalThink()
	if not self:GetParent():IsAttacking() then
		self:Destroy()
	end
end

modifier_imba_incapacitating_bite_debuff = class({})

function modifier_imba_incapacitating_bite_debuff:IsDebuff()			return true end
function modifier_imba_incapacitating_bite_debuff:IsHidden() 			return false end
function modifier_imba_incapacitating_bite_debuff:IsPurgable() 			return true end
function modifier_imba_incapacitating_bite_debuff:IsPurgeException() 	return true end
function modifier_imba_incapacitating_bite_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MISS_PERCENTAGE} end
function modifier_imba_incapacitating_bite_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("movespeed_slow")) end
function modifier_imba_incapacitating_bite_debuff:GetModifierMiss_Percentage() return self:GetAbility():GetSpecialValueFor("miss_chance") end

function modifier_imba_incapacitating_bite_debuff:OnCreated()
	if IsServer() then
		local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_poison_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx1, false, false, 15, false, false)
		self:AddParticle(pfx2, false, false, 15, false, false)
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_incapacitating_bite_debuff:OnIntervalThink()
	local dmg = ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("damage_per_second"), damage_type = self:GetAbility():GetAbilityDamageType()})
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self:GetParent(), dmg, nil)
end

imba_broodmother_insatiable_hunger = class({})

LinkLuaModifier("modifier_imba_insatiable_hunger", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_insatiable_hunger_truesight", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)

function imba_broodmother_insatiable_hunger:IsHiddenWhenStolen() 	return false end
function imba_broodmother_insatiable_hunger:IsRefreshable() 		return true end
function imba_broodmother_insatiable_hunger:IsStealable() 			return true end
function imba_broodmother_insatiable_hunger:IsNetherWardStealable()	return true end

function imba_broodmother_insatiable_hunger:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_imba_insatiable_hunger", {duration = self:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_imba_broodmother_2")})
end

modifier_imba_insatiable_hunger = class({})

function modifier_imba_insatiable_hunger:IsDebuff()			return false end
function modifier_imba_insatiable_hunger:IsHidden() 		return false end
function modifier_imba_insatiable_hunger:IsPurgable() 		return false end
function modifier_imba_insatiable_hunger:IsPurgeException() return false end
function modifier_imba_insatiable_hunger:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_HERO_KILLED} end
function modifier_imba_insatiable_hunger:GetModifierPreAttack_BonusDamage() return self.dmg end

function modifier_imba_insatiable_hunger:OnCreated()
	EmitSoundOn("Hero_Broodmother.InsatiableHunger", self:GetParent())
	self.dmg = (self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():GetTalentValue("special_bonus_imba_broodmother_1"))
	self.lifesteal = (self:GetAbility():GetSpecialValueFor("lifesteal_pct") + self:GetCaster():GetTalentValue("special_bonus_imba_broodmother_1"))
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, (self:GetParent():IsHero() and "attach_thorax" or "attach_hitloc"), self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_insatiable_hunger:OnDestroy()
	StopSoundOn("Hero_Broodmother.InsatiableHunger", self:GetParent())
	self.dmg = nil
	self.lifesteal = nil
end

function modifier_imba_insatiable_hunger:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and (keys.target:IsHero() or keys.target:IsCreep() or keys.target:IsBoss()) then
		local lifesteal = self.lifesteal
		self:GetParent():Heal(lifesteal, self:GetAbility())
	end
end

function modifier_imba_insatiable_hunger:OnHeroKilled(keys)
	if not IsServer() then
		return
	end
	if keys.target == self:GetParent() then
		self:Destroy()
	end
	if keys.target:IsTrueHero() and (self:GetParent():GetAbsOrigin() - keys.target:GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("strike_refresh_radius") then
		if self:GetParent():HasAbility("imba_broodmother_spider_strikes") then
			self:GetParent():FindAbilityByName('imba_broodmother_spider_strikes'):EndCooldown()
		end
	end
end

function modifier_imba_insatiable_hunger:IsAura() return true end
function modifier_imba_insatiable_hunger:GetAuraDuration() return 0.1 end
function modifier_imba_insatiable_hunger:GetModifierAura() return "modifier_imba_insatiable_hunger_truesight" end
function modifier_imba_insatiable_hunger:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("truesight_radius") end
function modifier_imba_insatiable_hunger:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_insatiable_hunger:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_insatiable_hunger:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_insatiable_hunger_truesight = class({})

function modifier_imba_insatiable_hunger_truesight:IsDebuff()			return true end
function modifier_imba_insatiable_hunger_truesight:IsHidden() 			return true end
function modifier_imba_insatiable_hunger_truesight:IsPurgable() 		return false end
function modifier_imba_insatiable_hunger_truesight:IsPurgeException() 	return false end
function modifier_imba_insatiable_hunger_truesight:CheckState() return {[MODIFIER_STATE_INVISIBLE] = false} end
function modifier_imba_insatiable_hunger_truesight:GetPriority() return MODIFIER_PRIORITY_HIGH end