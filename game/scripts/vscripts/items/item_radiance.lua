
item_imba_radiance = class({})

LinkLuaModifier("modifier_imba_radiance_passive", "items/item_radiance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_radiance_unique", "items/item_radiance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_radiance_debuff", "items/item_radiance", LUA_MODIFIER_MOTION_NONE)

function item_imba_radiance:GetIntrinsicModifierName() return "modifier_imba_radiance_passive" end

function item_imba_radiance:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_radiance:GetAbilityTextureName()
	if self:GetCaster():GetModifierStackCount("modifier_imba_radiance_unique", nil) == 0 then
		return "radiance"
	else
		return "radiance_inactive"
	end
end

function item_imba_radiance:OnSpellStart()
	local buff = self:GetCaster():FindModifierByName("modifier_imba_radiance_unique")
	if buff:GetStackCount() == 0 then
		buff:SetStackCount(1)
		buff:Inactive()
	else
		buff:SetStackCount(0)
		buff:Active()
	end
end

modifier_imba_radiance_passive = class({})

function modifier_imba_radiance_passive:IsDebuff()			return false end
function modifier_imba_radiance_passive:IsHidden() 			return true end
function modifier_imba_radiance_passive:IsPurgable() 		return false end
function modifier_imba_radiance_passive:IsPurgeException() 	return false end
function modifier_imba_radiance_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_radiance_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_radiance_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end

function modifier_imba_radiance_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_radiance_unique", {})
	end
end

function modifier_imba_radiance_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_radiance_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_radiance_unique")
	end
end

modifier_imba_radiance_unique = class({})

function modifier_imba_radiance_unique:IsDebuff()			return false end
function modifier_imba_radiance_unique:IsHidden() 			return true end
function modifier_imba_radiance_unique:IsPurgable() 		return false end
function modifier_imba_radiance_unique:IsPurgeException() 	return false end
function modifier_imba_radiance_unique:RemoveOnDeath() return self:GetParent():IsIllusion() end

function modifier_imba_radiance_unique:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:Active()
	end
end

function modifier_imba_radiance_unique:Active()
	self.pfx = ParticleManager:CreateParticle("particles/items2_fx/radiance_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_imba_radiance_unique:Inactive()
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self.pfx = nil
end

function modifier_imba_radiance_unique:OnDestroy()
	self.ability = nil
	if IsServer() and self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function modifier_imba_radiance_unique:IsAura() return (self:GetStackCount() == 0 and true or false) end
function modifier_imba_radiance_unique:GetAuraDuration() return 0.1 end
function modifier_imba_radiance_unique:GetModifierAura() return "modifier_imba_radiance_debuff" end
function modifier_imba_radiance_unique:GetAuraRadius() return self.ability:GetSpecialValueFor("aura_radius") end
function modifier_imba_radiance_unique:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_radiance_unique:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_radiance_unique:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_radiance_debuff = class({})

function modifier_imba_radiance_debuff:OnDestroy() self.ability = nil end
function modifier_imba_radiance_debuff:IsDebuff()			return false end
function modifier_imba_radiance_debuff:IsHidden() 			return true end
function modifier_imba_radiance_debuff:IsPurgable() 		return false end
function modifier_imba_radiance_debuff:IsPurgeException() 	return false end
function modifier_imba_radiance_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MISS_PERCENTAGE} end
function modifier_imba_radiance_debuff:GetModifierMiss_Percentage() return self.ability:GetSpecialValueFor("miss_chance") end

function modifier_imba_radiance_debuff:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:StartIntervalThink(self.ability:GetSpecialValueFor("think_interval"))
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/radiance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_radiance_debuff:OnIntervalThink()
	local dmg = self.ability:GetSpecialValueFor("base_damage") + self:GetParent():GetHealth() * (self.ability:GetSpecialValueFor("extra_damage") / 100)
	if self:GetParent():IsIllusion() then
		dmg = self.ability:GetSpecialValueFor("base_damage")
	end
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self.ability, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL})
end