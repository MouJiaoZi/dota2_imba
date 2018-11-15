


item_imba_vanguard = class({})

LinkLuaModifier("modifier_imba_vanguard_passive", "items/item_vanguard", LUA_MODIFIER_MOTION_NONE)

function item_imba_vanguard:GetIntrinsicModifierName() return "modifier_imba_vanguard_passive" end

modifier_imba_vanguard_passive = class({})

function modifier_imba_vanguard_passive:IsDebuff()			return false end
function modifier_imba_vanguard_passive:IsHidden() 			return true end
function modifier_imba_vanguard_passive:IsPurgable() 		return false end
function modifier_imba_vanguard_passive:IsPurgeException() 	return false end
function modifier_imba_vanguard_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_vanguard_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_imba_vanguard_passive:GetModifierPhysical_ConstantBlock()
	if self:GetParent():IsRealHero() then
		return (self:GetParent():GetLevel() + self:GetAbility():GetSpecialValueFor("base_damage_block"))
	else
		return nil
	end
end
function modifier_imba_vanguard_passive:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("health") end
function modifier_imba_vanguard_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("health_regen") end
function modifier_imba_vanguard_passive:GetModifierIncomingDamage_Percentage()
	if not self:GetParent():HasModifier("modifier_imba_rapier_super_unique") and not self:GetParent():HasModifier("modifier_imba_burrow") then
		return (0 - self:GetAbility():GetSpecialValueFor("damage_reduction"))
	else
		return 0
	end
end

item_imba_crimson_guard = class({})

LinkLuaModifier("modifier_imba_crimson_guard_passive", "items/item_vanguard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_crimson_guard_active", "items/item_vanguard", LUA_MODIFIER_MOTION_NONE)

function item_imba_crimson_guard:GetIntrinsicModifierName() return "modifier_imba_crimson_guard_passive" end

