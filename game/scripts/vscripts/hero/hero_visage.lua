CreateEmptyTalents("visage")

LinkLuaModifier("modifier_imba_gravekeepers_cloak_aura", "hero/hero_visage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_gravekeepers_cloak", "hero/hero_visage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_gravekeepers_cloak_recover_timer", "hero/hero_visage.lua", LUA_MODIFIER_MOTION_NONE)

imba_visage_gravekeepers_cloak = class({})

function imba_visage_gravekeepers_cloak:GetIntrinsicModifierName() return "modifier_imba_gravekeepers_cloak_aura" end
function imba_visage_gravekeepers_cloak:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

modifier_imba_gravekeepers_cloak_aura = class({})

function modifier_imba_gravekeepers_cloak_aura:IsDebuff()			return false end
function modifier_imba_gravekeepers_cloak_aura:IsHidden() 			return true end
function modifier_imba_gravekeepers_cloak_aura:IsPurgable() 		return false end
function modifier_imba_gravekeepers_cloak_aura:IsPurgeException() 	return false end
function modifier_imba_gravekeepers_cloak_aura:AllowIllusionDuplicate() return false end

function modifier_imba_gravekeepers_cloak_aura:IsAura() return (not self:GetCaster():PassivesDisabled()) end
function modifier_imba_gravekeepers_cloak_aura:IsAuraActiveOnDeath() return true end
function modifier_imba_gravekeepers_cloak_aura:GetAuraDuration() return 0.1 end
function modifier_imba_gravekeepers_cloak_aura:GetModifierAura() return "modifier_imba_gravekeepers_cloak" end
function modifier_imba_gravekeepers_cloak_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_gravekeepers_cloak_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_imba_gravekeepers_cloak_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_gravekeepers_cloak_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_gravekeepers_cloak_aura:GetAuraEntityReject(unit)
	if unit:IsCreep() and self:GetCaster():HasTalent("special_bonus_imba_visage_1") then
		return false
	end
	return (unit:GetPlayerOwnerID() ~= self:GetCaster():GetPlayerOwnerID())
end

function modifier_imba_gravekeepers_cloak_aura:OnCreated()
	if IsServer() then
		self.units = {}
	end
end

function modifier_imba_gravekeepers_cloak_aura:OnDestroy()
	if IsServer() then
		self.units = nil
	end
end

function modifier_imba_gravekeepers_cloak_aura:DamageHealUnits(hUnit, fDamage)
	if IsServer() and self.units then
		for k, v in pairs(self.units) do
			if v ~= hUnit and v ~= self:GetCaster() and v:IsControllableByAnyPlayer() then
				v:Heal(fDamage, self:GetAbility())
				local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_cast_tgt.vpcf", PATTACH_CUSTOMORIGIN, v)
				ParticleManager:SetParticleControlEnt(pfx, 2, v, PATTACH_ABSORIGIN_FOLLOW, nil, v:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(pfx)
			end
		end
	end
end

modifier_imba_gravekeepers_cloak = class({})

function modifier_imba_gravekeepers_cloak:IsDebuff()			return false end
function modifier_imba_gravekeepers_cloak:IsHidden() 			return false end
function modifier_imba_gravekeepers_cloak:IsPurgable() 			return false end
function modifier_imba_gravekeepers_cloak:IsPurgeException() 	return false end
function modifier_imba_gravekeepers_cloak:DeclareFunctions()	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end

function modifier_imba_gravekeepers_cloak:OnCreated()
	local buff = self
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if IsServer() then
		Timers:CreateTimer(0.1, function()
			if not buff:IsNull() then
				if caster == parent then
					buff:SetStackCount(ability:GetSpecialValueFor("max_layers"))
				else
					self:StartIntervalThink(0.1)
					buff:SetStackCount(caster:GetModifierStackCount("modifier_imba_gravekeepers_cloak", nil))
				end
			end
			return nil
		end
		)
		local buff = caster:FindModifierByName("modifier_imba_gravekeepers_cloak_aura")
		if buff then
			buff.units[parent:entindex()] = parent
		end
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

function modifier_imba_gravekeepers_cloak:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(self:GetCaster():GetModifierStackCount("modifier_imba_gravekeepers_cloak", nil))
	end
end

function modifier_imba_gravekeepers_cloak:OnStackCountChanged(iStack)
	local stack = self:GetStackCount()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if IsServer() and self.pfx then
		for i=2, stack + 2 - 1 do
			ParticleManager:SetParticleControl(self.pfx, i, Vector(1, 0, 0))
		end
		for i=stack + 2, 5 do
			ParticleManager:SetParticleControl(self.pfx, i, Vector(0, 0, 0))
		end
		if caster == parent and stack < self:GetAbility():GetSpecialValueFor("max_layers") then
			parent:AddNewModifierWhenPossible(parent, ability, "modifier_imba_gravekeepers_cloak_recover_timer", {duration = ability:GetSpecialValueFor("recovery_time")})
		end
	end
end

function modifier_imba_gravekeepers_cloak:GetModifierIncomingDamage_Percentage(keys)
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local stack = self:GetStackCount()
	local damage = keys.original_damage
	local reduction = (0 - (self:GetStackCount() * ability:GetSpecialValueFor("damage_reduction")))
	if parent:IsCreep() and not parent:IsConsideredHero() then
		reduction = reduction / 2
	end
	if IsServer() then
		if keys.attacker:IsBuilding() then
			return 0
		end
		if self:GetStackCount() > 0 and IsHeroDamage(keys.attacker, damage) and damage >= ability:GetSpecialValueFor("minimum_damage") then
			local buff = caster:FindModifierByName("modifier_imba_gravekeepers_cloak_aura")
			if buff then
				buff:DamageHealUnits(parent, damage)
			end
			if caster == parent then
				self:SetStackCount(self:GetStackCount() - 1)
			else
				self:SetStackCount(caster:GetModifierStackCount("modifier_imba_gravekeepers_cloak", nil))
			end
			return reduction
		end
		if damage >= ability:GetSpecialValueFor("minimum_damage") then
			return reduction
		end
	else
		return reduction
	end
end

function modifier_imba_gravekeepers_cloak:OnDestroy()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
		local buff = caster:FindModifierByName("modifier_imba_gravekeepers_cloak_aura")
		if buff then
			buff.units[parent:entindex()] = nil
		end
	end
end

modifier_imba_gravekeepers_cloak_recover_timer = class({})

function modifier_imba_gravekeepers_cloak_recover_timer:IsDebuff()			return false end
function modifier_imba_gravekeepers_cloak_recover_timer:IsHidden() 			return true end
function modifier_imba_gravekeepers_cloak_recover_timer:IsPurgable() 		return false end
function modifier_imba_gravekeepers_cloak_recover_timer:IsPurgeException() 	return false end

function modifier_imba_gravekeepers_cloak_recover_timer:OnDestroy()
	if IsServer() then
		local buff = self:GetParent():FindModifierByName("modifier_imba_gravekeepers_cloak")
		if buff then
			buff:SetStackCount(math.min(self:GetAbility():GetSpecialValueFor("max_layers"), buff:GetStackCount() + 1))
		end
	end
end