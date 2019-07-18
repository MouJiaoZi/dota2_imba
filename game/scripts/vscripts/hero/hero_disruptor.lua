CreateEmptyTalents("disruptor")


imba_disruptor_thunder_strike = class({})

LinkLuaModifier("modifier_imba_thunder_strike", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)

function imba_disruptor_thunder_strike:IsHiddenWhenStolen() 	return false end
function imba_disruptor_thunder_strike:IsRefreshable() 			return true end
function imba_disruptor_thunder_strike:IsStealable() 			return true end
function imba_disruptor_thunder_strike:IsNetherWardStealable()	return true end
function imba_disruptor_thunder_strike:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_disruptor_thunder_strike:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Disruptor.ThunderStrike.Cast")
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		enemy[i]:AddNewModifier(caster, self, "modifier_imba_thunder_strike", {})
	end
end

modifier_imba_thunder_strike = class({})

function modifier_imba_thunder_strike:IsDebuff()			return true end
function modifier_imba_thunder_strike:IsHidden() 			return false end
function modifier_imba_thunder_strike:IsPurgable() 			return not self:GetCaster():HasTalent("special_bonus_imba_disruptor_3") end
function modifier_imba_thunder_strike:IsPurgeException() 	return not self:GetCaster():HasTalent("special_bonus_imba_disruptor_3") end
function modifier_imba_thunder_strike:RemoveOnDeath()		return false end
function modifier_imba_thunder_strike:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_thunder_strike:GetEffectName() return "particles/units/heroes/hero_disruptor/disruptor_thunder_strike_buff.vpcf" end
function modifier_imba_thunder_strike:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_thunder_strike:ShouldUseOverheadOffset() return true end
function modifier_imba_thunder_strike:CheckState() return {[MODIFIER_STATE_INVISIBLE] = false} end
function modifier_imba_thunder_strike:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_thunder_strike:GetModifierProvidesFOWVision() return 1 end
function modifier_imba_thunder_strike:GetPriority() return MODIFIER_PRIORITY_HIGH end

function modifier_imba_thunder_strike:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and self:GetStackCount() > 0 then
		if self:GetParent():HasModifier("modifier_imba_kinetic_field") then
			local buff = self:GetParent():FindAllModifiersByName("modifier_imba_kinetic_field")
			local target = {}
			for i=1, #buff do
				local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), buff[i]:GetCaster():GetAbsOrigin(), nil, buff[i]:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
				for j=1, #enemy do
					if enemy[j] ~= self:GetParent() and not IsInTable(enemy[j], target) then
						target[#target + 1] = enemy[j]
					end
				end
			end
			for i = 1, #target do
				if target[i] ~= self:GetParent() and #target[i]:FindAllModifiersByName(self:GetName()) < 20 then
					target[i]:AddNewModifier(self:GetCaster(), self:GetAbility(), self:GetName(), {strikes = self:GetStackCount()})
				end
			end
			self:Destroy()
		else
			local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			for i = 1, #enemy do
				if enemy[i] ~= self:GetParent() and #enemy[i]:FindAllModifiersByName(self:GetName()) < 20 then
					enemy[i]:AddNewModifier(self:GetCaster(), self:GetAbility(), self:GetName(), {strikes = self:GetStackCount()})
					self:Destroy()
					break
				end
			end
		end
	end
end

function modifier_imba_thunder_strike:OnCreated(keys)
	if IsServer() then
		self:GetParent():EmitSound("Hero_Disruptor.ThunderStrike.Thunderator")
		if not keys.strikes then
			self:SetStackCount(self:GetAbility():GetSpecialValueFor("strikes") + self:GetCaster():GetTalentValue("special_bonus_imba_disruptor_2"))
			self:OnIntervalThink()
		else
			self:SetStackCount(keys.strikes)
		end
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("strike_interval"))
	end
end

function modifier_imba_thunder_strike:OnRefresh(keys) self:OnCreated(keys) end

function modifier_imba_thunder_strike:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	target:EmitSound("Hero_Disruptor.ThunderStrike.Target")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 2, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_OVERHEAD_FOLLOW, nil, target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	self:SetStackCount(self:GetStackCount() - (target:HasModifier("modifier_imba_static_storm_debuff") and -1 or 1))
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		ApplyDamage({victim = enemy[i], attacker = caster, ability = ability, damage = ability:GetSpecialValueFor("strike_damage") + caster:GetTalentValue("special_bonus_imba_disruptor_1"), damage_type = ability:GetAbilityDamageType()})
	end
end

function modifier_imba_thunder_strike:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Disruptor.ThunderStrike.Thunderator")
	end
end


imba_disruptor_glimpse = class({})