function item_imba_crimson_guard:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("active_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_crimson_guard:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Item.CrimsonGuard.Cast")
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/vanguard_active_launch.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("active_radius"),0,0))
	ParticleManager:ReleaseParticleIndex(pfx)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("active_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _, hero in pairs(heroes) do
		if hero:HasModifier("modifier_imba_crimson_guard_passive") and hero:FindModifierByName("modifier_imba_crimson_guard_passive"):GetDuration() < 0 then
			hero:AddNewModifier(caster, self, "modifier_item_crimson_guard_active", {duration = self:GetSpecialValueFor("duration")})
		else
			hero:AddNewModifier(caster, self, "modifier_item_crimson_guard_active", {duration = self:GetSpecialValueFor("duration")})
			hero:AddNewModifier(caster, self, "modifier_imba_crimson_guard_passive", {duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_imba_crimson_guard_passive = class({})

function modifier_imba_crimson_guard_passive:IsDebuff()			return false end
function modifier_imba_crimson_guard_passive:IsHidden() 		return true end
function modifier_imba_crimson_guard_passive:IsPurgable() 		return false end
function modifier_imba_crimson_guard_passive:IsPurgeException() return false end
function modifier_imba_crimson_guard_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_crimson_guard_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_crimson_guard_passive:GetModifierPhysical_ConstantBlock()
	if self:GetParent():IsRealHero() then
		return (self:GetParent():GetLevel() + self:GetAbility():GetSpecialValueFor("base_damage_block"))
	else
		return nil
	end
end
function modifier_imba_crimson_guard_passive:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("health") end
function modifier_imba_crimson_guard_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("health_regen") end
function modifier_imba_crimson_guard_passive:GetModifierIncomingDamage_Percentage()
	if not self:GetParent():HasModifier("modifier_imba_rapier_super_unique") and not self:GetParent():HasModifier("modifier_imba_burrow") then
		return (0 - self:GetAbility():GetSpecialValueFor("damage_reduction"))
	else
		return 0
	end
end
function modifier_imba_crimson_guard_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_crimson_guard_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_crimson_guard_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_crimson_guard_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end

modifier_item_crimson_guard_active = class({})

function modifier_item_crimson_guard_active:IsDebuff()			return false end
function modifier_item_crimson_guard_active:IsHidden() 			return false end
function modifier_item_crimson_guard_active:IsPurgable() 		return false end
function modifier_item_crimson_guard_active:IsPurgeException() 	return false end
function modifier_item_crimson_guard_active:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_crimson_guard_active:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("active_armor") end

function modifier_item_crimson_guard_active:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/vanguard_active.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end



item_imba_greatwyrm_plate = class({})

LinkLuaModifier("modifier_imba_greatwyrm_plate_passive", "items/item_vanguard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_greatwyrm_plate_active", "items/item_vanguard", LUA_MODIFIER_MOTION_NONE)

function item_imba_greatwyrm_plate:GetIntrinsicModifierName() return "modifier_imba_greatwyrm_plate_passive" end

function item_imba_greatwyrm_plate:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("active_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_greatwyrm_plate:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Item.CrimsonGuard.Cast")
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/vanguard_active_launch.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("active_radius"),0,0))
	ParticleManager:ReleaseParticleIndex(pfx)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("active_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _, hero in pairs(heroes) do
		hero:RemoveModifierByName("modifier_item_crimson_guard_active")
		hero:AddNewModifier(caster, self, "modifier_item_greatwyrm_plate_active", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_imba_greatwyrm_plate_passive = class({})

function modifier_imba_greatwyrm_plate_passive:IsDebuff()			return false end
function modifier_imba_greatwyrm_plate_passive:IsHidden() 			return true end
function modifier_imba_greatwyrm_plate_passive:IsPurgable() 		return false end
function modifier_imba_greatwyrm_plate_passive:IsPurgeException() 	return false end
function modifier_imba_greatwyrm_plate_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_greatwyrm_plate_passive:GetModifierPhysical_ConstantBlock()
	if self:GetParent():IsRealHero() then
		return (self:GetParent():GetLevel() + self:GetAbility():GetSpecialValueFor("base_damage_block"))
	else
		return nil
	end
end
function modifier_imba_greatwyrm_plate_passive:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("health") end
function modifier_imba_greatwyrm_plate_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("health_regen") end
function modifier_imba_greatwyrm_plate_passive:GetModifierIncomingDamage_Percentage()
	if not self:GetParent():HasModifier("modifier_imba_rapier_super_unique") and not self:GetParent():HasModifier("modifier_imba_burrow") and not self:GetParent():IsStunned() and not self:GetParent():IsHexed() then
		return (0 - self:GetAbility():GetSpecialValueFor("dmg_reduce"))
	end
	if (self:GetParent():IsHexed() or self:GetParent():IsStunned()) and not self:GetParent():HasModifier("modifier_imba_rapier_super_unique") and not self:GetParent():HasModifier("modifier_imba_burrow") then
		return (0 - math.min(self:GetAbility():GetSpecialValueFor("dmg_reduce") + math.floor(self:GetParent():GetMaxHealth() / self:GetAbility():GetSpecialValueFor("health_dmg_reduce")) * self:GetAbility():GetSpecialValueFor("disable_dmg_reduce"), self:GetAbility():GetSpecialValueFor("max_damage_reduce")))
	end
	return 0
end
function modifier_imba_greatwyrm_plate_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_greatwyrm_plate_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_greatwyrm_plate_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_greatwyrm_plate_passive:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("mana") end
function modifier_imba_greatwyrm_plate_passive:GetModifierStatusResistance() return self:GetAbility():GetSpecialValueFor("statue_resis") end
function modifier_imba_greatwyrm_plate_passive:GetModifierPhysicalArmorBonus()
	if self:GetParent():IsHexed() or self:GetParent():IsStunned() then
		return (self:GetAbility():GetSpecialValueFor("armor") - self:GetParent():GetPhysicalArmorBaseValue())
	else
		return self:GetAbility():GetSpecialValueFor("armor")
	end
end
function modifier_imba_greatwyrm_plate_passive:GetModifierMagicalResistanceBonus()
	if self:GetParent():IsHexed() or self:GetParent():IsStunned() then
		return (0 - self:GetParent():GetBaseMagicalResistanceValue())
	else
		return 0
	end
end

function modifier_imba_greatwyrm_plate_passive:OnCreated()
	if IsServer() and not self:GetParent():IsIllusion() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_greatwyrm_plate_passive:OnIntervalThink()
	if (self:GetParent():IsStunned() or self:GetParent():IsHexed()) and not self.pfx then
		self.pfx = ParticleManager:CreateParticle("particles/item/greatwyrm_plate/greatwyrm_passive.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.pfx, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	end
	if not self:GetParent():IsStunned() and not self:GetParent():IsHexed() and self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function modifier_imba_greatwyrm_plate_passive:OnDestroy()
	if IsServer() and self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

modifier_item_greatwyrm_plate_active = class({})

function modifier_item_greatwyrm_plate_active:IsDebuff()			return false end
function modifier_item_greatwyrm_plate_active:IsHidden() 			return false end
function modifier_item_greatwyrm_plate_active:IsPurgable() 			return false end
function modifier_item_greatwyrm_plate_active:IsPurgeException() 	return false end
function modifier_item_greatwyrm_plate_active:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK} end
function modifier_item_greatwyrm_plate_active:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("active_armor") end
function modifier_item_greatwyrm_plate_active:GetModifierPhysical_ConstantBlock()
	if self:GetParent():IsRealHero() then
		return (self:GetParent():GetLevel() + self:GetAbility():GetSpecialValueFor("base_damage_block"))
	else
		return nil
	end
end

function modifier_item_greatwyrm_plate_active:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/item/greatwyrm_plate/greatwyrm_active.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end
