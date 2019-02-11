

CreateEmptyTalents("pudge")


imba_pudge_sharp_hook = class({})

LinkLuaModifier("modifier_imba_hook_sharp_stack", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)

function imba_pudge_sharp_hook:IsHiddenWhenStolen() 	return false end
function imba_pudge_sharp_hook:IsRefreshable() 			return true end
function imba_pudge_sharp_hook:IsStealable() 			return false end
function imba_pudge_sharp_hook:IsNetherWardStealable()	return false end
function imba_pudge_sharp_hook:GetIntrinsicModifierName() return "modifier_imba_hook_sharp_stack" end
function imba_pudge_sharp_hook:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():FindModifierByName("modifier_imba_hook_sharp_stack"):StartIntervalThink(self:GetSpecialValueFor("think_interval"))
		if self:GetCaster():FindAbilityByName("imba_pudge_light_hook"):GetToggleState() then
			self:GetCaster():FindAbilityByName("imba_pudge_light_hook"):ToggleAbility()
		end
	else
		self:GetCaster():FindModifierByName("modifier_imba_hook_sharp_stack"):StartIntervalThink(-1)
	end
end

modifier_imba_hook_sharp_stack = class({})

function modifier_imba_hook_sharp_stack:IsDebuff()			return false end
function modifier_imba_hook_sharp_stack:IsHidden() 			return false end
function modifier_imba_hook_sharp_stack:IsPurgable() 		return false end
function modifier_imba_hook_sharp_stack:IsPurgeException() 	return false end
function modifier_imba_hook_sharp_stack:GetTexture() return "custom/pudge_sharp_hook" end

function modifier_imba_hook_sharp_stack:OnIntervalThink()
	local sharp_buff = self:GetParent():FindModifierByName("modifier_imba_hook_sharp_stack")
	local light_buff = self:GetParent():FindModifierByName("modifier_imba_hook_light_stack")
	if not sharp_buff or not light_buff then
		return
	end
	if light_buff:GetStackCount() == 0 then
		self:GetAbility():ToggleAbility()
		return
	end
	sharp_buff:SetStackCount(sharp_buff:GetStackCount() + 1)
	light_buff:SetStackCount(light_buff:GetStackCount() - 1)
end

imba_pudge_light_hook = class({})

LinkLuaModifier("modifier_imba_hook_light_stack", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)

function imba_pudge_light_hook:IsHiddenWhenStolen() 	return false end
function imba_pudge_light_hook:IsRefreshable() 			return true end
function imba_pudge_light_hook:IsStealable() 			return false end
function imba_pudge_light_hook:IsNetherWardStealable()	return false end
function imba_pudge_light_hook:GetIntrinsicModifierName() return "modifier_imba_hook_light_stack" end
function imba_pudge_light_hook:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():FindModifierByName("modifier_imba_hook_light_stack"):StartIntervalThink(self:GetSpecialValueFor("think_interval"))
		if self:GetCaster():FindAbilityByName("imba_pudge_sharp_hook"):GetToggleState() then
			self:GetCaster():FindAbilityByName("imba_pudge_sharp_hook"):ToggleAbility()
		end
	else
		self:GetCaster():FindModifierByName("modifier_imba_hook_light_stack"):StartIntervalThink(-1)
	end
end

modifier_imba_hook_light_stack = class({})

function modifier_imba_hook_light_stack:IsDebuff()			return false end
function modifier_imba_hook_light_stack:IsHidden() 			return false end
function modifier_imba_hook_light_stack:IsPurgable() 		return false end
function modifier_imba_hook_light_stack:IsPurgeException() 	return false end
function modifier_imba_hook_light_stack:GetTexture() return "custom/pudge_light_hook" end

function modifier_imba_hook_light_stack:OnIntervalThink()
	local sharp_buff = self:GetParent():FindModifierByName("modifier_imba_hook_sharp_stack")
	local light_buff = self:GetParent():FindModifierByName("modifier_imba_hook_light_stack")
	if not sharp_buff or not light_buff then
		return
	end
	if sharp_buff:GetStackCount() == 0 then
		self:GetAbility():ToggleAbility()
		return
	end
	sharp_buff:SetStackCount(sharp_buff:GetStackCount() - 1)
	light_buff:SetStackCount(light_buff:GetStackCount() + 1)
end




imba_pudge_meat_hook = class({})

LinkLuaModifier("modifier_imba_meat_hook_self_root", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_meat_hook_hook_check", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_meat_hook_stack_check", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hook_target_enemy", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hook_target_ally", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)

