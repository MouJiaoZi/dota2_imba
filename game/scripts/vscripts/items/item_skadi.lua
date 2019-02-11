

item_imba_skadi = class({})

LinkLuaModifier("modifier_imba_skadi_passive", "items/item_skadi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_skadi_slow", "items/item_skadi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_skadi_freeze", "items/item_skadi", LUA_MODIFIER_MOTION_NONE)

function item_imba_skadi:GetIntrinsicModifierName() return "modifier_imba_skadi_passive" end

function item_imba_skadi:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("base_radius") + self:GetCaster():GetModifierStackCount("modifier_imba_skadi_passive", nil) * self:GetSpecialValueFor("radius_per_str") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_skadi:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("base_radius") + self:GetCaster():GetModifierStackCount("modifier_imba_skadi_passive", nil) * self:GetSpecialValueFor("radius_per_str")
	local duration = self:GetSpecialValueFor("base_duration") + caster:GetIntellect() * self:GetSpecialValueFor("duration_per_int")
	local damage = self:GetSpecialValueFor("base_damage") + caster:GetAgility() * self:GetSpecialValueFor("damage_per_agi")
	local pfx = ParticleManager:CreateParticle("particles/item/skadi/skadi_ground.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:SetParticleControl(pfx, 2, Vector(radius, 0, 5000))
	ParticleManager:ReleaseParticleIndex(pfx)
	local sound = CreateModifierThinker(caster, self, "modifier_item_imba_skadi_slow", {duration = 1.0}, pos, caster:GetTeamNumber(), false)
	sound:EmitSound("Imba.SkadiCast")
	if RollPercentage(5) then
		sound:EmitSound("Imba.SkadiDeadWinter")
	end
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		ApplyDamage({victim = enemy, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		enemy:EmitSound("Imba.SkadiHit")
		enemy:AddNewModifier(caster, self, "modifier_item_imba_skadi_freeze", {duration = duration})
		enemy:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = 0.01})
	end
end

modifier_imba_skadi_passive = class({})

function modifier_imba_skadi_passive:IsDebuff()			return false end
function modifier_imba_skadi_passive:IsHidden() 		return true end
function modifier_imba_skadi_passive:IsPurgable() 		return false end
function modifier_imba_skadi_passive:IsPurgeException() return false end
function modifier_imba_skadi_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_skadi_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_skadi_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_skadi_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_skadi_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_skadi_passive:GetIMBAProjectileName() return "particles/items2_fx/skadi_projectile.vpcf" end

function modifier_imba_skadi_passive:OnCreated()
	if IsServer() then
		IMBA:ChangeUnitProjectile(self:GetParent(), self)
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_skadi_passive:OnDestroy()
	if IsServer() then
		IMBA:ChangeUnitProjectile(self:GetParent(), nil)
	end
end

function modifier_imba_skadi_passive:OnIntervalThink() self:SetStackCount(self:GetParent():GetStrength()) end

function modifier_imba_skadi_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or keys.unit:IsBuilding() or keys.unit:IsOther() or not IsEnemy(keys.unit, self:GetParent()) then
		return
	end
	local duration = self:GetAbility():GetSpecialValueFor("max_duration") - self:GetAbility():GetSpecialValueFor("min_duration")
	duration = self:GetAbility():GetSpecialValueFor("min_duration") + duration * math.max(self:GetAbility():GetSpecialValueFor("slow_range_cap") - (self:GetParent():GetAbsOrigin() - keys.unit:GetAbsOrigin()):Length2D(), 0) / self:GetAbility():GetSpecialValueFor("slow_range_cap")
	keys.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_skadi_slow", {duration = duration})
end

modifier_item_imba_skadi_slow = class({})

function modifier_item_imba_skadi_slow:IsDebuff()			return true end
function modifier_item_imba_skadi_slow:IsHidden() 			return false end
function modifier_item_imba_skadi_slow:IsPurgable() 		return true end
function modifier_item_imba_skadi_slow:IsPurgeException() 	return true end
function modifier_item_imba_skadi_slow:GetStatusEffectName() return "particles/status_fx/status_effect_frost_lich.vpcf" end
function modifier_item_imba_skadi_slow:StatusEffectPriority() return 15 end
function modifier_item_imba_skadi_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_skadi_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_ms")) end
function modifier_item_imba_skadi_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor('slow_as')) end


modifier_item_imba_skadi_freeze = class({})

function modifier_item_imba_skadi_freeze:IsDebuff()			return true end
function modifier_item_imba_skadi_freeze:IsHidden() 		return false end
function modifier_item_imba_skadi_freeze:IsPurgable() 		return true end
function modifier_item_imba_skadi_freeze:IsPurgeException() return true end
function modifier_item_imba_skadi_freeze:GetEffectName() return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf" end
function modifier_item_imba_skadi_freeze:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_imba_skadi_freeze:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end