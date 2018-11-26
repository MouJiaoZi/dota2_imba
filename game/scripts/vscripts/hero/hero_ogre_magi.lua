CreateEmptyTalents("ogre_magi")


imba_ogre_magi_multicast = class({})

LinkLuaModifier("modifier_imba_multicast_passive", "hero/hero_ogre_magi", LUA_MODIFIER_MOTION_NONE)

modifier_multicast_attack_range = class({})

function modifier_multicast_attack_range:IsDebuff()			return false end
function modifier_multicast_attack_range:IsHidden() 		return true end
function modifier_multicast_attack_range:IsPurgable() 		return false end
function modifier_multicast_attack_range:IsPurgeException() return false end
function modifier_multicast_attack_range:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_multicast_attack_range:GetModifierAttackRangeBonus() return 10000 end

function imba_ogre_magi_multicast:GetIntrinsicModifierName() return "modifier_imba_multicast_passive" end
function imba_ogre_magi_multicast:GetAbilityTextureName() return "custom/ogre_magi_multicast_"..self:GetCaster():GetModifierStackCount("modifier_imba_multicast_passive", nil) end
function imba_ogre_magi_multicast:ResetToggleOnRespawn() return false end

function imba_ogre_magi_multicast:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():FindModifierByName("modifier_imba_multicast_passive"):SetStackCount(1)
	else
		self:GetCaster():FindModifierByName("modifier_imba_multicast_passive"):SetStackCount(0)
	end
end

modifier_imba_multicast_passive = class({})

function modifier_imba_multicast_passive:IsDebuff()			return false end
function modifier_imba_multicast_passive:IsHidden() 			return true end
function modifier_imba_multicast_passive:IsPurgable() 		return false end
function modifier_imba_multicast_passive:IsPurgeException() 	return false end
function modifier_imba_multicast_passive:AllowIllusionDuplicate() return false end
function modifier_imba_multicast_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE} end
function modifier_imba_multicast_passive:GetModifierPercentageCooldown() return (self:GetAbility():GetSpecialValueFor("cdr_pct")) end

function modifier_imba_multicast_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or not self:GetAbility():IsCooldownReady() then
		return
	end
	if not self:GetParent().splitattack then
		return
	end
	local target = keys.target
	local ability = self:GetAbility()
	ability:UseResources(true, true, true)
	local multicast = 0
	if math.random(1,100) <= ability:GetSpecialValueFor("multicast_4") then
		multicast = 4
	elseif math.random(1,100) <= ability:GetSpecialValueFor("multicast_3") then
		multicast = 3
	elseif math.random(1,100) <= ability:GetSpecialValueFor("multicast_2") then
		multicast = 2
	end
	self:DoMultiAttack(self:GetParent(), target, multicast)
end

function modifier_imba_multicast_passive:DoMultiAttack(caster, target, times)
	for i = 1, times-1 do
		Timers:CreateTimer(i * self:GetAbility():GetSpecialValueFor("multicast_delay"), function()
			caster:StartGesture(ACT_DOTA_ATTACK)
			caster.splitattack = false
			caster:PerformAttack(target, true, true, true, true, true, false, false)
			caster.splitattack = true
			caster:EmitSound("Hero_OgreMagi.Fireblast.x"..i+1)
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			ParticleManager:SetParticleControl(pfx, 1, Vector(i+1, 1, 0))
			return nil
		end
		)
	end
end

local NoMultiCastItems = {
"item_imba_blink",
"item_tpscroll",
"item_imba_black_king_bar",
"item_black_king_bar",
"item_imba_blink_boots",
"item_imba_ultimate_scepter_synth",
"item_imba_manta",
"item_imba_magic_stick",
"item_imba_magic_wand",
"item_soul_ring",
"item_imba_armlet",
"item_imba_armlet_active",
"item_imba_bloodstone",
"item_imba_cyclone",
"item_imba_radiance",
"item_imba_refresher",
"item_imba_cheese",
"item_imba_soul_ring",
"item_urn_of_shadows",
"item_smoke_of_deceit",
"item_imba_ring_of_aquila",
"item_imba_moon_shard",
"item_imba_silver_edge",
"item_imba_octarine_core",
"item_imba_octarine_core_off",
"item_bottle",
"item_dust",
"item_flask",
"item_imba_shadow_blade",
"item_ward_observer",
"item_ward_sentry",
"item_spirit_vessel",
"item_refresher_shard",
"item_ward_dispenser",
"item_travel_boots_2",
"item_travel_boots",
"item_power_treads",
"item_imba_power_treads_2",
}