function imba_pudge_meat_hook:IsHiddenWhenStolen() 		return false end
function imba_pudge_meat_hook:IsRefreshable() 			return true end
function imba_pudge_meat_hook:IsStealable() 			return true end
function imba_pudge_meat_hook:IsNetherWardStealable()	return true end
function imba_pudge_meat_hook:GetIntrinsicModifierName() return "modifier_imba_meat_hook_stack_check" end
function imba_pudge_meat_hook:GetCooldown(i) return self:GetCaster():HasScepter() and math.max(self:GetSpecialValueFor("cooldown_base") - self:GetCaster():GetModifierStackCount("modifier_imba_hook_sharp_stack", self:GetCaster()) * self:GetSpecialValueFor("cooldown_scepter"), self:GetSpecialValueFor("cooldown_cap_scepter")) or self:GetSpecialValueFor("cooldown_base") end
function imba_pudge_meat_hook:GetCastRange() return self:GetSpecialValueFor("base_range") + self:GetCaster():GetModifierStackCount("modifier_imba_hook_light_stack", self:GetCaster()) * self:GetSpecialValueFor("stack_range") end
function imba_pudge_meat_hook:OnUpgrade()
	local ability1 = self:GetCaster():FindAbilityByName("imba_pudge_sharp_hook")
	local ability2 = self:GetCaster():FindAbilityByName("imba_pudge_light_hook")
	if ability1 then
		ability1:SetLevel(self:GetLevel())
	end
	if ability2 then
		ability2:SetLevel(self:GetLevel())
	end
end
function imba_pudge_meat_hook:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	return true
end
function imba_pudge_meat_hook:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	return true
end

