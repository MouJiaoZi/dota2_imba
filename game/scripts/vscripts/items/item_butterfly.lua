
item_imba_butterfly = class({})

LinkLuaModifier("modifier_imba_butterflf_passive", "items/item_butterfly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_butterflf_unique", "items/item_butterfly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_butterfly_flutter", "items/item_butterfly", LUA_MODIFIER_MOTION_NONE)

function item_imba_butterfly:GetIntrinsicModifierName() return "modifier_imba_butterflf_passive" end

function item_imba_butterfly:OnSpellStart()
	self:GetCaster():EmitSound("DOTA_Item.Butterfly")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_imba_butterfly_flutter", {duration = self:GetSpecialValueFor("flutter_duration")})
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/butterfly_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
end

function item_imba_butterfly:ButterFlyAttack(target)
	local info = 
	{
		Target = target,
		Source = self:GetCaster(),
		Ability = self,	
		EffectName = "particles/item/yasha/yasha_projectile.vpcf",
		iMoveSpeed = math.max(900, self:GetCaster():GetProjectileSpeed()),
		vSourceLoc = self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function item_imba_butterfly:OnProjectileHit(target, location)
	if not target then
		return
	end
	self:GetCaster().splitattack = false
	self:GetCaster():PerformAttack(target, false, true, true, false, false, false, false)
	self:GetCaster().splitattack = true
end

modifier_imba_butterflf_passive = class({})

function modifier_imba_butterflf_passive:IsDebuff()			return false end
function modifier_imba_butterflf_passive:IsHidden() 		return true end
function modifier_imba_butterflf_passive:IsPurgable() 		return false end
function modifier_imba_butterflf_passive:IsPurgeException() return false end
function modifier_imba_butterflf_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_butterflf_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_butterflf_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_butterflf_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_butterflf_passive:GetModifierEvasion_Constant() return self:GetCaster():HasModifier("modifier_item_imba_butterfly_flutter") and 0 or self:GetAbility():GetSpecialValueFor("bonus_evasion")  end
function modifier_imba_butterflf_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end

function modifier_imba_butterflf_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_butterflf_unique", {})
	end
end

function modifier_imba_butterflf_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_butterflf_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_butterflf_unique")
	end
end

modifier_imba_butterflf_unique = class({})

function modifier_imba_butterflf_unique:IsDebuff()			return false end
function modifier_imba_butterflf_unique:IsHidden() 			return true end
function modifier_imba_butterflf_unique:IsPurgable() 		return false end
function modifier_imba_butterflf_unique:IsPurgeException() 	return false end
function modifier_imba_butterflf_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_butterflf_unique:OnCreated()
	self.pct = self:GetAbility():GetSpecialValueFor("proc_chance")
	self.range = self:GetAbility():GetSpecialValueFor("min_range")
	self.ability = self:GetAbility()
end

function modifier_imba_butterflf_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and self:GetParent().splitattack and PseudoRandom:RollPseudoRandom(self.ability, self.pct) and not self:GetParent():IsIllusion() and keys.target:IsAlive() then
		local range = math.max(self.range, self:GetParent():Script_GetAttackRange())
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= keys.target then
				self.ability:ButterFlyAttack(enemy)
				break
			end
		end
	end
end

function modifier_imba_butterflf_unique:OnDestroy()
	self.pct = nil
	self.range = nil
	self.ability = nil
end

modifier_item_imba_butterfly_flutter = class({})

function modifier_item_imba_butterfly_flutter:IsDebuff()			return false end
function modifier_item_imba_butterfly_flutter:IsHidden() 			return false end
function modifier_item_imba_butterfly_flutter:IsPurgable() 			return true end
function modifier_item_imba_butterfly_flutter:IsPurgeException() 	return true end
function modifier_item_imba_butterfly_flutter:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_item_imba_butterfly_flutter:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("flutter_move_speed") end
function modifier_item_imba_butterfly_flutter:GetEffectName() return "particles/items2_fx/butterfly_buff.vpcf" end
function modifier_item_imba_butterfly_flutter:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end