item_imba_maelstrom = class({})

LinkLuaModifier("modifier_imba_maelstrom_passive", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_maelstrom_unique", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)

function item_imba_maelstrom:GetIntrinsicModifierName() return "modifier_imba_maelstrom_passive" end

modifier_imba_maelstrom_passive = class({})

function modifier_imba_maelstrom_passive:IsDebuff()			return false end
function modifier_imba_maelstrom_passive:IsHidden() 		return true end
function modifier_imba_maelstrom_passive:IsPurgable() 		return false end
function modifier_imba_maelstrom_passive:IsPurgeException() return false end
function modifier_imba_maelstrom_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_maelstrom_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_maelstrom_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_maelstrom_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end

function modifier_imba_maelstrom_passive:OnCreated()
	self:SetMaelStromParticle()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_maelstrom_unique", {})
	end
end

function modifier_imba_maelstrom_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_maelstrom_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_maelstrom_unique")
	end
end

modifier_imba_maelstrom_unique = class({})

function modifier_imba_maelstrom_unique:IsDebuff()			return false end
function modifier_imba_maelstrom_unique:IsHidden() 			return true end
function modifier_imba_maelstrom_unique:IsPurgable() 		return false end
function modifier_imba_maelstrom_unique:IsPurgeException() 	return false end
function modifier_imba_maelstrom_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_maelstrom_unique:OnCreated()
	self:SetMaelStromParticle()
	self.ability = self:GetAbility()
end

function modifier_imba_maelstrom_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or not keys.target:IsUnit() or not self:GetParent().splitattack or not keys.target:IsAlive() then
		return
	end
	if PseudoRandom:RollPseudoRandom(self.ability, self.ability:GetSpecialValueFor("proc_chance")) then
		self:GetParent():EmitSound("Item.Maelstrom.Chain_Lightning")
		local units = {}
		units[#units + 1] = keys.target
		for i, aunit in pairs(units) do
			local units1 = FindUnitsInRadius(self:GetParent():GetTeamNumber(), aunit:GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("bounce_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			for _, unit1 in pairs(units1) do
				local no_yet = true
				for _, unit in pairs(units) do
					if unit == unit1 or unit1 == self:GetParent() then
						no_yet = false
						break
					end
				end
				if no_yet then
					units[#units + 1] = unit1
					break
				end
			end
		end
		table.insert(units, 1, self:GetParent())
		for k, unit in pairs(units) do
			if k < #units then
				units[k+1]:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
				local pfx = ParticleManager:CreateParticle(self.chain_pfx, PATTACH_POINT_FOLLOW, unit)
				ParticleManager:SetParticleControlEnt(pfx, 0, units[k], PATTACH_POINT_FOLLOW, (units[k] == caster and "attach_attack1" or "attach_hitloc"), units[k]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, units[k+1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[k+1 >= #units and k or k+1]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(pfx, 2, Vector(1,1,1))
				ParticleManager:SetParticleControl(pfx, 15, self.color)
				ParticleManager:ReleaseParticleIndex(pfx)
				local damageTable = {
									victim = units[k+1],
									attacker = self:GetCaster(),
									damage = self.ability:GetSpecialValueFor("bounce_damage"),
									damage_type = DAMAGE_TYPE_PURE,
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self:GetAbility(), --Optional.
									}
				ApplyDamage(damageTable)
			end
		end
	end
end

function modifier_imba_maelstrom_unique:OnDestroy()
	self.chain_pfx = nil
	self.shield_pfx = nil
	self.color = nil
	self.ability = nil
end


item_imba_mjollnir = class({})

LinkLuaModifier("modifier_imba_mjollnir_passive", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_mjollnir_unique", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mjollnir_shield", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mjollnir_slow", "items/item_maelstrom", LUA_MODIFIER_MOTION_NONE)

function item_imba_mjollnir:GetIntrinsicModifierName() return "modifier_imba_mjollnir_passive" end

function item_imba_mjollnir:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:RemoveModifierByName("modifier_item_imba_mjollnir_shield")
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

function modifier_imba_mjollnir_passive:OnCreated()
	self:SetMaelStromParticle()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_mjollnir_unique", {})
	end
end

function modifier_imba_mjollnir_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_mjollnir_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_mjollnir_unique")
	end
end

modifier_imba_mjollnir_unique = class({})

function modifier_imba_mjollnir_unique:IsDebuff()			return false end
function modifier_imba_mjollnir_unique:IsHidden() 			return true end
function modifier_imba_mjollnir_unique:IsPurgable() 		return false end
function modifier_imba_mjollnir_unique:IsPurgeException() 	return false end
function modifier_imba_mjollnir_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_mjollnir_unique:OnCreated()
	self:SetMaelStromParticle()
	self.ability = self:GetAbility()
end

function modifier_imba_mjollnir_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() or not self:GetParent().splitattack or not keys.target:IsAlive() then
		return
	end
	if PseudoRandom:RollPseudoRandom(self.ability, self.ability:GetSpecialValueFor("proc_chance")) then
		self:GetParent():EmitSound("Item.Maelstrom.Chain_Lightning")
		local units = {}
		units[#units + 1] = keys.target
		for i, aunit in pairs(units) do
			local units1 = FindUnitsInRadius(self:GetParent():GetTeamNumber(), aunit:GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("bounce_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			for _, unit1 in pairs(units1) do
				local no_yet = true
				for _, unit in pairs(units) do
					if unit == unit1 or unit1 == self:GetParent() then
						no_yet = false
						break
					end
				end
				if no_yet then
					units[#units + 1] = unit1
					break
				end
			end
		end
		table.insert(units, 1, self:GetParent())
		for k, unit in pairs(units) do
			if k < #units then
				units[k+1]:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
				local pfx = ParticleManager:CreateParticle(self.chain_pfx, PATTACH_POINT_FOLLOW, unit)
				ParticleManager:SetParticleControlEnt(pfx, 0, units[k], PATTACH_POINT_FOLLOW, (units[k] == caster and "attach_attack1" or "attach_hitloc"), units[k]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, units[k+1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[k+1 >= #units and k or k+1]:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(pfx, 2, Vector(1,1,1))
				ParticleManager:SetParticleControl(pfx, 15, self.color)
				ParticleManager:ReleaseParticleIndex(pfx)
				local damageTable = {
									victim = units[k+1],
									attacker = self:GetCaster(),
									damage = self.ability:GetSpecialValueFor("bounce_damage"),
									damage_type = DAMAGE_TYPE_PURE,
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self:GetAbility(), --Optional.
									}
				ApplyDamage(damageTable)
			end
		end
	end
end

function modifier_imba_mjollnir_unique:OnDestroy()
	self.chain_pfx = nil
	self.shield_pfx = nil
	self.color = nil
	self.ability = nil
end


modifier_item_imba_mjollnir_shield = class({})

function modifier_item_imba_mjollnir_shield:IsDebuff()			return false end
function modifier_item_imba_mjollnir_shield:IsHidden() 			return false end
function modifier_item_imba_mjollnir_shield:IsPurgable() 		return true end
function modifier_item_imba_mjollnir_shield:IsPurgeException() 	return true end
function modifier_item_imba_mjollnir_shield:GetStatusEffectName() return "particles/status_fx/status_effect_mjollnir_shield.vpcf" end
function modifier_item_imba_mjollnir_shield:StatusEffectPriority() return 15 end
function modifier_item_imba_mjollnir_shield:OnCreated()
	self.ability = self.ability or self:GetAbility()
	self:SetMaelStromParticle()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle(self.shield_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 15, self.color)
		self:AddParticle(pfx, false, false, 15, false, false)
		self:GetParent():EmitSound("DOTA_Item.Mjollnir.Loop")
	end
end
function modifier_item_imba_mjollnir_shield:OnDestroy()
	self.ability = nil
	self.chain_pfx = nil
	self.shield_pfx = nil
	self.color = nil
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
			local pfx = ParticleManager:CreateParticle(self.chain_pfx, PATTACH_POINT_FOLLOW, enemy)
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			local change = RandomFloat(1.0, 2.0)
			ParticleManager:SetParticleControl(pfx, 2, Vector(RandomFloat(1.0, 2.0),RandomFloat(1.0, 2.0),RandomFloat(1.0, 2.0)))
			ParticleManager:SetParticleControl(pfx, 15, self.color)
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