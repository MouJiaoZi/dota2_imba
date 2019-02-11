CreateEmptyTalents("broodmother")

imba_broodmother_insatiable_hunger = class({})

LinkLuaModifier("modifier_insatiable_hunger_cast", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_insatiable_hunger", "hero/hero_broodmother", LUA_MODIFIER_MOTION_NONE)

function imba_broodmother_insatiable_hunger:IsHiddenWhenStolen() 	return false end
function imba_broodmother_insatiable_hunger:IsRefreshable() 		return true end
function imba_broodmother_insatiable_hunger:IsStealable() 			return true end
function imba_broodmother_insatiable_hunger:IsNetherWardStealable()	return true end
function imba_broodmother_insatiable_hunger:GetCastRange() return (self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus()) end

function imba_broodmother_insatiable_hunger:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_insatiable_hunger_cast", {duration = self:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_imba_broodmother_2")})
end

modifier_insatiable_hunger_cast = class({})

function modifier_insatiable_hunger_cast:IsDebuff()			return false end
function modifier_insatiable_hunger_cast:IsHidden() 		return false end
function modifier_insatiable_hunger_cast:IsPurgable() 		return false end
function modifier_insatiable_hunger_cast:IsPurgeException() return false end
function modifier_insatiable_hunger_cast:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end

function modifier_insatiable_hunger_cast:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Broodmother.InsatiableHunger")
	end
end

function modifier_insatiable_hunger_cast:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Broodmother.InsatiableHunger")
	end
end

function modifier_insatiable_hunger_cast:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and not keys.reincarnate then
		self:Destroy()
	end
end

function modifier_insatiable_hunger_cast:IsAura() return true end
function modifier_insatiable_hunger_cast:GetAuraDuration() return 0.1 end
function modifier_insatiable_hunger_cast:GetModifierAura() return "modifier_insatiable_hunger" end
function modifier_insatiable_hunger_cast:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_insatiable_hunger_cast:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_insatiable_hunger_cast:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_insatiable_hunger_cast:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_insatiable_hunger_cast:GetAuraEntityReject(unit)
	if unit:IsHero() and unit ~= self:GetCaster() then
		return true
	end
	if unit:IsControllableByAnyPlayer() and unit:GetPlayerOwnerID() ~= self:GetCaster():GetPlayerOwnerID() then
		return true
	end
	return false
end

modifier_insatiable_hunger = class({})

function modifier_insatiable_hunger:IsDebuff()			return false end
function modifier_insatiable_hunger:IsHidden() 			return false end
function modifier_insatiable_hunger:IsPurgable() 		return false end
function modifier_insatiable_hunger:IsPurgeException() 	return false end

function modifier_insatiable_hunger:OnCreated()
	self.dmg = (self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetCaster():GetTalentValue("special_bonus_imba_broodmother_1"))
	self.lifesteal = (self:GetAbility():GetSpecialValueFor("lifesteal_pct") + self:GetCaster():GetTalentValue("special_bonus_imba_broodmother_1"))
	if not self:GetParent():IsHero() then
		self.dmg = self.dmg * (self:GetAbility():GetSpecialValueFor("creeep_pct") / 100)
		self.lifesteal = self.lifesteal * (self:GetAbility():GetSpecialValueFor("creeep_pct") / 100)
	end
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, (self:GetParent():IsHero() and "attach_thorax" or "attach_hitloc"), self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_insatiable_hunger:OnDestroy()
	self.dmg = nil
	self.lifesteal = nil
end

function modifier_insatiable_hunger:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_insatiable_hunger:GetModifierPreAttack_BonusDamage() return self.dmg end

function modifier_insatiable_hunger:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and (keys.target:IsHero() or keys.target:IsCreep() or keys.target:IsBoss()) then
		local lifesteal = self.lifesteal
		self:GetParent():Heal(lifesteal, self:GetAbility())
	end
end