function imba_pudge_meat_hook:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local distance = self:GetCastRange(pos, caster) + caster:GetCastRangeBonus()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	local pos_end = caster:GetAbsOrigin() + direction * distance
	local thinker_modifier_name = "modifier_imba_hook_sharp_stack"
	local speed = self:GetSpecialValueFor("base_speed") + caster:GetModifierStackCount("modifier_imba_hook_light_stack", caster) * self:GetSpecialValueFor("stack_speed")
	local root = caster:AddNewModifier(caster, self, "modifier_imba_meat_hook_self_root", {})
	local hook = caster:AddNewModifier(caster, self, "modifier_imba_meat_hook_hook_check", {duration = 10.0})
	local thinker = CreateModifierThinker(caster, self, thinker_modifier_name, {duration = 20.0}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	thinker:EmitSound("Hero_Pudge.AttackHookExtend")
	thinker.root = root
	thinker.hook = hook
	local thinker_ent = thinker:entindex()
	local weapon_hook
	if caster:IsHero() then
		weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if weapon_hook ~= nil then
			weapon_hook:AddEffects( EF_NODRAW )
		end
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hook", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, thinker, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", thinker:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 2, Vector(5000, distance, self:GetSpecialValueFor("hook_width")))
	ParticleManager:SetParticleControl(pfx, 3, Vector(100,0,0))
	ParticleManager:SetParticleControl(pfx, 4, Vector(1,0,0))
	ParticleManager:SetParticleControl(pfx, 5, Vector(0,0,0))
	thinker:FindModifierByName(thinker_modifier_name):AddParticle(pfx, true, false, 15, false, false)
	local info = 
	{
		Ability = self,
		EffectName = nil,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = self:GetSpecialValueFor("hook_width"),
		fEndRadius = self:GetSpecialValueFor("hook_width"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 30.0,
		bDeleteOnHit = true,
		vVelocity = direction * speed,
		bProvidesVision = false,
		ExtraData = {thinker = thinker_ent, go = 1, speed = speed, pfx = pfx}
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function imba_pudge_meat_hook:OnProjectileThink_ExtraData(location, keys)
	if EntIndexToHScript(keys.thinker) then
		EntIndexToHScript(keys.thinker):SetAbsOrigin(location)
	end
end

function imba_pudge_meat_hook:OnProjectileHit_ExtraData(target, location, keys)
	if target and target:HasModifier("modifier_imba_tricks_of_the_trade_caster") then
		return false
	end
	if keys.go == 0 then
		EntIndexToHScript(keys.thinker).hook:Destroy()
		EntIndexToHScript(keys.thinker).hook = nil
		EntIndexToHScript(keys.thinker):StopSound("Hero_Pudge.AttackHookExtend")
		EntIndexToHScript(keys.thinker):StopSound("Hero_Pudge.AttackHookRetract")
		EntIndexToHScript(keys.thinker):ForceKill(false)
		local caster = self:GetCaster()
		local weapon_hook
		if caster:IsHero() and not caster:HasModifier("modifier_imba_meat_hook_hook_check") then
			weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
			if weapon_hook ~= nil then
				weapon_hook:RemoveEffects( EF_NODRAW )
			end
		end
		caster:EmitSound("Hero_Pudge.AttackHookRetractStop")
		if EntIndexToHScript(keys.thinker).buff then
			EntIndexToHScript(keys.thinker).buff:Destroy()
			EntIndexToHScript(keys.thinker).buff = nil
		end
		return true
	end
	if keys.go == 1 then
		if target and (target == self:GetCaster() or target:IsBoss()) then
			return false
		end
		EntIndexToHScript(keys.thinker).root:Destroy()
		EntIndexToHScript(keys.thinker).root = nil
		self:GetCaster():FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		local caster = self:GetCaster()
		local source_target = EntIndexToHScript(keys.thinker)
		if target and not IsNearEnemyFountain(location, caster:GetTeamNumber(), 1600) then
			if target:GetTeamNumber() ~= caster:GetTeamNumber() then
				local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_POINT_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), self:GetSpecialValueFor("vision_radius"), self:GetSpecialValueFor('vision_duration'), false)
				target:RemoveModifierByName("modifier_imba_hook_target_enemy")
				local buff = target:AddNewModifier(caster, self, "modifier_imba_hook_target_enemy", {thinker = keys.thinker})
				EntIndexToHScript(keys.thinker).buff = buff
				local dmg = self:GetSpecialValueFor("base_damage") + caster:GetModifierStackCount("modifier_imba_hook_sharp_stack", caster) * self:GetSpecialValueFor("stack_damage") + (caster:HasScepter() and caster:GetModifierStackCount("modifier_imba_hook_light_stack", caster) * self:GetSpecialValueFor("damage_scepter") or 0)
				local damageTable = {
									victim = target,
									attacker = self:GetCaster(),
									damage = dmg,
									damage_type = self:GetAbilityDamageType(),
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self, --Optional.
									}
				local dmg_done = ApplyDamage(damageTable)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, dmg_done, nil)
			else
				target:RemoveModifierByName("modifier_imba_hook_target_ally")
				local buff = target:AddNewModifier(caster, self, "modifier_imba_hook_target_ally", {thinker = keys.thinker})
				EntIndexToHScript(keys.thinker).buff = buff
			end
			target:EmitSound("Hero_Pudge.AttackHookImpact")
			source_target = target
		end
		EntIndexToHScript(keys.thinker):EmitSound("Hero_Pudge.AttackHookRetract")
		local info = 
		{
			Target = self:GetCaster(),
			Source = source_target,
			Ability = self,	
			EffectName = nil,
			iMoveSpeed = keys.speed,
			vSourceLoc = source_target:GetAbsOrigin(),
			bDrawsOnMinimap = false,
			bDodgeable = false,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 30.0,
			bProvidesVision = false,	
			ExtraData = {thinker = keys.thinker, go = 0,}
		}
		ProjectileManager:CreateTrackingProjectile(info)
		return true
	end
end


modifier_imba_meat_hook_stack_check = class({})

function modifier_imba_meat_hook_stack_check:IsDebuff()			return false end
function modifier_imba_meat_hook_stack_check:IsHidden() 		return true end
function modifier_imba_meat_hook_stack_check:IsPurgable() 		return false end
function modifier_imba_meat_hook_stack_check:IsPurgeException() return false end

function modifier_imba_meat_hook_stack_check:OnCreated()
	if IsServer() then
		if self:GetAbility():IsStolen() then
			local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_hook_sharp_stack", {})
			buff:SetStackCount(self:GetParent():GetLevel())
			local buff2 = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_hook_light_stack", {})
			buff2:SetStackCount(self:GetParent():GetLevel())
		else
			self:StartIntervalThink(0.1)
		end
	end
end

function modifier_imba_meat_hook_stack_check:OnIntervalThink()
	local buff1 = self:GetParent():FindModifierByName("modifier_imba_hook_sharp_stack")
	local buff2 = self:GetParent():FindModifierByName("modifier_imba_hook_light_stack")
	if (self:GetParent():GetLevel() * 2) > (buff1:GetStackCount() + buff2:GetStackCount()) then
		buff1:SetStackCount(buff1:GetStackCount() + 1)
		buff2:SetStackCount(buff2:GetStackCount() + 1)
	end
