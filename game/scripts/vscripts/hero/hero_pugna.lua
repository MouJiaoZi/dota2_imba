

CreateEmptyTalents("pugna")


imba_pugna_nether_blast = class({})

LinkLuaModifier("modifier_imba_nether_blast_debuff", "hero/hero_pugna", LUA_MODIFIER_MOTION_NONE)

function imba_pugna_nether_blast:IsHiddenWhenStolen() 		return false end
function imba_pugna_nether_blast:IsRefreshable() 			return true end
function imba_pugna_nether_blast:IsStealable() 				return true end
function imba_pugna_nether_blast:IsNetherWardStealable()	return true end
function imba_pugna_nether_blast:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_pugna_nether_blast:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local blasts = self:GetSpecialValueFor("secondary_blasts")
	local radius = self:GetSpecialValueFor("radius")
	local delay = self:GetSpecialValueFor("secondary_delay")
	local pfx_main = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx_main, 0, Vector(pos.x, pos.y, pos.z + 128))
	ParticleManager:SetParticleControl(pfx_main, 1, Vector(radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(pfx_main)
	local sound = CreateModifierThinker(caster, self, "modifier_imba_nether_blast_debuff", {duration = 0.1}, pos, caster:GetTeamNumber(), false)
	sound:EmitSound("Hero_Pugna.NetherBlast")
	local enemies_main = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ememy_main in pairs(enemies_main) do
		local dmg = self:GetSpecialValueFor("damage")
		if ememy_main:IsBuilding() then
			dmg = dmg * (self:GetSpecialValueFor("building_pct") / 100)
		end
		local damageTable = {
							victim = ememy_main,
							attacker = self:GetCaster(),
							damage = dmg,
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		if not ememy_main:IsBuilding() then
			ememy_main:AddNewModifier(caster, self, "modifier_imba_nether_blast_debuff", {duration = self:GetSpecialValueFor("duration")})
		end
	end
	local new_pos = pos + (pos - caster:GetAbsOrigin()):Normalized() * (radius - self:GetSpecialValueFor("center_radius"))
	for i=1, blasts do
		local blast_pos = GetGroundPosition(RotatePosition(pos, QAngle(0, 360 / blasts * i, 0), new_pos), nil)
		local pfx_min = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast_pre.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx_min, 0, Vector(blast_pos.x, blast_pos.y, blast_pos.z + 128))
		ParticleManager:SetParticleControl(pfx_min, 1, Vector(radius, 1, 1))
		ParticleManager:ReleaseParticleIndex(pfx_min)
		local sound = CreateModifierThinker(caster, self, "modifier_imba_nether_blast_debuff", {duration = 0.1}, blast_pos, caster:GetTeamNumber(), false)
		sound:EmitSound("Hero_Pugna.NetherBlastPreCast")
		Timers:CreateTimer(delay, function()
			local pfx_balst = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx_balst, 0, Vector(blast_pos.x, blast_pos.y, blast_pos.z + 128))
			ParticleManager:SetParticleControl(pfx_balst, 1, Vector(radius, 1, 1))
			ParticleManager:ReleaseParticleIndex(pfx_balst)
			local sound = CreateModifierThinker(caster, self, "modifier_imba_nether_blast_debuff", {duration = 0.1}, blast_pos, caster:GetTeamNumber(), false)
			sound:EmitSound("Hero_Pugna.NetherBlast")
			local enemies_balst = FindUnitsInRadius(caster:GetTeamNumber(), blast_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, ememy_balst in pairs(enemies_balst) do
				local dmg = self:GetSpecialValueFor("secondary_damage")
				if ememy_balst:IsBuilding() then
					dmg = dmg * (self:GetSpecialValueFor("building_pct") / 100)
				end
				local damageTable = {
									victim = ememy_balst,
									attacker = self:GetCaster(),
									damage = dmg,
									damage_type = self:GetAbilityDamageType(),
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self, --Optional.
									}
				ApplyDamage(damageTable)
				if not ememy_balst:IsBuilding() then
					ememy_balst:AddNewModifier(caster, self, "modifier_imba_nether_blast_debuff", {duration = self:GetSpecialValueFor("duration")})
				end
			end
			return nil
		end
		)
	end
end

modifier_imba_nether_blast_debuff = class({})

function modifier_imba_nether_blast_debuff:IsDebuff()			return true end
function modifier_imba_nether_blast_debuff:IsHidden() 			return false end
function modifier_imba_nether_blast_debuff:IsPurgable() 		return true end
function modifier_imba_nether_blast_debuff:IsPurgeException() 	return true end
function modifier_imba_nether_blast_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_imba_nether_blast_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_tooltip")) end
function modifier_imba_nether_blast_debuff:GetModifierMagicalResistanceBonus() return (0 - self:GetAbility():GetSpecialValueFor("magic_amp_tooltip")) end
function modifier_imba_nether_blast_debuff:GetEffectName() return "particles/hero/pugna/nether_blast_debuff.vpcf" end
function modifier_imba_nether_blast_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end



imba_pugna_decrepify = class({})

LinkLuaModifier("modifier_imba_decrepify_ally", "hero/hero_pugna", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_decrepify_enemy", "hero/hero_pugna", LUA_MODIFIER_MOTION_NONE)

function imba_pugna_decrepify:IsHiddenWhenStolen() 		return false end
function imba_pugna_decrepify:IsRefreshable() 			return true end
function imba_pugna_decrepify:IsStealable() 			return true end
function imba_pugna_decrepify:IsNetherWardStealable()	return true end

--[[function imba_pugna_decrepify:CastFilterResultTarget(target)
	if target:IsInvulnerable() then
		return UF_FAIL_INVULNERABLE
	end
	if target:IsBuilding() then
		return UF_FAIL_BUILDING
	end
	if target:IsCourier() then
		return UF_FAIL_COURIER
	end
	if target:IsOther() then
		return UF_FAIL_OTHER
	end
	if IsEnemy(self:GetCaster(), target) and target:IsMagicImmune() then
		return UF_FAIL_MAGIC_IMMUNE_ENEMY
	end
	if PlayerResource:IsDisableHelpSetForPlayerID(self:GetCaster():GetPlayerID(), target:GetPlayerID()) then
		return UF_FAIL_DISABLE_HELP
	end
end]]

function imba_pugna_decrepify:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local buff_name = IsEnemy(caster, target) and "modifier_imba_decrepify_enemy" or "modifier_imba_decrepify_ally"
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	if IsEnemy(target, caster) then
		target:AddNewModifier(caster, self, buff_name, {duration = self:GetSpecialValueFor("duration")})
	else
		target:AddNewModifier(caster, self, buff_name, {duration = self:GetSpecialValueFor("duration")})
	end
	target:EmitSound("Hero_Pugna.Decrepify")
end

modifier_imba_decrepify_ally = class({})

function modifier_imba_decrepify_ally:IsDebuff()			return false end
function modifier_imba_decrepify_ally:IsHidden() 			return false end
function modifier_imba_decrepify_ally:IsPurgable() 			return true end
function modifier_imba_decrepify_ally:IsPurgeException() 	return true end
function modifier_imba_decrepify_ally:GetEffectName() return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf" end
function modifier_imba_decrepify_ally:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_decrepify_ally:CheckState() return {[MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_ATTACK_IMMUNE] = true, } end
function modifier_imba_decrepify_ally:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_decrepify_ally:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_imba_decrepify_ally:GetModifierMagicalResistanceBonus() return (0 - self:GetAbility():GetSpecialValueFor("magic_amp")) end
function modifier_imba_decrepify_ally:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	self:SetStackCount(self:GetStackCount() + math.floor(keys.damage))
end

function modifier_imba_decrepify_ally:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasAbility("imba_pugna_nether_blast") and self:GetCaster():FindAbilityByName("imba_pugna_nether_blast"):GetLevel() > 0 then
			local caster = self:GetCaster()
			local ability = self:GetCaster():FindAbilityByName("imba_pugna_nether_blast")
			local radius = ability:GetSpecialValueFor("radius")
			local blast_pos = self:GetParent():GetAbsOrigin()
			local dmg = self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("blast_damage") / 100)
			local dmg_building = dmg * (self:GetAbility():GetSpecialValueFor("structure_damage") / 100)
			local pfx_min = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast_pre.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx_min, 0, Vector(blast_pos.x, blast_pos.y, blast_pos.z + 128))
			ParticleManager:SetParticleControl(pfx_min, 1, Vector(radius, 1, 1))
			ParticleManager:ReleaseParticleIndex(pfx_min)
			local sound = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_nether_blast_debuff", {duration = 0.1}, blast_pos, self:GetCaster():GetTeamNumber(), false)
			sound:EmitSound("Hero_Pugna.NetherBlastPreCast")
			Timers:CreateTimer(ability:GetSpecialValueFor("secondary_delay"), function()
				local pfx_balst = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(pfx_balst, 0, Vector(blast_pos.x, blast_pos.y, blast_pos.z + 128))
				ParticleManager:SetParticleControl(pfx_balst, 1, Vector(radius, 1, 1))
				ParticleManager:ReleaseParticleIndex(pfx_balst)
				local sound = CreateModifierThinker(caster, ability, "modifier_imba_nether_blast_debuff", {duration = 0.1}, blast_pos, caster:GetTeamNumber(), false)
				sound:EmitSound("Hero_Pugna.NetherBlast")
				local enemies_balst = FindUnitsInRadius(caster:GetTeamNumber(), blast_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, ememy_balst in pairs(enemies_balst) do
					local damage = ememy_balst:IsBuilding() and dmg_building or dmg
					local damageTable = {
										victim = ememy_balst,
										attacker = caster,
										damage = damage,
										damage_type = ability:GetAbilityDamageType(),
										damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
										ability = ability, --Optional.
										}
					ApplyDamage(damageTable)
					ememy_balst:AddNewModifier(caster, ability, "modifier_imba_nether_blast_debuff", {duration = ability:GetSpecialValueFor("duration")})
				end
				return nil
			end
			)
		end
	end
end

modifier_imba_decrepify_enemy = class({})

function modifier_imba_decrepify_enemy:IsDebuff()			return true end
function modifier_imba_decrepify_enemy:IsHidden() 			return false end
function modifier_imba_decrepify_enemy:IsPurgable() 		return true end
function modifier_imba_decrepify_enemy:IsPurgeException() 	return true end
function modifier_imba_decrepify_enemy:GetEffectName() return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf" end
function modifier_imba_decrepify_enemy:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_decrepify_enemy:CheckState() return {[MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_ATTACK_IMMUNE] = true, } end
function modifier_imba_decrepify_enemy:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_decrepify_enemy:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow")) end
function modifier_imba_decrepify_enemy:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_imba_decrepify_enemy:GetModifierMagicalResistanceBonus() return (0 - self:GetAbility():GetSpecialValueFor("magic_amp")) end
function modifier_imba_decrepify_enemy:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	self:SetStackCount(self:GetStackCount() + math.floor(keys.damage))
end

function modifier_imba_decrepify_enemy:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasAbility("imba_pugna_nether_blast") and self:GetCaster():FindAbilityByName("imba_pugna_nether_blast"):GetLevel() > 0 then
			local caster = self:GetCaster()
			local ability = self:GetCaster():FindAbilityByName("imba_pugna_nether_blast")
			local radius = ability:GetSpecialValueFor("radius")
			local blast_pos = self:GetParent():GetAbsOrigin()
			local dmg = self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("blast_damage") / 100)
			local dmg_building = dmg * (self:GetAbility():GetSpecialValueFor("structure_damage") / 100)
			local pfx_min = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast_pre.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx_min, 0, Vector(blast_pos.x, blast_pos.y, blast_pos.z + 128))
			ParticleManager:SetParticleControl(pfx_min, 1, Vector(radius, 1, 1))
			ParticleManager:ReleaseParticleIndex(pfx_min)
			local sound = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_nether_blast_debuff", {duration = 0.1}, blast_pos, self:GetCaster():GetTeamNumber(), false)
			sound:EmitSound("Hero_Pugna.NetherBlastPreCast")
			Timers:CreateTimer(ability:GetSpecialValueFor("secondary_delay"), function()
				local pfx_balst = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(pfx_balst, 0, Vector(blast_pos.x, blast_pos.y, blast_pos.z + 128))
				ParticleManager:SetParticleControl(pfx_balst, 1, Vector(radius, 1, 1))
				ParticleManager:ReleaseParticleIndex(pfx_balst)
				local sound = CreateModifierThinker(caster, ability, "modifier_imba_nether_blast_debuff", {duration = 0.1}, blast_pos, caster:GetTeamNumber(), false)
				sound:EmitSound("Hero_Pugna.NetherBlast")
				local enemies_balst = FindUnitsInRadius(caster:GetTeamNumber(), blast_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, ememy_balst in pairs(enemies_balst) do
					local damage = ememy_balst:IsBuilding() and dmg_building or dmg
					local damageTable = {
										victim = ememy_balst,
										attacker = caster,
										damage = damage,
										damage_type = ability:GetAbilityDamageType(),
										damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
										ability = ability, --Optional.
										}
					ApplyDamage(damageTable)
					ememy_balst:AddNewModifier(caster, ability, "modifier_imba_nether_blast_debuff", {duration = ability:GetSpecialValueFor("duration")})
				end
				return nil
			end
			)
		end
	end
end


--npc_imba_pugna_nether_ward_
imba_pugna_nether_ward = class({})

LinkLuaModifier("modifier_imba_nether_ward", "hero/hero_pugna", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nether_ward_debuff", "hero/hero_pugna", LUA_MODIFIER_MOTION_NONE)

function imba_pugna_nether_ward:IsHiddenWhenStolen() 	return false end
function imba_pugna_nether_ward:IsRefreshable() 		return true end
function imba_pugna_nether_ward:IsStealable() 			return true end
function imba_pugna_nether_ward:IsNetherWardStealable()	return false end
function imba_pugna_nether_ward:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_pugna_nether_ward:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local ward = CreateUnitByName("npc_imba_pugna_nether_ward_"..self:GetLevel(), pos, true, caster, caster, caster:GetTeamNumber())
	ward:AddNewModifier(caster, self, "modifier_imba_nether_ward", {duration = self:GetSpecialValueFor("duration")})
	ward:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	ward:AddNewModifier(caster, self, "modifier_rooted", {duration = self:GetSpecialValueFor("duration")})
	ward:SetControllableByPlayer(caster:GetPlayerID(), false)
	ward:EmitSound("Hero_Pugna.NetherWard")
	SetCreatureHealth(ward, self:GetSpecialValueFor("ward_health"), true)
end

modifier_imba_nether_ward = class({})

function modifier_imba_nether_ward:IsDebuff()			return false end
function modifier_imba_nether_ward:IsHidden() 			return false end
function modifier_imba_nether_ward:IsPurgable() 		return false end
function modifier_imba_nether_ward:IsPurgeException() 	return false end
function modifier_imba_nether_ward:IsAura() 			return true end
function modifier_imba_nether_ward:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_nether_ward:GetAuraDuration() return 0.5 end
function modifier_imba_nether_ward:GetModifierAura() return "modifier_imba_nether_ward_debuff" end
function modifier_imba_nether_ward:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_nether_ward:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_MANA_ONLY end
function modifier_imba_nether_ward:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_nether_ward:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_nether_ward:DeclareFunctions() return {MODIFIER_EVENT_ON_SPENT_MANA, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_IGNORE_CAST_ANGLE, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE} end
function modifier_imba_nether_ward:GetModifierPercentageCasttime() return -100 end
function modifier_imba_nether_ward:GetModifierIgnoreCastAngle() return 360 end
function modifier_imba_nether_ward:GetModifierHPRegenAmplify_Percentage() return -100 end
function modifier_imba_nether_ward:GetModifierIncomingDamage_Percentage(keys)
	if IsServer() then
		if keys.damage <= 0 then
			return -100
		end
		if keys.inflictor or keys.ability then
			return -10000
		end
		local dmg = keys.attacker:IsRealHero() and 4 or 1
		if dmg > self:GetParent():GetHealth() then
			self:GetParent():Kill(self:GetAbility(), keys.attacker)
			return -10000
		end
		self:GetParent():SetHealth(self:GetParent():GetHealth() - dmg)
		return -10000
	end
end

function modifier_imba_nether_ward:OnSpentMana(keys)
	if not IsServer() then
		return
	end
	if not IsEnemy(keys.unit, self:GetCaster()) or (keys.unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("radius") or keys.cost == 0 or not key.unit:IsHero() then
		return
	end
	if not self:GetParent():IsAlive() then
		self:Destroy()
		return
	end
	local target = keys.unit
	local mana_spent = keys.cost
	local pfx_name = mana_spent < 200 and "particles/econ/items/pugna/pugna_ward_ti5/pugna_ward_attack_light_ti_5.vpcf" or (mana_spent < 400 and "particles/econ/items/pugna/pugna_ward_ti5/pugna_ward_attack_medium_ti_5.vpcf" or "particles/econ/items/pugna/pugna_ward_ti5/pugna_ward_attack_heavy_ti_5.vpcf")
	local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	self:GetParent():EmitSound("Hero_Pugna.NetherWard.Attack")
	target:EmitSound("Hero_Pugna.NetherWard.Target")
	local damageTable = {
						victim = target,
						attacker = self:GetParent(),
						damage = mana_spent * self:GetAbility():GetSpecialValueFor("mana_multiplier"),
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)

	local forbidden_abilities = {
		"imba_pugna_nether_ward",
		"ancient_apparition_ice_blast",
		"furion_teleportation",
		"furion_wrath_of_nature",
		"imba_juggernaut_healing_ward",
		"imba_juggernaut_omni_slash",
		"imba_kunkka_x_marks_the_spot",
		"imba_lich_dark_ritual",
		"life_stealer_infest",
		"life_stealer_assimilate",
		"life_stealer_assimilate_eject",
		"imba_lina_fiery_soul",
		"imba_night_stalker_darkness",
		"imba_sandking_sand_storm",
		"imba_sandking_epicenter",
		"storm_spirit_static_remnant",
		"storm_spirit_ball_lightning",
		"imba_tinker_rearm",
		"imba_venomancer_plague_ward",
		"imba_witch_doctor_paralyzing_cask",
		"imba_witch_doctor_voodoo_restoration",
		"imba_witch_doctor_maledict",
		"imba_witch_doctor_death_ward",
		"imba_jakiro_fire_breath",
		"imba_jakiro_ice_breath",
		"alchemist_unstable_concoction",
		"alchemist_chemical_rage",
		"ursa_overpower",
		"imba_bounty_hunter_wind_walk",
		"invoker_ghost_walk",
		"imba_clinkz_strafe",
		"imba_clinkz_skeleton_walk",
		"imba_clinkz_death_pact",
		"imba_obsidian_destroyer_arcane_orb",
		"imba_obsidian_destroyer_sanity_eclipse",
		"shadow_demon_shadow_poison",
		"shadow_demon_demonic_purge",
		"phantom_lancer_doppelwalk",
		"chaos_knight_phantasm",
		"imba_phantom_assassin_phantom_strike",
		"wisp_relocate",
		"templar_assassin_refraction",
		"templar_assassin_meld",
		"naga_siren_mirror_image",
		"imba_nyx_assassin_vendetta",
		"imba_centaur_stampede",
		"ember_spirit_activate_fire_remnant",
		"legion_commander_duel",
		"phoenix_fire_spirits",
		"terrorblade_conjure_image",
		"imba_techies_land_mines",
		"imba_techies_stasis_trap",
		"techies_suicide",
		"winter_wyvern_arctic_burn",
		"imba_wraith_king_kingdom_come",
		"imba_faceless_void_chronosphere",
		"magnataur_skewer",
		"imba_tinker_march_of_the_machines",
		"riki_blink_strike",
		"riki_tricks_of_the_trade",
		"imba_necrolyte_death_pulse",
		"beastmaster_call_of_the_wild",
		"beastmaster_call_of_the_wild_boar",
		"dark_seer_ion_shell",
		"dark_seer_wall_of_replica",
		"morphling_waveform",
		"morphling_adaptive_strike",
		"morphling_replicate",
		"morphling_morph_replicate",
		"morphling_hybrid",
		"leshrac_pulse_nova",
		"rattletrap_power_cogs",
		"rattletrap_rocket_flare",
		"rattletrap_hookshot",
		"spirit_breaker_charge_of_darkness",
		"shredder_timber_chain",
		"shredder_chakram",
		"shredder_chakram_2",
		"imba_enigma_demonic_conversion",
		"spectre_haunt",
		"windrunner_focusfire",
		"viper_poison_attack",
		"arc_warden_tempest_double",
		"broodmother_insatiable_hunger",
		"weaver_time_lapse",
		"death_prophet_exorcism",
		"treant_eyes_in_the_forest",
		"treant_living_armor",
		"enchantress_impetus",
		"chen_holy_persuasion",
		"batrider_firefly",
		"undying_decay",
		"undying_tombstone",
		"tusk_walrus_kick",
		"tusk_walrus_punch",
		"tusk_frozen_sigil",
		"gyrocopter_flak_cannon",
		"elder_titan_echo_stomp_spirit",
		"visage_soul_assumption",
		"visage_summon_familiars",
		"earth_spirit_geomagnetic_grip",
		"keeper_of_the_light_recall",
		"monkey_king_boundless_strike",
		"monkey_king_mischief",
		"monkey_king_tree_dance",
		"monkey_king_primal_spring",
		"monkey_king_wukongs_command",
		"imba_skywrath_mage_concussive_shot",
		"imba_silencer_glaives_of_wisdom",
		"keeper_of_the_light_will_o_wisp",
		"zuus_cloud",
		"imba_terrorblade_reflection",
		"imba_terrorblade_conjure_image",
	}
	if IsInTable(keys.ability:GetName(), forbidden_abilities) or (keys.ability.IsNetherWardStealable and not keys.ability:IsNetherWardStealable()) or keys.ability:IsItem() or keys.ability:GetCaster():IsMagicImmune() then
		return
	end
	if self:GetAbility():GetSpecialValueFor("spell_damage") >= self:GetParent():GetHealth() then
		return
	end

	local cast_ability = keys.ability
	local cast_ability_name = cast_ability:GetName()
	local ward = self:GetParent()
	local caster = self:GetCaster()

	-- Look for the cast ability in the Nether Ward's own list
	local ability = ward:FindAbilityByName(cast_ability_name)

	-- If it was not found, add it to the Nether Ward
	if not ability then
		ward:AddAbility(cast_ability_name)
		ability = ward:FindAbilityByName(cast_ability_name)

		-- Else, activate it
	else
		ability:SetActivated(true)
	end

	-- Level up the ability
	ability:SetLevel(cast_ability:GetLevel())

	-- Refresh the ability
	ability:EndCooldown()

	local ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
	local target_point = target:GetAbsOrigin()
	local ward_position = ward:GetAbsOrigin()

	-- Special cases

	-- Dark Ritual: target a random nearby creep
	if cast_ability_name == "imba_lich_dark_ritual" then
		local creeps = FindUnitsInRadius(caster:GetTeamNumber(),
			ward:GetAbsOrigin(),
			nil,
			ability_range,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED,
			FIND_CLOSEST,
			false)

		-- If there are no creeps nearby, do nothing (ward also counts as a creep)
		if #creeps == 1 then
			return nil
		end

		-- Find the SECOND closest creep and set it as the target (since the ward counts as a creep)
		target = creeps[2]
		target_point = target:GetAbsOrigin()
		ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
	end

	-- Nether Strike: add greater bash
	if cast_ability_name == "spirit_breaker_nether_strike" then
		ward:AddAbility("spirit_breaker_greater_bash")
		local ability_bash = ward:FindAbilityByName("spirit_breaker_greater_bash")
		ability_bash:SetLevel(4)
	end

	-- Repel: Find a target to cast it on
	if cast_ability_name == "imba_omniknight_repel" then
		local allies = FindUnitsInRadius(caster:GetTeamNumber(),
			ward:GetAbsOrigin(),
			nil,
			ability_range,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false)

		-- If there are no allies nearby, cast on self
		if #allies == 1 then
			target = allies[1]
			target_point = target:GetAbsOrigin()
			ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
		else
			-- Find the closest ally and set it as the target
			target = allies[2]
			target_point = target:GetAbsOrigin()
			ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
		end
	end


	-- Meat Hook: ignore cast range
	if cast_ability_name == "imba_pudge_meat_hook" then
		ability_range = ability:GetLevelSpecialValueFor("base_range", ability:GetLevel() - 1)
	end

	-- Earth Splitter: ignore cast range
	if cast_ability_name == "elder_titan_earth_splitter" then
		ability_range = 25000
	end

	-- Shadowraze: face the caster
	if cast_ability_name == "imba_nevermore_shadowraze" then
		ward:SetForwardVector((target_point - ward_position):Normalized())
	end

	-- Reqiuem of Souls: Get target's Necromastery stack count
	if cast_ability_name == "imba_nevermore_requiem" and not ward:HasModifier("modifier_imba_necromastery_counter") and target:HasAbility("imba_nevermore_necromastery") then
		local ability_handle = ward:AddAbility("imba_nevermore_necromastery")
		ability_handle:SetLevel(4)

		-- Find target's modifier and its stacks
		if target:HasModifier("modifier_imba_necromastery_counter") then
			local stacks = target:GetModifierStackCount("modifier_imba_necromastery_counter", target)

			-- Set the ward stacks count to be the same as the caster
			if ward:HasModifier("modifier_imba_necromastery_counter") then
				local modifier_souls_handler = ward:FindModifierByName("modifier_imba_necromastery_counter")
				if modifier_souls_handler then
					modifier_souls_handler:SetStackCount(stacks)
				end
			end
		end
	end

	-- Storm Bolt: choose another target
	if cast_ability_name == "imba_sven_storm_bolt" then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), ward_position, nil, ability_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		if #enemies > 0 then
			if enemies[1]:FindAbilityByName("imba_sven_storm_bolt") then
				if #enemies > 1 then
					target = enemies[2]
				else
					return nil
				end
			else
				target = enemies[1]
			end
		else
			return nil
		end
	end

	-- Sun Strike: global cast range
	if cast_ability_name == "invoker_sun_strike" then
		ability_range = 25000
	end

	-- Eclipse: add lucent beam before cast
	if cast_ability_name == "luna_eclipse" then
		if not ward:FindAbilityByName("luna_lucent_beam") then
			ward:AddAbility("luna_lucent_beam")
		end
		local ability_lucent = ward:FindAbilityByName("luna_lucent_beam")
		ability_lucent:SetLevel(4)
	end

	-- Decide which kind of targetting to use
	local ability_behavior = ability:GetBehavior()
	local ability_target_team = ability:GetAbilityTargetTeam()

	-- If the ability is hidden, reveal it and remove the hidden binary sum
	if ability:IsHidden() then
		ability:SetHidden(false)
		ability_behavior = ability_behavior - 1
	end

	-- Memorize if an ability was actually cast
	local ability_was_used = false

	if ability_behavior == DOTA_ABILITY_BEHAVIOR_NONE then
	--Do nothing, not suppose to happen

	-- Toggle ability
	elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_TOGGLE == 0 then
		ability:ToggleAbility()
		ability_was_used = true

		-- Point target ability
	elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_POINT == 0 then

		-- If the ability targets allies, use it on the ward's vicinity
		if ability_target_team == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
			ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_POSITION, Position = ward:GetAbsOrigin(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
			ability_was_used = true

			-- Else, use it as close as possible to the enemy
		else

			-- If target is not in range of the ability, use it on its general direction
			if ability_range > 0 and (target_point - ward_position):Length2D() > ability_range then
				target_point = ward_position + (target_point - ward_position):Normalized() * (ability_range - 50)
			end
			ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_POSITION, Position = target_point, AbilityIndex = ability:GetEntityIndex(), Queue = queue})
			ability_was_used = true
		end

		-- Unit target ability
	elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_UNIT_TARGET == 0 then

		-- If the ability targets allies, use it on a random nearby ally
		if ability_target_team == DOTA_UNIT_TARGET_TEAM_FRIENDLY then

			-- Find nearby allies
			local allies = FindUnitsInRadius(caster:GetTeamNumber(), ward_position, nil, ability_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			-- If there is at least one ally nearby, cast the ability
			if #allies > 0 then
				ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = allies[1]:GetEntityIndex(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
				ability_was_used = true
			end

			-- If not, try to use it on the original caster
		elseif (target_point - ward_position):Length2D() <= ability_range then
			ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = target:GetEntityIndex(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
			ability_was_used = true

			-- If the original caster is too far away, cast the ability on a random nearby enemy
		else

			-- Find nearby enemies
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), ward_position, nil, ability_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			-- If there is at least one ally nearby, cast the ability
			if #enemies > 0 then
				ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = enemies[1]:GetEntityIndex(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
				ability_was_used = true
			end
		end

		-- No-target ability
	elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_NO_TARGET == 0 then
		ability:CastAbility()
		ability_was_used = true
	end

	-- Very edge cases in which the nether ward is silenced (doesn't actually cast a spell)
	if ward:IsSilenced() then
		ability_was_used	=	false
	end

	-- If an ability was actually used, reduce the ward's health
	if ability_was_used then
		self:GetParent():SetHealth(self:GetParent():GetHealth() - self:GetAbility():GetSpecialValueFor("spell_damage"))
	end

	-- Refresh the ability's cooldown and set it as inactive
	local cast_point = ability:GetCastPoint()
	Timers:CreateTimer(cast_point + 0.5, function()
		ability:SetActivated(false)
	end)
end

function modifier_imba_nether_ward:OnDestroy()
	if IsServer() then
		TrueKill(self:GetParent(), self:GetParent(), self:GetAbility())
		UTIL_Remove(self:GetParent())
	end
end

modifier_imba_nether_ward_debuff = class({})

function modifier_imba_nether_ward_debuff:IsDebuff()			return true end
function modifier_imba_nether_ward_debuff:IsHidden() 			return false end
function modifier_imba_nether_ward_debuff:IsPurgable() 			return false end
function modifier_imba_nether_ward_debuff:IsPurgeException() 	return false end
function modifier_imba_nether_ward_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE} end
function modifier_imba_nether_ward_debuff:GetModifierTotalPercentageManaRegen() return (0 - self:GetAbility():GetSpecialValueFor("mana_regen_tooltip")) end
function modifier_imba_nether_ward_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end


imba_pugna_life_drain = class({})

LinkLuaModifier("modifier_imba_life_drain_enemy", "hero/hero_pugna", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_life_drain_friend", "hero/hero_pugna", LUA_MODIFIER_MOTION_NONE)

function imba_pugna_life_drain:IsHiddenWhenStolen() 	return false end
function imba_pugna_life_drain:IsRefreshable() 			return true end
function imba_pugna_life_drain:IsStealable() 			return true end
function imba_pugna_life_drain:IsNetherWardStealable()	return true end
function imba_pugna_life_drain:GetCooldown(i) return (self:GetCaster():HasScepter() and 0 or self:GetSpecialValueFor("cooldown")) end
function imba_pugna_life_drain:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_pugna_life_drain_end")
	if ability then
		ability:SetLevel(1)
	end
end

function imba_pugna_life_drain:CastFilterResultTarget(target)
	if target == self:GetCaster() or target:IsBuilding() or target:IsOther() or target:IsCourier() then
		return UF_FAIL_CUSTOM
	end
	if IsServer() then
		local buffs = self:GetCaster():FindAllModifiersByName("modifier_imba_life_drain_enemy")
		for _, buff in pairs(buffs) do
			if target:entindex() == buff:GetStackCount() then
				return UF_FAIL_CUSTOM
			end
		end
	end
end

function imba_pugna_life_drain:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	else
		return "#dota_hud_error_cant_cast_on_other"
	end
end

function imba_pugna_life_drain:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local target_ent = target:entindex()
	if IsEnemy(caster, target) then
		caster:AddNewModifier(caster, self, "modifier_imba_life_drain_enemy", {target = target_ent})
	else
		target_ent = caster:entindex()
		caster:AddNewModifier(target, self, "modifier_imba_life_drain_enemy", {target = target_ent, ally = 1})
	end
	caster:EmitSound("Hero_Pugna.LifeDrain.Cast")
	target:EmitSound("Hero_Pugna.LifeDrain.Target")
	target:EmitSound("Hero_Pugna.LifeDrain.Loop")
	if not caster:HasModifier("modifier_imba_life_drain_enemy") then--and not caster:HasModifier("modifier_imba_life_drain_friend") then
		caster:EmitSound("Hero_Pugna.LifeDrain.Loop")
	end
end

modifier_imba_life_drain_enemy = class({})

function modifier_imba_life_drain_enemy:IsDebuff()			return false end
function modifier_imba_life_drain_enemy:IsHidden() 			return true end
function modifier_imba_life_drain_enemy:IsPurgable() 		return false end
function modifier_imba_life_drain_enemy:IsPurgeException() 	return false end
function modifier_imba_life_drain_enemy:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_life_drain_enemy:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_rate"))
		self.target = EntIndexToHScript(keys.target)
		self.ally = keys.ally
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_neck", self:GetCaster():GetAbsOrigin(), true)
		if self.ally then
			ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		end
		ParticleManager:SetParticleControlEnt(self.pfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.pfx, 11, Vector(0,0,0))
		local ent = keys.target
		if self:GetCaster() ~= self:GetAbility():GetCaster() then
			ent = self:GetCaster():entindex()
		end
		self:SetStackCount(ent)
	end
end

function modifier_imba_life_drain_enemy:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self.target
	if caster:IsSilenced() or IsHardDisabled(caster) or (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() > (self:GetAbility():GetSpecialValueFor("break_range") + self:GetCaster():GetCastRangeBonus()) or not target:IsAlive() or target:IsOutOfGame() then
		self:Destroy()
		return
	end
	if not caster:CanEntityBeSeenByMyTeam(target) and not caster:HasTalent("special_bonus_imba_pugna_1") then
		self:Destroy()
		return
	end
	local ability = self:GetAbility()
	local dmg = (ability:GetSpecialValueFor("health_drain") + (caster:HasScepter() and (ability:GetSpecialValueFor("health_drain_scepter") / 100) * target:GetHealth() or 0)) / (1.0 / ability:GetSpecialValueFor("tick_rate"))
	if self.ally then
		dmg = dmg / 2
	end
	local damageTable = {
						victim = target,
						attacker = caster,
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	local dmg_done = ApplyDamage(damageTable)
	if self.ally then
		dmg_done = dmg_done * 2
	end
	if caster:GetHealth() ~= caster:GetMaxHealth() then
		ParticleManager:SetParticleControl(self.pfx, 11, Vector(0,0,0))
		caster:Heal(dmg_done, ability)
	else
		ParticleManager:SetParticleControl(self.pfx, 11, Vector(1,0,0))
		caster:SetMana(math.min(caster:GetMaxMana(), caster:GetMana() + dmg_done))
	end
end

function modifier_imba_life_drain_enemy:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.target = nil
		self.pfx = nil
		self:GetCaster():StopSound("Hero_Pugna.LifeDrain.Cast")
		self:GetParent():StopSound("Hero_Pugna.LifeDrain.Target")
		self:GetParent():StopSound("Hero_Pugna.LifeDrain.Loop")
		if not self:GetCaster():HasModifier("modifier_imba_life_drain_enemy") and not self:GetCaster():HasModifier("modifier_imba_life_drain_friend") then
			self:GetCaster():StopSound("Hero_Pugna.LifeDrain.Loop")
		end
	end
end

imba_pugna_life_drain_end = class({})

function imba_pugna_life_drain_end:IsHiddenWhenStolen() 	return false end
function imba_pugna_life_drain_end:IsRefreshable() 			return true end
function imba_pugna_life_drain_end:IsStealable() 			return false end
function imba_pugna_life_drain_end:IsNetherWardStealable()	return false end

function imba_pugna_life_drain_end:OnSpellStart()
	local buffs = self:GetCaster():FindAllModifiersByName("modifier_imba_life_drain_enemy")
	for _, buff in pairs(buffs) do
		if buff.ally then
			buff:Destroy() 
		end
	end
end