LinkLuaModifier("modifier_imba_glimpse_built_in", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_glimpse_record", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_glimpse_target", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

function imba_disruptor_glimpse:IsHiddenWhenStolen() 	return false end
function imba_disruptor_glimpse:IsRefreshable() 		return true end
function imba_disruptor_glimpse:IsStealable() 			return true end
function imba_disruptor_glimpse:IsNetherWardStealable()	return true end
function imba_disruptor_glimpse:GetIntrinsicModifierName() return "modifier_imba_glimpse_built_in" end

function imba_disruptor_glimpse:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	caster:EmitSound("Hero_Disruptor.Glimpse.End")
	local buff = target:FindModifierByName("modifier_imba_glimpse_record")
	if buff then
		if not target:HasModifier("modifier_imba_static_storm_debuff") then
			buff:BackTrack(caster, self)
		else
			target:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = 3.0})
		end
	elseif target:IsIllusion() then
		TrueKill(caster, target, self)
	end
end

modifier_imba_glimpse_built_in = class({})

function modifier_imba_glimpse_built_in:IsDebuff() return false end
function modifier_imba_glimpse_built_in:IsHidden() return true end
function modifier_imba_glimpse_built_in:IsPurgable() return false end
function modifier_imba_glimpse_built_in:IsPurgeException() return false end
function modifier_imba_glimpse_built_in:AllowIllusionDuplicate() return false end
function modifier_imba_glimpse_built_in:IsAura() return not self:GetParent():IsIllusion() end
function modifier_imba_glimpse_built_in:IsAuraActiveOnDeath() return true end
function modifier_imba_glimpse_built_in:GetAuraDuration() return 0.1 end
function modifier_imba_glimpse_built_in:GetModifierAura() return "modifier_imba_glimpse_record" end
function modifier_imba_glimpse_built_in:GetAuraRadius() return 50000 end
function modifier_imba_glimpse_built_in:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO end
function modifier_imba_glimpse_built_in:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_imba_glimpse_built_in:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_glimpse_record = class({})

function modifier_imba_glimpse_record:IsDebuff()			return false end
function modifier_imba_glimpse_record:IsHidden() 			return true end
function modifier_imba_glimpse_record:IsPurgable() 			return false end
function modifier_imba_glimpse_record:IsPurgeException() 	return false end

function modifier_imba_glimpse_record:OnCreated()
	if IsServer() then
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.pos_table = {}
		self.pos_table[GameRules:GetGameTime()] = self.parent:GetAbsOrigin()
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_glimpse_record:OnIntervalThink()
	self.pos_table[GameRules:GetGameTime()] = self.parent:GetAbsOrigin()
	for k, v in pairs(self.pos_table) do
		if k < GameRules:GetGameTime() - self.ability:GetSpecialValueFor("backtrack_time") then
			self.pos_table[k] = nil
		end
	end
end

function modifier_imba_glimpse_record:BackTrack(hCaster, hAbility)
	if not IsServer() then
		return
	end
	local target_time = GameRules:GetGameTime() - self.ability:GetSpecialValueFor("backtrack_time")
	local target = GetGroundPosition(Vector(0, 0, 0), self.parent)
	for k, v in pairs(self.pos_table) do
		if math.abs(k - target_time) <= 0.2 then
			target = v
			break
		end
	end
	CreateModifierThinker(hCaster, hAbility, "modifier_dummy_thinker", {duration = hAbility:GetSpecialValueFor("travel_time"), create_sound = "Hero_Disruptor.Glimpse.Destination"}, target, hCaster:GetTeamNumber(), false)
	AddFOWViewer(hCaster:GetTeamNumber(), target, 100, hAbility:GetSpecialValueFor("travel_time"), false)
	self.parent:RemoveModifierByName("modifier_imba_glimpse_target")
	self.parent:AddNewModifier(hCaster, hAbility, "modifier_imba_glimpse_target", {pos = target})
end

function modifier_imba_glimpse_record:OnDestroy()
	if IsServer() then
		self.parent = nil
		self.ability = nil
		self.pos_table = nil
	end
end

modifier_imba_glimpse_target = class({})

function modifier_imba_glimpse_target:IsDebuff()			return true end
function modifier_imba_glimpse_target:IsHidden() 			return false end
function modifier_imba_glimpse_target:IsPurgable() 			return true end
function modifier_imba_glimpse_target:IsPurgeException() 	return true end
function modifier_imba_glimpse_target:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_glimpse_target:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_glimpse_target:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_imba_glimpse_target:OnHorizontalMotionInterrupted() self:Destroy() end

