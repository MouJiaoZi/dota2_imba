

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
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() or not self:GetParent().splitattack or not keys.target:IsAlive() then
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
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() or not self:GetParent().splitattack or not keys.target:IsAlive() then
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