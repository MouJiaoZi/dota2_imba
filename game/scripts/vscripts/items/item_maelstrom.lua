--[[	Author: Firetoad
		Date:	19.07.2016	]]

function Maelstrom( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local sound_proc = keys.sound_proc
	local sound_bounce = keys.sound_bounce
	local particle_bounce = keys.particle_bounce
	local particle_charge = keys.particle_charge
	local modifier_charge = keys.modifier_charge

	-- If the target is a building, do nothing
	if target:IsBuilding() then
		return nil
	end

	-- Parameters
	local proc_count = ability:GetSpecialValueFor("proc_count")
	local bounce_damage = ability:GetSpecialValueFor("bounce_damage")
	local bounce_radius = ability:GetSpecialValueFor("bounce_radius")

	-- Add a stack of the charge modifier
	AddStacks(ability, caster, caster, modifier_charge, 1, true)

	-- If this isn't enough charges to proc the chain lightning, do nothing else
	local charge_count = caster:GetModifierStackCount(modifier_charge, caster)
	if charge_count < proc_count then
		return nil
	end

	-- Else, remove the charge counter and proc the chain lightning
	caster:RemoveModifierByName(modifier_charge)
		
	-- Play initial sound
	caster:EmitSound(sound_proc)

	-- Play first bounce sound
	target:EmitSound(sound_bounce)

	-- Play first particle
	local bounce_pfx = ParticleManager:CreateParticle(particle_bounce, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(bounce_pfx, 2, Vector(1, 1, 1))
	ParticleManager:ReleaseParticleIndex(bounce_pfx)

	-- Damage initial target
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = bounce_damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- Initialize targets hit table
	local enemies_hit = {}
	enemies_hit[1] = target

	-- Bounce around and ZAP THEM!
	local keep_bouncing = true
	local current_bounce_source = target
	local current_bounce_source_loc = target:GetAbsOrigin()
	while keep_bouncing do
		keep_bouncing = false

		-- Search for valid bounce targets
		local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), current_bounce_source_loc, nil, bounce_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
		for _,enemy in pairs(nearby_enemies) do
			local is_valid_target = true
			for _,hit_enemy in pairs(enemies_hit) do
				if enemy == hit_enemy then is_valid_target = false end
			end

			-- If this enemy is a valid bounce target, stop searching and bounce
			if is_valid_target then

				-- Play bounce particle
				bounce_pfx = ParticleManager:CreateParticle(particle_bounce, PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(bounce_pfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(bounce_pfx, 1, current_bounce_source, PATTACH_POINT_FOLLOW, "attach_hitloc", current_bounce_source_loc, true)
				ParticleManager:SetParticleControl(bounce_pfx, 2, Vector(1, 1, 1))
				ParticleManager:ReleaseParticleIndex(bounce_pfx)

				-- Damage bounce target
				ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = bounce_damage, damage_type = DAMAGE_TYPE_MAGICAL})

				-- Update bounce parameters
				current_bounce_source = enemy
				current_bounce_source_loc = enemy:GetAbsOrigin()
				enemies_hit[#enemies_hit + 1] = enemy
				keep_bouncing = true
				break
			end
		end
	end
end

function Mjollnir( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_shield = keys.modifier_shield
	local sound_cast = keys.sound_cast
	local sound_loop = keys.sound_loop

	-- Apply the modifier to the target
	ability:ApplyDataDrivenModifier(caster, target, modifier_shield, {})

	-- Play cast sound
	target:EmitSound(sound_cast)

	-- End any previously existing sound loop, and create a new one
	StopSoundEvent(sound_loop, target)
	target:EmitSound(sound_loop)
end

function MjollnirProc( keys )
	local attacker = keys.attacker
	local shield_owner = keys.unit
	local ability = keys.ability
	local sound_hit = keys.sound_hit
	local particle_static = keys.particle_static
	local modifier_slow = keys.modifier_slow
	local modifier_charge = keys.modifier_charge

	-- If the attacker and the shield owner are in the same team, do nothing
	if attacker:GetTeam() == shield_owner:GetTeam() then
		return nil
	end

	-- Parameters
	local static_proc_count = ability:GetSpecialValueFor("static_proc_count")
	local static_damage = ability:GetSpecialValueFor("static_damage")
	local static_radius = ability:GetSpecialValueFor("static_radius")

	-- Add a stack of the charge modifier
	AddStacks(ability, shield_owner, shield_owner, modifier_charge, 1, true)

	-- If this isn't enough charges to proc the chain lightning, do nothing else
	local charge_count = shield_owner:GetModifierStackCount(modifier_charge, shield_owner)
	if charge_count < static_proc_count then
		return nil
	end

	-- Else, remove the charge counter and ZAP THEM!
	shield_owner:RemoveModifierByName(modifier_charge)

	local shield_owner_loc = shield_owner:GetAbsOrigin()
	local static_origin = shield_owner_loc + Vector(0, 0, 200)
	
	-- Search for nearby valid targets
	local nearby_enemies = FindUnitsInRadius(shield_owner:GetTeamNumber(), shield_owner_loc, nil, static_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	for _,enemy in pairs(nearby_enemies) do
		
		-- Play hit sound
		enemy:EmitSound(sound_hit)

		-- Play particle
		local static_pfx = ParticleManager:CreateParticle(particle_static, PATTACH_ABSORIGIN_FOLLOW, shield_owner)
		ParticleManager:SetParticleControlEnt(static_pfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(static_pfx, 1, static_origin)
		ParticleManager:ReleaseParticleIndex(static_pfx)

		-- Apply damage
		ApplyDamage({attacker = shield_owner, victim = enemy, ability = ability, damage = static_damage, damage_type = DAMAGE_TYPE_MAGICAL})

		-- Apply slow modifier
		ability:ApplyDataDrivenModifier(shield_owner, enemy, modifier_slow, {})
	end
end

function MjollnirEnd( keys )
	local target = keys.target
	local sound_end = keys.sound_end
	local sound_loop = keys.sound_loop

	-- Play end sound
	target:EmitSound(sound_end)

	-- Stop sound loop
	StopSoundEvent(sound_loop, target)
end


LinkLuaModifier("modifier_item_imba_maelstrom_charge", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)

modifier_item_imba_maelstrom_charge = class({})

function modifier_item_imba_maelstrom_charge:IsDebuff()			return false end
function modifier_item_imba_maelstrom_charge:IsHidden() 		return false end
function modifier_item_imba_maelstrom_charge:IsPurgable() 		return false end
function modifier_item_imba_maelstrom_charge:IsPurgeException() return false end

item_imba_maelstrom = class({})

LinkLuaModifier("modifier_imba_maelstrom_passive", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)

function item_imba_maelstrom:GetIntrinsicModifierName() return "modifier_imba_maelstrom_passive" end

modifier_imba_maelstrom_passive = class({})

function modifier_imba_maelstrom_passive:IsDebuff()			return false end
function modifier_imba_maelstrom_passive:IsHidden() 		return true end
function modifier_imba_maelstrom_passive:IsPurgable() 		return false end
function modifier_imba_maelstrom_passive:IsPurgeException() return false end
function modifier_imba_maelstrom_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_maelstrom_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_maelstrom_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_maelstrom_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end

function modifier_imba_maelstrom_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() or not self:GetParent().splitattack then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_maelstrom_charge", {duration = self:GetAbility():GetSpecialValueFor("proc_duration")})
	buff:SetStackCount(buff:GetStackCount() + 1)
	if buff:GetStackCount() >= self:GetAbility():GetSpecialValueFor("proc_count") then
		buff:SetStackCount(0)
		buff:Destroy()
		self:GetParent():EmitSound("Item.Maelstrom.Chain_Lightning")
		local units = {}
		table.insert(units, keys.target)
		for i, aunit in pairs(units) do
			local units1 = FindUnitsInRadius(self:GetParent():GetTeamNumber(), aunit:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("bounce_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
			for _, unit1 in pairs(units1) do
				local no_yet = true
				for _, unit in pairs(units) do
					if unit == unit1 or unit1 == self:GetParent() then
						no_yet = false
						break
					end
				end
				if no_yet then
					table.insert(units, unit1)
					break
				end
			end
		end
		table.insert(units, 1, self:GetParent())
		for k, unit in pairs(units) do
			if k < #units then
				units[k+1]:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
				local pfx = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, unit)
				ParticleManager:SetParticleControlEnt(pfx, 0, units[k], PATTACH_POINT_FOLLOW, (units[k] == caster and "attach_attack2" or "attach_hitloc"), units[k]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, units[k+1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[k+1 >= #units and k or k+1]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(pfx, 2, Vector(3,3,3))
				ParticleManager:ReleaseParticleIndex(pfx)
				local damageTable = {
									victim = units[k+1],
									attacker = self:GetCaster(),
									damage = self:GetAbility():GetSpecialValueFor("bounce_damage"),
									damage_type = DAMAGE_TYPE_MAGICAL,
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self:GetAbility(), --Optional.
									}
				ApplyDamage(damageTable)
			end
		end
	end
end



item_imba_mjollnir = class({})

LinkLuaModifier("modifier_imba_mjollnir_passive", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mjollnir_shield", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mjollnir_slow", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)

function item_imba_mjollnir:GetIntrinsicModifierName() return "modifier_imba_mjollnir_passive" end

function item_imba_mjollnir:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_item_imba_mjollnir_shield", {duration = self:GetSpecialValueFor("static_duration")})
	target:EmitSound("DOTA_Item.Mjollnir.Activate")
end

modifier_imba_mjollnir_passive = class({})

function modifier_imba_mjollnir_passive:IsDebuff()			return false end
function modifier_imba_mjollnir_passive:IsHidden() 			return true end
function modifier_imba_mjollnir_passive:IsPurgable() 		return false end
function modifier_imba_mjollnir_passive:IsPurgeException() 	return false end
function modifier_imba_mjollnir_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_mjollnir_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_mjollnir_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_mjollnir_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end

function modifier_imba_mjollnir_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() or not self:GetParent().splitattack then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_maelstrom_charge", {duration = self:GetAbility():GetSpecialValueFor("proc_duration")})
	buff:SetStackCount(buff:GetStackCount() + 1)
	if buff:GetStackCount() >= self:GetAbility():GetSpecialValueFor("proc_count") then
		buff:SetStackCount(0)
		buff:Destroy()
		self:GetParent():EmitSound("Item.Maelstrom.Chain_Lightning")
		local units = {}
		table.insert(units, keys.target)
		for i, aunit in pairs(units) do
			local units1 = FindUnitsInRadius(self:GetParent():GetTeamNumber(), aunit:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("bounce_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
			for _, unit1 in pairs(units1) do
				local no_yet = true
				for _, unit in pairs(units) do
					if unit == unit1 or unit1 == self:GetParent() then
						no_yet = false
						break
					end
				end
				if no_yet then
					table.insert(units, unit1)
					break
				end
			end
		end
		table.insert(units, 1, self:GetParent())
		for k, unit in pairs(units) do
			if k < #units then
				units[k+1]:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
				local pfx = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, unit)
				ParticleManager:SetParticleControlEnt(pfx, 0, units[k], PATTACH_POINT_FOLLOW, (units[k] == caster and "attach_attack2" or "attach_hitloc"), units[k]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, units[k+1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[k+1 >= #units and k or k+1]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(pfx, 2, Vector(3,math.random(1,3),math.random(1,3)))
				ParticleManager:ReleaseParticleIndex(pfx)
				local damageTable = {
									victim = units[k+1],
									attacker = self:GetCaster(),
									damage = self:GetAbility():GetSpecialValueFor("bounce_damage"),
									damage_type = DAMAGE_TYPE_MAGICAL,
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self:GetAbility(), --Optional.
									}
				ApplyDamage(damageTable)
			end
		end
	end
end

modifier_item_imba_mjollnir_shield = class({})

function modifier_item_imba_mjollnir_shield:IsDebuff()			return false end
function modifier_item_imba_mjollnir_shield:IsHidden() 			return false end
function modifier_item_imba_mjollnir_shield:IsPurgable() 		return true end
function modifier_item_imba_mjollnir_shield:IsPurgeException() 	return true end
function modifier_item_imba_mjollnir_shield:GetEffectName() return "particles/items2_fx/mjollnir_shield.vpcf" end
function modifier_item_imba_mjollnir_shield:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_imba_mjollnir_shield:GetStatusEffectName() return "particles/status_fx/status_effect_mjollnir_shield.vpcf" end
function modifier_item_imba_mjollnir_shield:StatusEffectPriority() return 15 end
function modifier_item_imba_mjollnir_shield:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:GetParent():EmitSound("DOTA_Item.Mjollnir.Loop")
	end
end
function modifier_item_imba_mjollnir_shield:OnDestroy()
	self.ability = nil
	if IsServer() then
		self:GetParent():StopSound("DOTA_Item.Mjollnir.Loop")
		self:GetParent():EmitSound("DOTA_Item.Mjollnir.DeActivate")
	end
end
function modifier_item_imba_mjollnir_shield:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_item_imba_mjollnir_shield:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() or not IsHeroDamage(keys.attacker, keys.damage) then
		return
	end
	self:SetStackCount(self:GetStackCount() + 1)
	if self:GetStackCount() >= self.ability:GetSpecialValueFor("static_proc_count") then
		self:SetStackCount(0)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("static_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
		self:GetParent():EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
		for _, enemy in pairs(enemies) do
			local pfx = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, enemy)
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(pfx, 2, Vector(10,math.random(1,10),math.random(1,10)))
			ParticleManager:ReleaseParticleIndex(pfx)
			ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = self.ability:GetSpecialValueFor("static_damage"), ability = self.ability, damage_type = DAMAGE_TYPE_MAGICAL})
			enemy:AddNewModifier(self:GetCaster(), self.ability, "modifier_item_imba_mjollnir_slow", {duration = self.ability:GetSpecialValueFor("static_slow_duration")})
		end
	end
end

modifier_item_imba_mjollnir_slow = class({})

function modifier_item_imba_mjollnir_slow:IsDebuff()			return true end
function modifier_item_imba_mjollnir_slow:IsHidden() 			return false end
function modifier_item_imba_mjollnir_slow:IsPurgable() 			return true end
function modifier_item_imba_mjollnir_slow:IsPurgeException() 	return true end
function modifier_item_imba_mjollnir_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_mjollnir_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("static_slow")) end
function modifier_item_imba_mjollnir_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("static_slow")) end