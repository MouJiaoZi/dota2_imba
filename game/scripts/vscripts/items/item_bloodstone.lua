
item_imba_bloodstone = class({})

LinkLuaModifier("modifier_imba_bloodstone_passive", "items/item_bloodstone", LUA_MODIFIER_MOTION_NONE)

function item_imba_bloodstone:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("effect_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_bloodstone:GetIntrinsicModifierName() return "modifier_imba_bloodstone_passive" end

function item_imba_bloodstone:OnSpellStart()
	local caster = self:GetCaster()
	TrueKill(caster, caster, self)
end

modifier_imba_bloodstone_passive = class({})

function modifier_imba_bloodstone_passive:IsDebuff()			return false end
function modifier_imba_bloodstone_passive:IsHidden() 			return true end
function modifier_imba_bloodstone_passive:IsPurgable() 			return false end
function modifier_imba_bloodstone_passive:IsPurgeException() 	return false end
function modifier_imba_bloodstone_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_bloodstone_passive:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_bloodstone_passive:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_RESPAWNTIME_STACKING} end
function modifier_imba_bloodstone_passive:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_imba_bloodstone_passive:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_imba_bloodstone_passive:GetModifierConstantHealthRegen() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("hp_regen_per_charge")) end
function modifier_imba_bloodstone_passive:GetModifierConstantManaRegen() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("mana_regen_per_charge")) end
function modifier_imba_bloodstone_passive:GetModifierStackingRespawnTime() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("respawn_time_reduction")) end

function modifier_imba_bloodstone_passive:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.3)
	end
end

function modifier_imba_bloodstone_passive:OnIntervalThink() self:SetStackCount(self:GetAbility():GetCurrentCharges()) end

function modifier_imba_bloodstone_passive:OnDeath(keys)
	if not IsServer() or self:GetParent():IsIllusion() then
		return
	end
	if keys.unit == self:GetParent() then
		local allies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("effect_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local heal = self:GetAbility():GetCurrentCharges() * self:GetAbility():GetSpecialValueFor("heal_on_death_per_charge") + self:GetAbility():GetSpecialValueFor("heal_on_death_base")
		for _, ally in pairs(allies) do
			local pfx = ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
			ParticleManager:ReleaseParticleIndex(pfx)
			ally:Heal(heal, self:GetAbility())
		end
		Timers:CreateTimer(0.2, function()
			self:GetAbility():SetCurrentCharges(math.floor(self:GetAbility():GetCurrentCharges() - self:GetAbility():GetCurrentCharges() * (self:GetAbility():GetSpecialValueFor("on_death_loss") / 100)))
			return nil
		end
		)
	end
	if IsEnemy(keys.unit, self:GetParent()) and keys.unit:IsRealHero() and not keys.unit:IsClone() and not keys.unit:IsTempestDouble() and (self:GetParent():GetAbsOrigin() - keys.unit:GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("effect_radius") then
		for i=0, 5 do
			local item = self:GetParent():GetItemInSlot(i)
			if item and item:GetName() == "item_imba_bloodstone" then
				item:SetCurrentCharges(item:GetCurrentCharges() + 1)
				break
			end
		end
	end
end