function modifier_imba_glimpse_target:OnCreated(keys)
	if IsServer() then
		self:GetParent():EmitSound("Hero_Disruptor.Glimpse.Target")
		self.pos = StringToVector(keys.pos)
		local travel_time = (self:GetParent():GetAbsOrigin() - self.pos):Length2D() / self:GetAbility():GetSpecialValueFor("travel_speed")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_travel.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, self.pos)
		ParticleManager:SetParticleControl(pfx, 2, Vector(travel_time, 0, 0))
		self:AddParticle(pfx, true, false, 15, false, false)
		local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_targetend.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx2, 0, self.pos)
		ParticleManager:SetParticleControl(pfx2, 1, self.pos)
		ParticleManager:SetParticleControl(pfx2, 7, self.pos)
		ParticleManager:SetParticleControl(pfx2, 2, Vector(travel_time, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:SetPriority(DOTA_MOTION_CONTROLLER_PRIORITY_HIGH)
		if self:ApplyHorizontalMotionController() then
			self:StartIntervalThink(FrameTime())
		else
			self:Destroy()
		end
	end
end

function modifier_imba_glimpse_target:OnIntervalThink()
	local parent = self:GetParent()
	local buffs = parent:FindAllModifiersByName("modifier_imba_kinetic_field")
	for i=1, #buffs do
		if buffs[i]:GetStackCount() == 1 then
			parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stunned", {duration = 0.1})
			break
		end
	end
	parent:RemoveModifierByName("modifier_eul_cyclone")
	local direction = (self.pos - parent:GetAbsOrigin()):Normalized()
	direction.z = 0
	local distance = (self.pos - parent:GetAbsOrigin()):Length2D()
	local dis = self:GetAbility():GetSpecialValueFor("travel_speed") / (1.0 / FrameTime())
	if dis > distance then
		dis = distance
	end
	local new_pos = GetGroundPosition(parent:GetAbsOrigin() + direction * dis, parent)
	parent:InterruptChannel()
	parent:SetAbsOrigin(new_pos)
	if (new_pos - self.pos):Length2D() <= 100 then
		self:Destroy()
	end
end

function modifier_imba_glimpse_target:OnDestroy()
	if IsServer() then
		self.pos = nil
		self:GetParent():StopSound("Hero_Disruptor.Glimpse.Target")
		self:GetParent():EmitSound("Hero_Disruptor.Glimpse.End")
		self:GetParent():RemoveHorizontalMotionController(self)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

imba_disruptor_kinetic_field = class({})

LinkLuaModifier("modifier_imba_kinetic_field_delay", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_kinetic_field_thinker", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_kinetic_field", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)

function imba_disruptor_kinetic_field:IsHiddenWhenStolen() 		return false end
function imba_disruptor_kinetic_field:IsRefreshable() 			return true end
function imba_disruptor_kinetic_field:IsStealable() 			return true end
function imba_disruptor_kinetic_field:IsNetherWardStealable()	return true end
function imba_disruptor_kinetic_field:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_disruptor_kinetic_field:GetCooldown(iLevel) return (self.BaseClass.GetCooldown(self, iLevel) + self:GetCaster():GetTalentValue("special_bonus_imba_disruptor_4")) end

function imba_disruptor_kinetic_field:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = self:GetSpecialValueFor("formation_time") + self:GetSpecialValueFor("duration") + self:GetCaster():GetTalentValue("special_bonus_imba_disruptor_5") + FrameTime()}, pos, caster:GetTeamNumber(), false)
	local delay = CreateModifierThinker(caster, self, "modifier_imba_kinetic_field_delay", {duration = self:GetSpecialValueFor("formation_time"), sound = sound:entindex()}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_kinetic_field_delay = class({})

function modifier_imba_kinetic_field_delay:OnCreated(keys)
	if IsServer() then
		self.sound = keys.sound
		EntIndexToHScript(self.sound):EmitSound("Hero_Disruptor.KineticField")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_kf_formation.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), 0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetAbility():GetSpecialValueFor("formation_time"), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_kinetic_field_delay:OnDestroy()
	if IsServer() then
		CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_kinetic_field_thinker", {duration = self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():GetTalentValue("special_bonus_imba_disruptor_5"), sound = self.sound}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
		AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():GetTalentValue("special_bonus_imba_disruptor_5"), false)
		self.sound = nil
	end
end

modifier_imba_kinetic_field_thinker = class({})

function modifier_imba_kinetic_field_thinker:OnCreated(keys)
	if IsServer() then
		self.sound = keys.sound
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_kineticfield.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetAbility():GetSpecialValueFor("duration") + self:GetCaster():GetTalentValue("special_bonus_imba_disruptor_5"), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_kinetic_field_thinker:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		if not enemy[i]:FindModifierByNameAndCaster("modifier_imba_kinetic_field", self:GetParent()) then
			enemy[i]:AddNewModifier(self:GetParent(), ability, "modifier_imba_kinetic_field", {duration = self:GetRemainingTime()})
		end
	end
end

