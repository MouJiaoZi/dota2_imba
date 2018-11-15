

item_imba_hand_of_midas = class({})

LinkLuaModifier("modifier_imba_midas_passive", "items/item_midas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_midas_unique", "items/item_midas", LUA_MODIFIER_MOTION_NONE)

function item_imba_hand_of_midas:GetIntrinsicModifierName() return "modifier_imba_midas_passive" end

function item_imba_hand_of_midas:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local XP = target:GetDeathXP() * self:GetSpecialValueFor("xp_multiplier") * (1 + CUSTOM_XP_BONUS / 100)
	local gold = self:GetSpecialValueFor("bonus_gold") * (1 + CUSTOM_GOLD_BONUS / 100)
	target:EmitSound("DOTA_Item.Hand_Of_Midas")
	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
	ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	target:SetDeathXP(0)
	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	target:Kill(self, caster)
	caster:AddExperience(XP, DOTA_ModifyXP_CreepKill, false, false)
	caster:ModifyGold(gold, false, DOTA_ModifyGold_CreepKill)
	SendOverheadEventMessage(PlayerResource:GetPlayer(caster:GetPlayerID()), OVERHEAD_ALERT_GOLD, target, gold, nil)
end

modifier_imba_midas_passive = class({})

function modifier_imba_midas_passive:IsDebuff()			return false end
function modifier_imba_midas_passive:IsHidden() 		return true end
function modifier_imba_midas_passive:IsPurgable() 		return false end
function modifier_imba_midas_passive:IsPurgeException() return false end
function modifier_imba_midas_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_midas_passive:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_midas_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end

function modifier_imba_midas_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_midas_unique", {})
	end
end

function modifier_imba_midas_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_midas_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_midas_unique")
	end
end

modifier_imba_midas_unique = class({})

function modifier_imba_midas_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_midas_unique:OnDestroy() self.ability = nil end

function modifier_imba_midas_unique:IsDebuff()			return false end
function modifier_imba_midas_unique:IsHidden() 			return true end
function modifier_imba_midas_unique:IsPurgable() 		return false end
function modifier_imba_midas_unique:IsPurgeException() 	return false end
function modifier_imba_midas_unique:GetIMBAGoldPercentage() return self.ability:GetSpecialValueFor("passive_gold_bonus") end