end

modifier_imba_hook_target_enemy = class({})

function modifier_imba_hook_target_enemy:IsMotionController()	return true end
function modifier_imba_hook_target_enemy:IsDebuff()				return true end
function modifier_imba_hook_target_enemy:IsHidden() 			return false end
function modifier_imba_hook_target_enemy:IsPurgable() 			return false end
function modifier_imba_hook_target_enemy:IsPurgeException() 	return false end
function modifier_imba_hook_target_enemy:RemoveOnDeath() 		return false end
function modifier_imba_hook_target_enemy:IsStunDebuff()			return true end
function modifier_imba_hook_target_enemy:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_hook_target_enemy:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_hook_target_enemy:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_hook_target_enemy:GetOverrideAnimation() return ACT_DOTA_FLAIL end

function modifier_imba_hook_target_enemy:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.thinker = EntIndexToHScript(keys.thinker)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_hook_target_enemy:OnIntervalThink()
	if not self.thinker:IsNull() and self.thinker and not self:GetParent():HasModifier("modifier_imba_illusion_hidden") then
		self:GetParent():SetAbsOrigin(GetGroundPosition(self.thinker:GetAbsOrigin(), self:GetParent()))
	else
		self:Destroy()
	end
end

function modifier_imba_hook_target_enemy:OnDestroy()
	if IsServer() then
		self.thinker = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

modifier_imba_hook_target_ally = class({})

function modifier_imba_hook_target_ally:IsMotionController()	return true end
function modifier_imba_hook_target_ally:IsDebuff()				return false end
function modifier_imba_hook_target_ally:IsHidden() 				return false end
function modifier_imba_hook_target_ally:IsPurgable() 			return false end
function modifier_imba_hook_target_ally:IsPurgeException() 		return false end
function modifier_imba_hook_target_ally:RemoveOnDeath() 		return false end
function modifier_imba_hook_target_ally:IsStunDebuff()			return false end
function modifier_imba_hook_target_ally:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_hook_target_ally:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_hook_target_ally:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_hook_target_ally:GetOverrideAnimation() return ACT_DOTA_FLAIL end

function modifier_imba_hook_target_ally:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.thinker = EntIndexToHScript(keys.thinker)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_hook_target_ally:OnIntervalThink()
	if not self.thinker:IsNull() and self.thinker and not self:GetParent():HasModifier("modifier_imba_illusion_hidden") then
		self:GetParent():SetAbsOrigin(GetGroundPosition(self.thinker:GetAbsOrigin(), self:GetParent()))
	else
		self:Destroy()
	end
end

function modifier_imba_hook_target_ally:OnDestroy()
	if IsServer() then
		self.thinker = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

modifier_imba_meat_hook_self_root = class({})

function modifier_imba_meat_hook_self_root:IsDebuff()			return false end
function modifier_imba_meat_hook_self_root:IsHidden() 			return true end
function modifier_imba_meat_hook_self_root:IsPurgable() 		return false end
function modifier_imba_meat_hook_self_root:IsPurgeException() 	return false end
function modifier_imba_meat_hook_self_root:RemoveOnDeath() 		return false end
function modifier_imba_meat_hook_self_root:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_meat_hook_self_root:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end

modifier_imba_meat_hook_hook_check = class({})

function modifier_imba_meat_hook_hook_check:IsDebuff()			return false end
function modifier_imba_meat_hook_hook_check:IsHidden() 			return true end
function modifier_imba_meat_hook_hook_check:IsPurgable() 		return false end
function modifier_imba_meat_hook_hook_check:IsPurgeException() 	return false end
function modifier_imba_meat_hook_hook_check:RemoveOnDeath() 	return false end
function modifier_imba_meat_hook_hook_check:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end


imba_pudge_rot = class({})