function modifier_imba_kinetic_field_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Disruptor.KineticField.End")
		EntIndexToHScript(self.sound):StopSound("Hero_Disruptor.KineticField")
		self.sound = nil
	end
end

modifier_imba_kinetic_field = class({})

function modifier_imba_kinetic_field:IsDebuff()			return true end
function modifier_imba_kinetic_field:IsHidden() 		return true end
function modifier_imba_kinetic_field:IsPurgable() 		return true end
function modifier_imba_kinetic_field:IsPurgeException() return true end
function modifier_imba_kinetic_field:RemoveOnDeath() return false end
function modifier_imba_kinetic_field:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_kinetic_field:OnCreated()
	if IsServer() then
		local thinker = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local distance = (thinker:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()
		if distance >= ability:GetSpecialValueFor("radius") - parent:GetHullRadius() / 2 then
			local direction = (parent:GetAbsOrigin() - thinker:GetAbsOrigin()):Normalized()
			direction.z = 0
			local pos = thinker:GetAbsOrigin() + direction * (ability:GetSpecialValueFor("radius") + parent:GetHullRadius())
			GridNav:DestroyTreesAroundPoint(pos, 50, false)
			FindClearSpaceForUnit(parent, pos, true)
			self:Destroy()
		else
			self:StartIntervalThink(FrameTime())
		end
	end
end

function modifier_imba_kinetic_field:OnIntervalThink()
	local thinker = self:GetCaster()
	if not thinker or (thinker and thinker:IsNull()) then
		self:Destroy()
		return
	end
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local distance = (thinker:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()
	if distance > ability:GetSpecialValueFor("radius") - parent:GetHullRadius() then
		local direction = (parent:GetAbsOrigin() - thinker:GetAbsOrigin()):Normalized()
		direction.z = 0
		FindClearSpaceForUnit(parent, thinker:GetAbsOrigin() + direction * (ability:GetSpecialValueFor("radius") - parent:GetHullRadius()), true)
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

imba_disruptor_static_storm = class({})

LinkLuaModifier("modifier_imba_static_storm_thinker", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_static_storm_debuff", "hero/hero_disruptor.lua", LUA_MODIFIER_MOTION_NONE)

function imba_disruptor_static_storm:IsHiddenWhenStolen() 		return false end
function imba_disruptor_static_storm:IsRefreshable() 			return true end
function imba_disruptor_static_storm:IsStealable() 				return true end
function imba_disruptor_static_storm:IsNetherWardStealable()	return true end
function imba_disruptor_static_storm:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_disruptor_static_storm:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	CreateModifierThinker(caster, self, "modifier_imba_static_storm_thinker", {duration = caster:HasScepter() and self:GetSpecialValueFor("duration_scepter") or self:GetSpecialValueFor("duration")}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_static_storm_thinker = class({})

function modifier_imba_static_storm_thinker:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local thinker = self:GetParent()
		thinker:EmitSound("Hero_Disruptor.StaticStorm.Cast")
		thinker:EmitSound("Hero_Disruptor.StaticStorm")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, thinker:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetDuration(), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(0.2)
		local enemy = FindUnitsInRadius(caster:GetTeamNumber(), thinker:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for i=1, #enemy do
			if enemy[i]:HasModifier("modifier_imba_kinetic_field") then
				FindClearSpaceForUnit(enemy[i], thinker:GetAbsOrigin(), true)
			end
		end
	end
end

function modifier_imba_static_storm_thinker:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local thinker = self:GetParent()
	local dmg = ability:GetSpecialValueFor("damage_per_second") / (1.0 / 0.2)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), thinker:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		ApplyDamage({victim = enemy[i], attacker = caster, ability = ability, damage = dmg, damage_type = ability:GetAbilityDamageType()})
	end
end

function modifier_imba_static_storm_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Disruptor.StaticStorm")
		self:GetParent():EmitSound("Hero_Disruptor.StaticStorm.End")
	end
end

function modifier_imba_static_storm_thinker:IsAura() return true end
function modifier_imba_static_storm_thinker:GetAuraDuration() return 0.1 end
function modifier_imba_static_storm_thinker:GetModifierAura() return "modifier_imba_static_storm_debuff" end
function modifier_imba_static_storm_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_static_storm_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_imba_static_storm_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_static_storm_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_static_storm_debuff = class({})

function modifier_imba_static_storm_debuff:IsDebuff()			return true end
function modifier_imba_static_storm_debuff:IsHidden() 			return false end
function modifier_imba_static_storm_debuff:IsPurgable() 		return true end
function modifier_imba_static_storm_debuff:IsPurgeException() 	return true end
function modifier_imba_static_storm_debuff:CheckState() return {[MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = self:GetCaster():HasScepter(), [MODIFIER_STATE_PASSIVES_DISABLED] = self:GetCaster():HasTalent("special_bonus_imba_disruptor_6")} end