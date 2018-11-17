


LinkLuaModifier("modifier_item_imba_desolator_armor_debuff", "items/item_desolator", LUA_MODIFIER_MOTION_NONE)

modifier_item_imba_desolator_armor_debuff = class({})

function modifier_item_imba_desolator_armor_debuff:IsDebuff()			return true end
function modifier_item_imba_desolator_armor_debuff:IsHidden() 			return false end
function modifier_item_imba_desolator_armor_debuff:IsPurgable() 		return false end
function modifier_item_imba_desolator_armor_debuff:IsPurgeException() 	return false end
function modifier_item_imba_desolator_armor_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_BONUS_DAY_VISION} end
function modifier_item_imba_desolator_armor_debuff:GetModifierPhysicalArmorBonus() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stack_armor")) end
function modifier_item_imba_desolator_armor_debuff:GetBonusNightVision() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stack_vision")) end
function modifier_item_imba_desolator_armor_debuff:GetBonusDayVision() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stack_vision")) end

LinkLuaModifier("modifier_desolator_active_thinker", "items/item_desolator", LUA_MODIFIER_MOTION_NONE)

modifier_desolator_active_thinker = class({})

function modifier_desolator_active_thinker:OnDestroy()
	if IsServer() then
		self:GetParent().hitted = nil
	end
end

item_imba_desolator = class({})

LinkLuaModifier("modifier_imba_desolator_passive", "items/item_desolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_desolator_unique", "items/item_desolator", LUA_MODIFIER_MOTION_NONE)

function item_imba_desolator:GetIntrinsicModifierName() return "modifier_imba_desolator_passive" end

function item_imba_desolator:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()

	caster:EmitSound("Imba.DesolatorCast")

	local active_range = self:GetSpecialValueFor("active_range") + caster:GetCastRangeBonus()
	local projectile_count = self:GetSpecialValueFor("projectile_count")
	local projectile_radius = self:GetSpecialValueFor("projectile_radius")
	local projectile_distance = self:GetSpecialValueFor("projectile_distance")
	local projectile_speed = self:GetSpecialValueFor("projectile_speed")

	local caster_pos = caster:GetAbsOrigin()
	local direction = (pos - caster_pos):Normalized()
	local projectile_line_start = RotatePosition(caster_pos, QAngle(0, 90, 0), caster_pos + direction * math.floor(projectile_count / 2) * projectile_distance)
	local projectile_line_direction = (caster_pos - projectile_line_start):Normalized()

	self.think = CreateModifierThinker(caster, self, "modifier_desolator_active_thinker", {duration = 3.0}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	self.think.hitted = {}

	-- Launch projectiles
	for i = 1, projectile_count do
		local projectile_position = projectile_line_start + projectile_line_direction * projectile_distance * (i - 1)

		local info = 
		{
			Ability = self,
			EffectName = "particles/item/desolator/desolator_active_projectile.vpcf",
			vSpawnOrigin = projectile_position,
			fDistance = active_range,
			fStartRadius = 100,
			fEndRadius = 100,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
			fExpireTime	= GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = direction * projectile_speed,
			bProvidesVision	= false,
		}
		ProjectileManager:CreateLinearProjectile(info)
	end
end


function item_imba_desolator:OnProjectileHit(target, location)
	if not target then
		return
	end
	if not IsInTable(target, self.think.hitted) then
		table.insert(self.think.hitted, target)
		target:EmitSound("Item_Desolator.Target")
		ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("active_damage"), damage_type = DAMAGE_TYPE_PHYSICAL})
		local buff = target:AddNewModifier(self:GetCaster(), self, "modifier_item_imba_desolator_armor_debuff", {duration = self:GetSpecialValueFor("duration")})
		buff:SetStackCount(self:GetSpecialValueFor("max_stacks"))
	end
end

modifier_imba_desolator_passive = class({})

function modifier_imba_desolator_passive:IsDebuff()			return false end
function modifier_imba_desolator_passive:IsHidden() 		return true end
function modifier_imba_desolator_passive:IsPurgable() 		return false end
function modifier_imba_desolator_passive:IsPurgeException() return false end
function modifier_imba_desolator_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_desolator_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_desolator_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end

function modifier_imba_desolator_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_desolator_unique", {})
	end
end

function modifier_imba_desolator_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_desolator_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_desolator_unique")
	end
end

modifier_imba_desolator_unique = class({})

function modifier_imba_desolator_unique:IsDebuff()			return false end
function modifier_imba_desolator_unique:IsHidden() 			return true end
function modifier_imba_desolator_unique:IsPurgable() 		return false end
function modifier_imba_desolator_unique:IsPurgeException() 	return false end
function modifier_imba_desolator_unique:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		IMBA:ChangeUnitProjectile(self:GetParent(), self)
	end
end
function modifier_imba_desolator_unique:OnDestroy()
	self.ability = nil 
	if IsServer() then
		IMBA:ChangeUnitProjectile(self:GetParent(), nil)
	end
end
function modifier_imba_desolator_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_desolator_unique:GetIMBAProjectileName() return "particles/items_fx/desolator_projectile.vpcf" end