LinkLuaModifier("modifier_imba_rot_active", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rot_slow", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)

function imba_pudge_rot:IsHiddenWhenStolen() 	return false end
function imba_pudge_rot:IsRefreshable() 		return true end
function imba_pudge_rot:IsStealable() 			return true end
function imba_pudge_rot:IsNetherWardStealable()	return false end
function imba_pudge_rot:GetCastRange() return self:GetSpecialValueFor("base_radius") + math.min(self:GetCaster():GetModifierStackCount("modifier_imba_flesh_heap_stacks", self:GetCaster()), self:GetSpecialValueFor("max_stacks")) * self:GetSpecialValueFor("stack_radius") - self:GetCaster():GetCastRangeBonus() end

function imba_pudge_rot:OnToggle()
	if self:GetToggleState() then
		EmitSoundOn("Hero_Pudge.Rot", self:GetCaster())
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_rot_active", {})
	else
		StopSoundOn("Hero_Pudge.Rot", self:GetCaster())
		self:GetCaster():RemoveModifierByName("modifier_imba_rot_active")
	end
end

modifier_imba_rot_active = class({})

function modifier_imba_rot_active:IsDebuff()			return false end
function modifier_imba_rot_active:IsHidden() 			return false end
function modifier_imba_rot_active:IsPurgable() 			return false end
function modifier_imba_rot_active:IsPurgeException() 	return false end
function modifier_imba_rot_active:IsAura() return true end
function modifier_imba_rot_active:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("rot_stickyness") end
function modifier_imba_rot_active:GetModifierAura() return "modifier_imba_rot_slow" end
function modifier_imba_rot_active:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("base_radius") + math.min(self:GetCaster():GetModifierStackCount("modifier_imba_flesh_heap_stacks", self:GetCaster()), self:GetAbility():GetSpecialValueFor("max_stacks")) * self:GetAbility():GetSpecialValueFor("stack_radius") end
function modifier_imba_rot_active:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_rot_active:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_rot_active:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_rot_active:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAuraRadius(), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("rot_tick"))
	end
end

function modifier_imba_rot_active:OnIntervalThink()
	local dmg = (self:GetAbility():GetSpecialValueFor("base_damage") + ((self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():GetTalentValue("special_bonus_imba_pudge_1")) / 100) * self:GetParent():GetMaxHealth()) / (1.0 / self:GetAbility():GetSpecialValueFor("rot_tick"))
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetParent(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

function modifier_imba_rot_active:OnDestroy()
	if IsServer() then
		if self:GetAbility():GetToggleState() then
			self:GetAbility():ToggleAbility()
		end
	end
end

modifier_imba_rot_slow = class({})

function modifier_imba_rot_slow:IsDebuff()			return true end
function modifier_imba_rot_slow:IsHidden() 			return false end
function modifier_imba_rot_slow:IsPurgable() 		return false end
function modifier_imba_rot_slow:IsPurgeException() 	return false end
function modifier_imba_rot_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_rot_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("rot_slow")) end

function modifier_imba_rot_slow:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("rot_tick"))
	end
end

function modifier_imba_rot_slow:OnIntervalThink()
	local dmg = (self:GetAbility():GetSpecialValueFor("base_damage") + ((self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():GetTalentValue("special_bonus_imba_pudge_1")) / 100) * self:GetCaster():GetMaxHealth()) / (1.0 / self:GetAbility():GetSpecialValueFor("rot_tick"))
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end


imba_pudge_flesh_heap = class({})

LinkLuaModifier("modifier_imba_flesh_heap_stacks", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)

function imba_pudge_flesh_heap:GetCastRange() return self:GetSpecialValueFor("range") - self:GetCaster():GetCastRangeBonus() end
function imba_pudge_flesh_heap:OnHeroDiedNearby(unit, attacker, keys)
	if unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and unit:IsRealHero() and not unit:IsClone() and not unit:IsTempestDouble() and (((unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() <= self:GetLevelSpecialValueFor("range", 0) and self:GetCaster():IsAlive()) or attacker == self:GetCaster()) and not self:GetCaster():IsIllusion() then
		if self.stack == nil then
			self.stack = 0
		end
		self.stack = self.stack + 1
		local buff = self:GetCaster():FindModifierByName("modifier_imba_flesh_heap_stacks")
		if buff ~= nil then
			buff:SetStackCount(self.stack)
			self:GetCaster():CalculateStatBonus()
		end
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function imba_pudge_flesh_heap:GetStack()
	if self.stack == nil then
		self.stack = 0
	end
	return self.stack
end

function imba_pudge_flesh_heap:GetIntrinsicModifierName() return "modifier_imba_flesh_heap_stacks" end

modifier_imba_flesh_heap_stacks = class({})

function modifier_imba_flesh_heap_stacks:IsDebuff()			return false end
function modifier_imba_flesh_heap_stacks:IsHidden() 		return false end
function modifier_imba_flesh_heap_stacks:IsPurgable() 		return false end
function modifier_imba_flesh_heap_stacks:IsPurgeException() return false end
function modifier_imba_flesh_heap_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_MODEL_SCALE} end
function modifier_imba_flesh_heap_stacks:GetModifierBonusStats_Strength() return self:GetParent():PassivesDisabled() and 0 or (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stack_str")) end
function modifier_imba_flesh_heap_stacks:GetModifierMagicalResistanceBonus() return self:GetParent():PassivesDisabled() and 0 or (self:GetAbility():GetSpecialValueFor("base_magic_resist") + math.min(self:GetStackCount(), self:GetAbility():GetSpecialValueFor("max_stacks")) * self:GetAbility():GetSpecialValueFor("stack_magic_resist")) end
function modifier_imba_flesh_heap_stacks:GetModifierModelScale() return self:GetParent():PassivesDisabled() and 0.5 or (1.0 + math.min(self:GetStackCount(), self:GetAbility():GetSpecialValueFor("max_stacks")) * self:GetAbility():GetSpecialValueFor("stack_scale_up")) end
function modifier_imba_flesh_heap_stacks:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetStack())
		self:GetCaster():CalculateStatBonus()
	end
