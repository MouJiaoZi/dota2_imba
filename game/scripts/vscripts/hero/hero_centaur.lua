CreateEmptyTalents("centaur")

imba_centaur_hoof_stomp = class({})

LinkLuaModifier("modifier_imba_hoof_stomp_caster", "hero/hero_centaur", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hoof_stomp_enemy", "hero/hero_centaur", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hoof_stomp_dummy", "hero/hero_centaur", LUA_MODIFIER_MOTION_NONE)

function imba_centaur_hoof_stomp:IsHiddenWhenStolen() 		return false end
function imba_centaur_hoof_stomp:IsRefreshable() 			return true  end
function imba_centaur_hoof_stomp:IsStealable() 				return true  end
function imba_centaur_hoof_stomp:IsNetherWardStealable() 	return true end

function imba_centaur_hoof_stomp:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_centaur_hoof_stomp:OnSpellStart()
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = self:GetSpecialValueFor("stomp_damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
	end
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Centaur.HoofStomp", caster)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_CUSTOMORIGIN, nil)
	for i=0,6 do
		ParticleManager:SetParticleControl(pfx, i, caster:GetAbsOrigin())
	end
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("radius")))
	GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), false)
	CreateModifierThinker(caster, self, "modifier_imba_hoof_stomp_dummy", {duration = self:GetSpecialValueFor("pit_duration")}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
end

modifier_imba_hoof_stomp_dummy = class({})

function modifier_imba_hoof_stomp_dummy:IsAura() return true end
function modifier_imba_hoof_stomp_dummy:GetAuraDuration() return 0.1 end
function modifier_imba_hoof_stomp_dummy:GetModifierAura() return "modifier_imba_hoof_stomp_caster" end
function modifier_imba_hoof_stomp_dummy:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_hoof_stomp_dummy:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_hoof_stomp_dummy:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_hoof_stomp_dummy:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_hoof_stomp_dummy:GetAuraEntityReject(unit)
	if unit ~= self:GetCaster() then
		return true
	end
	return false
end

function modifier_imba_hoof_stomp_dummy:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/hero/centaur/centaur_hoof_stomp_arena.vpcf", PATTACH_CUSTOMORIGIN, nil)
		for i=0,7 do
			ParticleManager:SetParticleControl(pfx, i, self:GetParent():GetAbsOrigin())
		end
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(0.03)
	end
end

function modifier_imba_hoof_stomp_dummy:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_hoof_stomp_enemy", {duration = self:GetRemainingTime()})
	end

end

modifier_imba_hoof_stomp_caster = class({})

function modifier_imba_hoof_stomp_caster:IsDebuff()				return false end
function modifier_imba_hoof_stomp_caster:IsHidden() 			return false end
function modifier_imba_hoof_stomp_caster:IsPurgable() 			return false end
function modifier_imba_hoof_stomp_caster:IsPurgeException() 	return false end

function modifier_imba_hoof_stomp_caster:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_imba_hoof_stomp_caster:GetModifierIncomingDamage_Percentage() return (0-self:GetAbility():GetSpecialValueFor("pit_dmg_reduction")) end

modifier_imba_hoof_stomp_enemy = class({})

function modifier_imba_hoof_stomp_enemy:IsDebuff()			return true end
function modifier_imba_hoof_stomp_enemy:IsHidden() 			return true end
function modifier_imba_hoof_stomp_enemy:IsPurgable() 		return true end
function modifier_imba_hoof_stomp_enemy:IsPurgeException() 	return true end

function modifier_imba_hoof_stomp_enemy:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_imba_hoof_stomp_enemy:OnIntervalThink()
	if not self:GetCaster() or not self:GetAbility() or not self then
		return
	end
	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("radius") then
		local pos = self:GetCaster():GetAbsOrigin() + (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetAbility():GetSpecialValueFor("radius")
		FindClearSpaceForUnit(self:GetParent(), pos, true)
	end
end

imba_centaur_double_edge = class({})

function imba_centaur_double_edge:IsHiddenWhenStolen() 		return false end
function imba_centaur_double_edge:IsRefreshable() 			return true  end
function imba_centaur_double_edge:IsStealable() 			return true  end
function imba_centaur_double_edge:IsNetherWardStealable() 	return true end

function imba_centaur_double_edge:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_centaur_double_edge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local dmg = self:GetSpecialValueFor("edge_damage") + self:GetSpecialValueFor("str_percentage") / 100 * caster:GetStrength()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = dmg,
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControlEnt(pfx, 0, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 5, caster, PATTACH_POINT_FOLLOW, "attach_weapon_base", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
		EmitSoundOnLocationWithCaster(enemy:GetAbsOrigin(), "Hero_Centaur.DoubleEdge", caster)
	end
	local damageTable = {
						victim = caster,
						attacker = caster,
						damage = dmg,
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
end

imba_centaur_return = class({})

LinkLuaModifier("modifier_imba_centaur_return_aura", "hero/hero_centaur", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_centaur_return", "hero/hero_centaur", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_centaur_return_prevent", "hero/hero_centaur", LUA_MODIFIER_MOTION_NONE)

function imba_centaur_return:GetIntrinsicModifierName() return "modifier_imba_centaur_return_aura" end

modifier_imba_centaur_return_aura = class({})

function modifier_imba_centaur_return_aura:IsAura() return true end
function modifier_imba_centaur_return_aura:GetAuraDuration() return 0.1 end
function modifier_imba_centaur_return_aura:GetModifierAura() return "modifier_imba_centaur_return" end
function modifier_imba_centaur_return_aura:GetAuraRadius() return 1 + self:GetCaster():GetTalentValue("special_bonus_imba_centaur_1") end
function modifier_imba_centaur_return_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_centaur_return_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_centaur_return_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_centaur_return_aura:GetAuraEntityReject(unit)
	if self:GetCaster():HasTalent("special_bonus_imba_centaur_1") and unit:IsHero() then
		return false
	elseif self:GetCaster() ~= unit then
		return true
	end
	return false
end

function modifier_imba_centaur_return_aura:IsDebuff()			return false end
function modifier_imba_centaur_return_aura:IsHidden() 			return true end
function modifier_imba_centaur_return_aura:IsPurgable() 		return false end
function modifier_imba_centaur_return_aura:IsPurgeException() 	return false end

modifier_imba_centaur_return = class({})

function modifier_imba_centaur_return:IsDebuff()			return false end
function modifier_imba_centaur_return:IsHidden() 			return false end
function modifier_imba_centaur_return:IsPurgable() 			return false end
function modifier_imba_centaur_return:IsPurgeException() 	return false end

function modifier_imba_centaur_return:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_imba_centaur_return:GetModifierTotal_ConstantBlock(keys)
	if self:GetParent():PassivesDisabled() or keys.attacker:HasModifier("modifier_imba_centaur_return_prevent") then
		return nil
	end
	if keys.damage < self:GetAbility():GetSpecialValueFor("dmg_block") then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, self:GetParent(), keys.damage, nil)
	else
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, self:GetParent(), self:GetAbility():GetSpecialValueFor("dmg_block"), nil)
	end
	return self:GetAbility():GetSpecialValueFor("dmg_block")
end

function modifier_imba_centaur_return:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return 
	end
	if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() or self:GetParent():IsIllusion() or keys.attacker:IsBuilding() then
		return
	end
	if keys.attacker:HasModifier("modifier_imba_centaur_return_prevent") or self:GetParent():PassivesDisabled() then
		return
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
	ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	keys.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_centaur_return_prevent", {duration = self:GetAbility():GetSpecialValueFor("cooldown")})
	local caster_str = self:GetCaster():GetStrength()
	local dmg = caster_str * self:GetAbility():GetSpecialValueFor("strength_pct") / 100 * 300 / (caster_str + 300)
	local damageTable = {
						victim = keys.attacker,
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_REFLECTION, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

modifier_imba_centaur_return_prevent = class({})

function modifier_imba_centaur_return_prevent:IsDebuff()			return false end
function modifier_imba_centaur_return_prevent:IsHidden() 			return true end
function modifier_imba_centaur_return_prevent:IsPurgable() 			return false end
function modifier_imba_centaur_return_prevent:IsPurgeException() 	return false end

imba_centaur_stampede = class({})
LinkLuaModifier("modifier_imba_centaur_stampede", "hero/hero_centaur", LUA_MODIFIER_MOTION_NONE)

function imba_centaur_stampede:IsHiddenWhenStolen() 	return false end
function imba_centaur_stampede:IsRefreshable() 			return true  end
function imba_centaur_stampede:IsStealable() 			return true  end
function imba_centaur_stampede:IsNetherWardStealable() 	return true end

function imba_centaur_stampede:OnSpellStart()
	local caster = self:GetCaster()
	self.hit = {}
	caster:StartGesture(ACT_DOTA_CENTAUR_STAMPEDE)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 250000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_imba_centaur_stampede", {duration = self:GetSpecialValueFor("duration")})
		EmitSoundOnLocationWithCaster(ally:GetAbsOrigin(), "Hero_Centaur.Stampede.Cast", ally)
	end
end

modifier_imba_centaur_stampede = class({})

function modifier_imba_centaur_stampede:IsDebuff()			return false end
function modifier_imba_centaur_stampede:IsHidden() 			return false end
function modifier_imba_centaur_stampede:IsPurgable() 		return false end
function modifier_imba_centaur_stampede:IsPurgeException() 	return false end
function modifier_imba_centaur_stampede:GetEffectName() return "particles/units/heroes/hero_centaur/centaur_stampede_overhead.vpcf" end
function modifier_imba_centaur_stampede:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_centaur_stampede:ShouldUseOverheadOffset() return true end

function modifier_imba_centaur_stampede:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_stampede.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, 15, false, false)
		if self:GetCaster():HasTalent("special_bonus_imba_centaur_2") then
			local buffs = self:GetParent():FindAllModifiers()
			for _, buff in pairs(buffs) do
				if ((buff.IsDebuff and buff:IsDebuff()) or buff:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber()) and not (buff.IsMotionController and buff:IsMotionController()) and buff:GetDuration() > 0 then
					local duration = buff:GetRemainingTime() - buff:GetRemainingTime() * (self:GetCaster():GetTalentValue("special_bonus_imba_centaur_2") / 100)
					if duration < 0.03 then
						duration = 0.03
					end
					buff:SetDuration(duration, true)
				end
			end
		end
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_centaur_stampede:OnIntervalThink()
	local ability = self:GetAbility()
	if not self:GetParent():HasModifier("modifier_treant_natures_guise_near_tree_display") then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), ability:GetSpecialValueFor("tree_radius"), true)
	end
	if self:GetParent() == self:GetCaster() then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if not IsInTable(enemy, self:GetAbility().hit) then
				ability.hit[#ability.hit + 1] = enemy
				local dmg = ability:GetSpecialValueFor("strength_damage") / 100 * self:GetCaster():GetStrength()
				local damageTable = {
									victim = enemy,
									attacker = self:GetParent(),
									damage = dmg,
									damage_type = ability:GetAbilityDamageType(),
									damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
									ability = ability, --Optional.
									}
				ApplyDamage(damageTable)
				enemy:AddNewModifier(self:GetCaster(), ability, "modifier_imba_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
			end
		end
	end
end

function modifier_imba_centaur_stampede:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_imba_centaur_stampede:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function modifier_imba_centaur_stampede:GetModifierMoveSpeed_AbsoluteMin() return 550 end
function modifier_imba_centaur_stampede:GetModifierStatusResistanceStacking() return self:GetAbility():GetSpecialValueFor("status_resistance") end
function modifier_imba_centaur_stampede:GetModifierIncomingDamage_Percentage()
	if self:GetCaster():HasScepter() then
		return (0-self:GetAbility():GetSpecialValueFor("damage_reduction_scepter"))
	end
	return 0
end

function modifier_imba_centaur_stampede:CheckState()
	if self:GetCaster():HasScepter() then
		return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
end