function modifier_imba_desolator_unique:OnAttackLanded(keys)
	if not IsServer() or keys.attacker ~= self:GetParent() or self:GetParent():HasModifier("modifier_imba_desolator2_unique")  or not self:GetParent().splitattack then
		return
	end
	local has = false
	if keys.target:HasModifier("modifier_item_imba_desolator_armor_debuff") then
		has = true
	end
	local buff = keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_desolator_armor_debuff", {duration = self.ability:GetSpecialValueFor("duration")})
	if not has then
		buff:SetStackCount(self.ability:GetSpecialValueFor("base_stacks"))
	elseif buff:GetStackCount() < self.ability:GetSpecialValueFor("max_stacks") then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	keys.target:EmitSound("Item_Desolator.Target")
end

item_imba_desolator_2 = class({})

LinkLuaModifier("modifier_imba_desolator2_passive", "items/item_desolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_desolator2_unique", "items/item_desolator", LUA_MODIFIER_MOTION_NONE)

function item_imba_desolator_2:GetIntrinsicModifierName() return "modifier_imba_desolator2_passive" end

function item_imba_desolator_2:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()

	caster:EmitSound("Imba.DesolatorCast")

	local active_range = self:GetSpecialValueFor("active_range") + caster:GetCastRangeBonus()
	local projectile_count = self:GetSpecialValueFor("projectile_count")
	local projectile_radius = self:GetSpecialValueFor("projectile_radius")
	local projectile_distance = self:GetSpecialValueFor("projectile_distance")
	local projectile_speed = self:GetSpecialValueFor("projectile_speed")

	local caster_pos = caster:GetAbsOrigin()
	local direction = (pos - caster_pos):Normalized()
	local projectile_line_start = RotatePosition(caster_pos, QAngle(0, 90, 0), caster_pos + direction * math.floor(projectile_count / 2) * projectile_distance)
	local projectile_line_direction = (caster_pos - projectile_line_start):Normalized()

	self.think = CreateModifierThinker(caster, self, "modifier_desolator_active_thinker", {duration = 3.0}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	self.think.hitted = {}

	-- Launch projectiles
	for i = 1, projectile_count do
		local projectile_position = projectile_line_start + projectile_line_direction * projectile_distance * (i - 1)

		local info = 
		{
			Ability = self,
			EffectName = "particles/item/desolator/desolator_active_projectile.vpcf",
			vSpawnOrigin = projectile_position,
			fDistance = active_range,
			fStartRadius = 100,
			fEndRadius = 100,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
			fExpireTime	= GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = direction * projectile_speed,
			bProvidesVision	= false,
		}
		ProjectileManager:CreateLinearProjectile(info)
	end
end


function item_imba_desolator_2:OnProjectileHit(target, location)
	if not target then
		return
	end
	if not IsInTable(target, self.think.hitted) then
		table.insert(self.think.hitted, target)
		target:EmitSound("Item_Desolator.Target")
		ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("active_damage"), damage_type = DAMAGE_TYPE_PHYSICAL})
		local buff = target:AddNewModifier(self:GetCaster(), self, "modifier_item_imba_desolator_armor_debuff", {duration = self:GetSpecialValueFor("duration")})
		if buff:GetStackCount() < self:GetSpecialValueFor("active_stacks") then
			buff:SetStackCount(self:GetSpecialValueFor("active_stacks"))
		end
	end
end

modifier_imba_desolator2_passive = class({})

function modifier_imba_desolator2_passive:IsDebuff()			return false end
function modifier_imba_desolator2_passive:IsHidden() 		return true end
function modifier_imba_desolator2_passive:IsPurgable() 		return false end
function modifier_imba_desolator2_passive:IsPurgeException() return false end
function modifier_imba_desolator2_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_desolator2_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_desolator2_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end

function modifier_imba_desolator2_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_desolator2_unique", {})
	end
end

function modifier_imba_desolator2_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_desolator2_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_desolator2_unique")
	end
end

modifier_imba_desolator2_unique = class({})

function modifier_imba_desolator2_unique:IsDebuff()			return false end
function modifier_imba_desolator2_unique:IsHidden() 			return true end
function modifier_imba_desolator2_unique:IsPurgable() 		return false end
function modifier_imba_desolator2_unique:IsPurgeException() 	return false end
function modifier_imba_desolator2_unique:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		IMBA:ChangeUnitProjectile(self:GetParent(), self)
	end
end
function modifier_imba_desolator2_unique:OnDestroy()
	self.ability = nil 
	if IsServer() then
		IMBA:ChangeUnitProjectile(self:GetParent(), nil)
	end
end
function modifier_imba_desolator2_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_desolator2_unique:GetIMBAProjectileName() return "particles/items_fx/desolator_projectile.vpcf" end

function modifier_imba_desolator2_unique:OnAttackLanded(keys)
	if not IsServer() or keys.attacker ~= self:GetParent()  or not self:GetParent().splitattack then
		return
	end
	local has = false
	if keys.target:HasModifier("modifier_item_imba_desolator_armor_debuff") then
		has = true
	end
	local buff = keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_desolator_armor_debuff", {duration = self.ability:GetSpecialValueFor("duration")})
	if not has then
		buff:SetStackCount(self.ability:GetSpecialValueFor("base_stacks"))
	else
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	if keys.target:IsBuilding() and buff:GetStackCount() > self.ability:GetSpecialValueFor("active_stacks") then
		buff:SetStackCount(self.ability:GetSpecialValueFor("active_stacks"))
	end
	keys.target:EmitSound("Item_Desolator.Target")
end