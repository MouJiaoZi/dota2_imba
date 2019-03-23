
--"imba_armlet_active"

item_imba_armlet = class({})

LinkLuaModifier("midifier_imba_armlet_passive", "items/item_armlet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("midifier_imba_armlet_active_unique", "items/item_armlet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_armlet_stacks", "items/item_armlet", LUA_MODIFIER_MOTION_NONE)

function item_imba_armlet:GetIntrinsicModifierName() return "midifier_imba_armlet_passive" end

function item_imba_armlet:GetAbilityTextureName() return (self:GetCaster():GetModifierStackCount("midifier_imba_armlet_active_unique", nil) > 0 and "imba_armlet_active" or "imba_armlet") end

function item_imba_armlet:OnSpellStart()
	local caster = self:GetCaster()
	local buff = caster:FindModifierByName("midifier_imba_armlet_active_unique")
	if not buff then
		return nil
	end
	if caster:GetModifierStackCount("midifier_imba_armlet_active_unique", nil) == 0 then
		caster:EmitSound("DOTA_Item.Armlet.Activate")
		buff:StartIntervalThink(0.6 / self:GetSpecialValueFor("unholy_bonus_strength"))
	else
		caster:EmitSound("DOTA_Item.Armlet.DeActivate")
		buff:StartIntervalThink(-1)
		buff:SetStackCount(0)
		if buff.pfx then
			ParticleManager:DestroyParticle(buff.pfx, false)
			ParticleManager:ReleaseParticleIndex(buff.pfx)
			buff.pfx = nil
		end
	end
	caster:CalculateStatBonus()
end

midifier_imba_armlet_passive = class({})

function midifier_imba_armlet_passive:IsDebuff()		return false end
function midifier_imba_armlet_passive:IsHidden() 		return true end
function midifier_imba_armlet_passive:IsPurgable() 		return false end
function midifier_imba_armlet_passive:IsPurgeException() return false end
function midifier_imba_armlet_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function midifier_imba_armlet_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function midifier_imba_armlet_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function midifier_imba_armlet_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function midifier_imba_armlet_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function midifier_imba_armlet_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end

function midifier_imba_armlet_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "midifier_imba_armlet_active_unique", {})
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_armlet_stacks", {})
	end
end

function midifier_imba_armlet_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("midifier_imba_armlet_passive") then
		self:GetParent():RemoveModifierByName("midifier_imba_armlet_active_unique")
		self:GetParent():RemoveModifierByName("modifier_item_imba_armlet_stacks")
	end
end

midifier_imba_armlet_active_unique = class({})

function midifier_imba_armlet_active_unique:IsDebuff()			return false end
function midifier_imba_armlet_active_unique:IsHidden() 			return true end
function midifier_imba_armlet_active_unique:IsPurgable() 		return false end
function midifier_imba_armlet_active_unique:IsPurgeException() 	return false end
function midifier_imba_armlet_active_unique:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function midifier_imba_armlet_active_unique:GetModifierBonusStats_Strength() return self:GetStackCount() end
function midifier_imba_armlet_active_unique:GetModifierPhysicalArmorBonus() return (self:GetStackCount() > 0 and self.ar or 0) end
function midifier_imba_armlet_active_unique:GetModifierPreAttack_BonusDamage() return (self:GetStackCount() > 0 and self.ad or 0) end

function midifier_imba_armlet_active_unique:OnCreated()
	self.str = self:GetAbility():GetSpecialValueFor("unholy_bonus_strength")
	self.ar = self:GetAbility():GetSpecialValueFor("unholy_bonus_armor")
	self.ad = self:GetAbility():GetSpecialValueFor("unholy_bonus_damage")
end

function midifier_imba_armlet_active_unique:OnDestroy()
	self.str = nil
	self.ar = nil
	self.ad = nil
	if IsServer() and self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function midifier_imba_armlet_active_unique:OnIntervalThink()
	if not self.pfx then
		self.pfx = ParticleManager:CreateParticle("particles/items_fx/armlet.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
	self:SetStackCount(self:GetStackCount() + 1)
	self:GetParent():CalculateStatBonus()
	if self:GetStackCount() >= self.str then
		self:SetStackCount(self.str)
		self:StartIntervalThink(-1)
	end
end

modifier_item_imba_armlet_stacks = class({})

function modifier_item_imba_armlet_stacks:IsDebuff()			return false end
function modifier_item_imba_armlet_stacks:IsHidden() 			return (self:GetParent():GetModifierStackCount("midifier_imba_armlet_active_unique", nil) == 0 and true or false) end
function modifier_item_imba_armlet_stacks:IsPurgable() 			return false end
function modifier_item_imba_armlet_stacks:IsPurgeException() 	return false end
function modifier_item_imba_armlet_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_imba_armlet_stacks:GetModifierPreAttack_BonusDamage() return self.ad * self:GetStackCount() end
function modifier_item_imba_armlet_stacks:GetModifierAttackSpeedBonus_Constant() return self.as * self:GetStackCount() end
function modifier_item_imba_armlet_stacks:GetModifierPhysicalArmorBonus() return self.ar * self:GetStackCount() end

function modifier_item_imba_armlet_stacks:OnCreated()
	self.hp = self:GetAbility():GetSpecialValueFor("unholy_health_drain")
	self.health_per_stack = self:GetAbility():GetSpecialValueFor("health_per_stack")
	self.ad = self:GetAbility():GetSpecialValueFor("stack_damage")
	self.as = self:GetAbility():GetSpecialValueFor("stack_as")
	self.ar = self:GetAbility():GetSpecialValueFor("stack_armor")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_item_imba_armlet_stacks:OnDestroy()
	self.hp = nil
	self.health_per_stack = nil
	self.ad = nil
	self.as = nil
	self.ar = nil
end

function modifier_item_imba_armlet_stacks:OnIntervalThink()
	if self:IsHidden() then
		self:SetStackCount(0)
	else
		self:SetStackCount(math.floor((self:GetParent():GetMaxHealth() - self:GetParent():GetHealth()) / self.health_per_stack))
		local hp_loss = self.hp / (1.0 / 0.1)
		self:GetParent():SetHealth(math.max(1, self:GetParent():GetHealth() - hp_loss))
	end
end