function modifier_imba_multicast_passive:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if self.nocast or keys.unit ~= self:GetParent() or not self:GetAbility():IsCooldownReady() then
		return
	end
	if IsInTable(keys.ability:GetName(), NoMultiCastItems) then
		return
	end
	local caster = self:GetParent()
	local ability = keys.ability
	self:GetAbility():UseResources(true, true, true)
	local target = ability:GetCursorTarget()
	local pos = ability:GetCursorPosition()
	local multicast = 0
	if math.random(1,100) <= self:GetAbility():GetSpecialValueFor("multicast_4") then
		multicast = 4
	elseif math.random(1,100) <= self:GetAbility():GetSpecialValueFor("multicast_3") then
		multicast = 3
	elseif math.random(1,100) <= self:GetAbility():GetSpecialValueFor("multicast_2") then
		multicast = 2
	end
	if target then
		if self:GetStackCount() == 0 then
			self:DoMultiTargetAbility(caster, target, ability, multicast)
		else
			local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetCastRange(caster:GetAbsOrigin(), caster) + caster:GetCastRangeBonus(), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
			for i=2, multicast do
				if units[i] then
					self:DoMultiTargetAbility(caster, units[i], ability, 2)
				end
			end
		end
		return
	end
	if pos then
		self:DoMultiPositionAbility(caster, pos, ability, multicast)
		return
	end
	self:DoMultiNoTargetAbility(caster, ability, multicast)
end

function modifier_imba_multicast_passive:DoMultiTargetAbility(caster, target, ability, times)
	for i = 1, times-1 do
		Timers:CreateTimer(i * self:GetAbility():GetSpecialValueFor("multicast_delay"), function()
			self.nocast = true
			caster:SetCursorCastTarget(target)
			ability:OnSpellStart()
			self.nocast = false
			caster:EmitSound("Hero_OgreMagi.Fireblast.x"..i+1)
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			ParticleManager:SetParticleControl(pfx, 1, Vector(i+1, 1, 0))
			return nil
		end
		)
	end
end

function modifier_imba_multicast_passive:DoMultiPositionAbility(caster, pos, ability, times)
	for i = 1, times-1 do
		Timers:CreateTimer(i * self:GetAbility():GetSpecialValueFor("multicast_delay"), function()
			self.nocast = true
			caster:SetCursorPosition(pos)
			ability:OnSpellStart()
			self.nocast = false
			caster:EmitSound("Hero_OgreMagi.Fireblast.x"..i+1)
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			ParticleManager:SetParticleControl(pfx, 1, Vector(i+1, 1, 0))
			return nil
		end
		)
	end
end

function modifier_imba_multicast_passive:DoMultiNoTargetAbility(caster, ability, times)
	for i = 1, times-1 do
		Timers:CreateTimer(i * self:GetAbility():GetSpecialValueFor("multicast_delay"), function()
			self.nocast = true
			ability:OnSpellStart()
			self.nocast = false
			caster:EmitSound("Hero_OgreMagi.Fireblast.x"..i+1)
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			ParticleManager:SetParticleControl(pfx, 1, Vector(i+1, 1, 0))
			return nil
		end
		)
	end
end

function modifier_imba_multicast_passive:OnCreated()
	if IsServer() and not self:GetParent():IsIllusion() then
		self:StartIntervalThink(1.0)
		self.nocast_check = 0
		self.noattack_check = 0
	end
end

function modifier_imba_multicast_passive:OnIntervalThink()
	if self.nocast then
		self.nocast_check = self.nocast_check + 1
	else
		self.nocast_check = 0
	end
	if self.nocast_check >=5 then
		self.nocast = false
	end
end