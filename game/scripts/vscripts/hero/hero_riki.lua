CreateEmptyTalents("riki")

imba_riki_tricks_of_the_trade = class({})

LinkLuaModifier("modifier_imba_tricks_of_the_trade_caster", "hero/hero_riki", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_tricks_of_the_trade_thinker", "hero/hero_riki", LUA_MODIFIER_MOTION_NONE)

function imba_riki_tricks_of_the_trade:IsHiddenWhenStolen() 	return false end
function imba_riki_tricks_of_the_trade:IsRefreshable() 			return true end
function imba_riki_tricks_of_the_trade:IsStealable() 			return true end
function imba_riki_tricks_of_the_trade:IsNetherWardStealable()	return false end
function imba_riki_tricks_of_the_trade:GetAssociatedSecondaryAbilities() return "imba_riki_tott_true" end
function imba_riki_tricks_of_the_trade:GetAOERadius() return self:GetSpecialValueFor("range") + self:GetCaster():GetTalentValue("special_bonus_imba_riki_1") end

function imba_riki_tricks_of_the_trade:GetBehavior()
	if self:GetCaster():HasScepter() then
		return (DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES)
	else
		return (DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES)
	end
end

function imba_riki_tricks_of_the_trade:GetCastRange()
	if self:GetCaster():HasScepter() then
		return self.BaseClass.GetCastRange(self, self:GetCaster():GetAbsOrigin(), self:GetCaster())
	else
		return (self:GetSpecialValueFor("range") + self:GetCaster():GetTalentValue("special_bonus_imba_riki_1") - self:GetCaster():GetCastRangeBonus())
	end
end

function imba_riki_tricks_of_the_trade:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:HasScepter() and self:GetCursorTarget() or caster
	local ability = caster:FindAbilityByName("imba_riki_tott_true")
	local thinker = CreateModifierThinker(caster, ability, "modifier_imba_tricks_of_the_trade_thinker", {duration = ability:GetChannelTime() + 0.1}, target:GetAbsOrigin(), caster:GetTeamNumber(), false)
	ability.target = target
	ability.thinker = thinker
	ability.pos = target:GetAbsOrigin()
	caster:CastAbilityNoTarget(ability, caster:GetPlayerOwnerID())
end

imba_riki_tott_true = class({})

function imba_riki_tott_true:IsHiddenWhenStolen() 		return true end
function imba_riki_tott_true:IsRefreshable() 			return false end
function imba_riki_tott_true:IsStealable() 				return false end
function imba_riki_tott_true:IsNetherWardStealable()	return false end
function imba_riki_tott_true:IsTalentAbility() 			return true end
function imba_riki_tott_true:IsHiddenAbilityCastable()	return true end
function imba_riki_tott_true:GetAssociatedPrimaryAbilities() return "imba_riki_tricks_of_the_trade" end
function imba_riki_tott_true:GetChannelTime() return (self:GetSpecialValueFor("duration") + (self:GetCaster():HasScepter() and self:GetSpecialValueFor("bonus_scepter") or 0)) end

function imba_riki_tott_true:OnSpellStart()
	local caster = self:GetCaster()
	local target = self.target
	caster:EmitSound("Hero_Riki.TricksOfTheTrade.Cast")
	caster:AddNoDraw()
end

function imba_riki_tott_true:OnChannelThink(flInterval)
	if not self.target:IsAlive() then
		self:GetCaster():InterruptChannel()
		return
	end
	if not self.thinker or self.thinker:IsNull() then
		return
	end
	self.thinker:SetAbsOrigin(self.target:GetAbsOrigin())
	self:GetCaster():SetAbsOrigin(self.thinker:GetAbsOrigin())
end

function imba_riki_tott_true:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	caster:RemoveNoDraw()
	self.thinker:ForceKill(false)
end

modifier_imba_tricks_of_the_trade_caster = class({})

function modifier_imba_tricks_of_the_trade_caster:IsDebuff()			return false end
function modifier_imba_tricks_of_the_trade_caster:IsHidden() 			return true end
function modifier_imba_tricks_of_the_trade_caster:IsPurgable() 			return false end
function modifier_imba_tricks_of_the_trade_caster:IsPurgeException() 	return false end
function modifier_imba_tricks_of_the_trade_caster:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_INVISIBLE] = false} end
function modifier_imba_tricks_of_the_trade_caster:GetPriority() return (MODIFIER_PRIORITY_SUPER_ULTRA + 1) end

modifier_imba_tricks_of_the_trade_thinker = class({})

function modifier_imba_tricks_of_the_trade_thinker:OnCreated()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_tricks_of_the_trade_caster", {})
		local radius = self:GetAbility():GetSpecialValueFor("range") + self:GetCaster():GetTalentValue("special_bonus_imba_riki_1")
		local duration = self:GetAbility():GetChannelTime()
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 1, Vector(radius, duration, duration))
		ParticleManager:SetParticleControl(pfx, 2, Vector(duration, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		local pfx_range = ParticleManager:CreateParticle("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx_range, 1, Vector(radius, 0, 0))
		ParticleManager:SetParticleControl(pfx_range, 2, Vector(10,0,0))
		ParticleManager:SetParticleControl(pfx_range, 3, Vector(100,0,0))
		ParticleManager:SetParticleControl(pfx_range, 15, Vector(197, 25, 255))
		self:AddParticle(pfx_range, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("attack_rate"))
		self:OnIntervalThink()
	end
end

function modifier_imba_tricks_of_the_trade_thinker:OnIntervalThink()
	if (self:GetElapsedTime() > 0.1 and not self:GetCaster():IsChanneling()) then
		self:Destroy()
		return
	end
	if self:GetParent():IsDisarmed() then
		return
	end
	local abs = self:GetParent():GetAbsOrigin()
	local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("range") + self:GetCaster():GetTalentValue("special_bonus_imba_riki_1"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		self:GetCaster():SetAbsOrigin(enemy[i]:GetAbsOrigin() + enemy[i]:GetForwardVector() * -120)
		self:GetCaster():PerformAttack(enemy[i], false, true, true, false, true, false, false)
		self:GetCaster():SetAbsOrigin(abs)
	end
end

function modifier_imba_tricks_of_the_trade_thinker:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_imba_tricks_of_the_trade_caster")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_Riki.TricksOfTheTrade")
	end
end
