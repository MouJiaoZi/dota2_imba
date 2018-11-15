

item_imba_octarine_core = class({})

LinkLuaModifier("modifier_imba_octarine_core_passive", "items/item_octarine_core", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_octarine_core_unique", "items/item_octarine_core", LUA_MODIFIER_MOTION_NONE)

function item_imba_octarine_core:GetIntrinsicModifierName() return "modifier_imba_octarine_core_passive" end
function item_imba_octarine_core:GetAbilityTextureName() return self:GetCaster():GetModifierStackCount("modifier_imba_octarine_core_unique", self:GetCaster()) == 1 and "custom/imba_octarine_core_off" or "custom/imba_octarine_core" end

function item_imba_octarine_core:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("blast_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_octarine_core:OnSpellStart()
	self:GetCaster():EmitSound("Item.DropGemWorld")
	if self:GetCaster():FindModifierByName("modifier_imba_octarine_core_unique"):GetStackCount() == 0 then
		self:GetCaster():FindModifierByName("modifier_imba_octarine_core_unique"):SetStackCount(1)
	else
		self:GetCaster():FindModifierByName("modifier_imba_octarine_core_unique"):SetStackCount(0)
	end
end

modifier_imba_octarine_core_passive = class({})

function modifier_imba_octarine_core_passive:IsDebuff()				return false end
function modifier_imba_octarine_core_passive:IsHidden() 			return true end
function modifier_imba_octarine_core_passive:IsPurgable() 			return false end
function modifier_imba_octarine_core_passive:IsPurgeException() 	return false end
function modifier_imba_octarine_core_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_octarine_core_passive:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_octarine_core_passive:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_imba_octarine_core_passive:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_imba_octarine_core_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intelligence") end

function modifier_imba_octarine_core_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_octarine_core_unique", {})
	end
end

function modifier_imba_octarine_core_passive:OnDestroy()
	if IsServer() then
		if not self:GetParent():HasModifier("modifier_imba_octarine_core_passive") then
			self:GetParent():RemoveModifierByName("modifier_imba_octarine_core_unique")
		end
	end
end

modifier_imba_octarine_core_unique = class({})

function modifier_imba_octarine_core_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_octarine_core_unique:OnDestroy() self.ability = nil end
function modifier_imba_octarine_core_unique:IsDebuff()			return false end
function modifier_imba_octarine_core_unique:IsHidden() 			return true end
function modifier_imba_octarine_core_unique:IsPurgable() 		return false end
function modifier_imba_octarine_core_unique:IsPurgeException() 	return false end
function modifier_imba_octarine_core_unique:DeclareFunctions() return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_octarine_core_unique:GetModifierPercentageCooldown() return self.ability:GetSpecialValueFor("bonus_cooldown") end

function modifier_imba_octarine_core_unique:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and self:GetStackCount() == 0 and keys.cost >= self.ability:GetSpecialValueFor("minimum_mana") then
		local pfx = ParticleManager:CreateParticle("particles/item/octarine_core/octarine_core_active.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("blast_radius"), self.ability:GetSpecialValueFor("blast_radius"), self.ability:GetSpecialValueFor("blast_radius")))
		ParticleManager:ReleaseParticleIndex(pfx)
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("blast_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			local pfx2 = ParticleManager:CreateParticle("particles/item/octarine_core/octarine_core_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControl(pfx2, 1, Vector(0.2,0,0))
			ParticleManager:ReleaseParticleIndex(pfx2)
			ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = self.ability:GetSpecialValueFor("blast_dmg"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, self.ability:GetSpecialValueFor("blast_dmg"), nil)
		end
		self:GetParent():EmitSound("Hero_Zuus.StaticField")
	end
end

function modifier_imba_octarine_core_unique:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and keys.inflictor and IsEnemy(keys.attacker, keys.unit) and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
		local dmg = keys.damage * (self.ability:GetSpecialValueFor("hero_lifesteal") / 100)
		if keys.unit:IsCreep() then
			dmg = dmg / 5
		end
		self:GetParent():Heal(dmg, self.ability)
		local pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end