end


imba_pudge_dismember = class({})

LinkLuaModifier("modifier_imba_dismember_channel", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_dismember", "hero/hero_pudge", LUA_MODIFIER_MOTION_NONE)

function imba_pudge_dismember:IsHiddenWhenStolen() 		return false end
function imba_pudge_dismember:IsRefreshable() 			return true end
function imba_pudge_dismember:IsStealable() 			return true end
function imba_pudge_dismember:IsNetherWardStealable()	return true end
function imba_pudge_dismember:GetIntrinsicModifierName() return "modifier_imba_dismember_channel" end
function imba_pudge_dismember:GetConceptRecipientType() return DOTA_SPEECH_USER_ALL end
function imba_pudge_dismember:SpeakTrigger() return DOTA_ABILITY_SPEAK_START_ACTION_PHASE end
function imba_pudge_dismember:GetChannelTime() return (self:GetCaster():GetModifierStackCount("modifier_imba_dismember_channel", self:GetCaster()) / 10) end

function imba_pudge_dismember:OnAbilityPhaseStart()
	self:GetCaster():FindModifierByName("modifier_imba_dismember_channel"):SetStackCount(((self:GetCursorTarget():IsHero() or self:GetCursorTarget():IsBoss()) and (self:GetSpecialValueFor("hero_duration") + self:GetCaster():GetTalentValue("special_bonus_imba_pudge_2")) * 10 or (self:GetSpecialValueFor("creep_duration") + self:GetCaster():GetTalentValue("special_bonus_imba_pudge_2")) * 10))
	return true
end

function imba_pudge_dismember:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		Timers:CreateTimer(FrameTime(), function()
				self:EndChannel(true)
				caster:Stop()
				return nil
			end
		)
		return
	end
	target:AddNewModifier(caster, self, "modifier_imba_dismember", {duration = (self:GetChannelTime() + FrameTime() * 2)})
end

modifier_imba_dismember_channel = class({})

function modifier_imba_dismember_channel:IsDebuff()			return false end
function modifier_imba_dismember_channel:IsHidden() 		return true end
function modifier_imba_dismember_channel:IsPurgable() 		return false end
function modifier_imba_dismember_channel:IsPurgeException() return false end

modifier_imba_dismember = class({})

function modifier_imba_dismember:IsDebuff()			return true end
function modifier_imba_dismember:IsHidden() 		return false end
function modifier_imba_dismember:IsPurgable() 		return false end
function modifier_imba_dismember:IsPurgeException() return false end
function modifier_imba_dismember:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_dismember:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_dismember:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_dismember:GetOverrideAnimation() return ACT_DOTA_FLAIL end

function modifier_imba_dismember:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
		self:OnIntervalThink()
	end
end

function modifier_imba_dismember:OnIntervalThink()
	if not self:GetAbility() or (not self:GetAbility():IsChanneling() and self:GetElapsedTime() > 0.06) then
		self:Destroy()
		return
	end
	self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100)
	local dmg = (self:GetCaster():GetStrength() * (self:GetAbility():GetSpecialValueFor("strength_damage") / 100) + self:GetAbility():GetSpecialValueFor("dismember_damage")) / (1.0 / 0.5)
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	local dmg_done = ApplyDamage(damageTable)
	self:GetCaster():Heal(dmg_done, self:GetAbility())
end