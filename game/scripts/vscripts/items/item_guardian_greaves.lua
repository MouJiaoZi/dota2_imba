

item_imba_guardian_greaves = class({})

LinkLuaModifier("modifier_imga_guardian_greaves_passive", "items/item_guardian_greaves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_guardian_greaves_aura", "items/item_guardian_greaves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_guardian_greaves_hot", "items/item_guardian_greaves", LUA_MODIFIER_MOTION_NONE)

function item_imba_guardian_greaves:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_guardian_greaves:GetIntrinsicModifierName() return "modifier_imga_guardian_greaves_passive" end

function item_imba_guardian_greaves:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("aura_radius")
	caster:Purge(false, true, false, false, false)
	caster:EmitSound("Item.GuardianGreaves.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items3_fx/warmage.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		local pfx = ParticleManager:CreateParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		ParticleManager:ReleaseParticleIndex(pfx)
		ally:Heal(self:GetSpecialValueFor("replenish_health"), self)
		ally:GiveMana(self:GetSpecialValueFor("replenish_mana"))
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, self:GetSpecialValueFor("replenish_health"), nil)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, ally, self:GetSpecialValueFor("replenish_mana"), nil)
		ally:AddNewModifier(caster, self, "modifier_item_imba_guardian_greaves_hot", {duration = self:GetSpecialValueFor("replenish_duration")})
	end
end

modifier_imga_guardian_greaves_passive = class({})

function modifier_imga_guardian_greaves_passive:IsDebuff()			return false end
function modifier_imga_guardian_greaves_passive:IsHidden() 			return true end
function modifier_imga_guardian_greaves_passive:IsPurgable() 		return false end
function modifier_imga_guardian_greaves_passive:IsPurgeException() 	return false end
function modifier_imga_guardian_greaves_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imga_guardian_greaves_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MANA_BONUS} end
function modifier_imga_guardian_greaves_passive:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("bonus_movement") end
function modifier_imga_guardian_greaves_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imga_guardian_greaves_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imga_guardian_greaves_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imga_guardian_greaves_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imga_guardian_greaves_passive:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_imga_guardian_greaves_passive:IsAura() return true end
function modifier_imga_guardian_greaves_passive:GetAuraDuration() return 0.1 end
function modifier_imga_guardian_greaves_passive:GetModifierAura() return "modifier_item_imba_guardian_greaves_aura" end
function modifier_imga_guardian_greaves_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imga_guardian_greaves_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imga_guardian_greaves_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imga_guardian_greaves_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imga_guardian_greaves_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and self:GetAbility():IsCooldownReady() and (self:GetParent():GetHealth() <= self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("heal_threshold_pct") / 100)) and self:GetAbility():IsOwnersManaEnough() and not self:GetParent():IsIllusion() then
		self:GetAbility():OnSpellStart()
		self:GetAbility():UseResources(true, true, true)
		self:GetParent():Purge(false, true, false, true, true)
	end
end

modifier_item_imba_guardian_greaves_aura = class({})

function modifier_item_imba_guardian_greaves_aura:IsDebuff()		return false end
function modifier_item_imba_guardian_greaves_aura:IsHidden() 		return false end
function modifier_item_imba_guardian_greaves_aura:IsPurgable() 		return false end
function modifier_item_imba_guardian_greaves_aura:IsPurgeException() return false end
function modifier_item_imba_guardian_greaves_aura:GetTexture() return "imba_guardian_greaves" end
function modifier_item_imba_guardian_greaves_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_guardian_greaves_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_guardian_greaves_aura:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_imba_guardian_greaves_aura:GetModifierConstantHealthRegen()
	if self:GetParent():IsHero() then
		return (self.ability:GetSpecialValueFor("base_regen") + ((100 - self:GetParent():GetHealthPercent()) / 100) * self.ability:GetSpecialValueFor("regen_per_pct_tooltip"))
	else
		return self.ability:GetSpecialValueFor("base_regen")
	end
end
function modifier_item_imba_guardian_greaves_aura:GetModifierPhysicalArmorBonus()
	if self:GetParent():IsHero() then
		return (self.ability:GetSpecialValueFor("base_armor") + ((100 - self:GetParent():GetHealthPercent()) / 100) * self.ability:GetSpecialValueFor("armor_per_pct_tooltip"))
	else
		return self.ability:GetSpecialValueFor("base_armor")
	end
end

modifier_item_imba_guardian_greaves_hot = class({})

function modifier_item_imba_guardian_greaves_hot:IsDebuff()			return false end
function modifier_item_imba_guardian_greaves_hot:IsHidden() 		return false end
function modifier_item_imba_guardian_greaves_hot:IsPurgable() 		return true end
function modifier_item_imba_guardian_greaves_hot:IsPurgeException() return true end
function modifier_item_imba_guardian_greaves_hot:GetTexture() return "imba_guardian_greaves" end
function modifier_item_imba_guardian_greaves_hot:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_guardian_greaves_hot:OnDestroy() self.ability = nil end
function modifier_item_imba_guardian_greaves_hot:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE} end
function modifier_item_imba_guardian_greaves_hot:GetModifierHealthRegenPercentage() return self.ability:GetSpecialValueFor("replenish_pct") end
function modifier_item_imba_guardian_greaves_hot:GetModifierTotalPercentageManaRegen() return self.ability:GetSpecialValueFor("replenish_pct") end