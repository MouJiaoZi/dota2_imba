LinkLuaModifier("modifier_imba_dagon_passive", "items/item_dagon", LUA_MODIFIER_MOTION_NONE)

modifier_imba_dagon_passive = class({})

function modifier_imba_dagon_passive:IsDebuff()			return false end
function modifier_imba_dagon_passive:IsHidden() 		return true end
function modifier_imba_dagon_passive:IsPurgable() 		return false end
function modifier_imba_dagon_passive:IsPurgeException() return false end
function modifier_imba_dagon_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_dagon_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_dagon_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") + self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_imba_dagon_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_dagon_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end 
function modifier_imba_dagon_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end

local function IMBA_Dagon_Main_Target(iItemLevel, strPfxName, fDamage, hCaster, hTarget, hAbility)
	hCaster:EmitSound("DOTA_Item.Dagon.Activate")
	hTarget:EmitSound("DOTA_Item.Dagon5.Target")
	local pfx = ParticleManager:CreateParticle(strPfxName, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(pfx, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", hCaster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 2, Vector(iItemLevel, 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
	ApplyDamage({victim = hTarget, attacker = hCaster, damage_type = DAMAGE_TYPE_MAGICAL, damage = fDamage, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = hAbility})
end

local function IMBA_Dagon_Bounce_Target(iItemLevel, strPfxName, fDamage, hCaster, hTarget, hAbility, fBDamage, iBRange, iBDecay)
	local damage = fBDamage
	local units = {}
	table.insert(units, hTarget)
	for i, aunit in pairs(units) do
		local units1 = FindUnitsInRadius(hCaster:GetTeamNumber(), aunit:GetAbsOrigin(), nil, iBRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
		for _, unit1 in pairs(units1) do
			local no_yet = true
			for _, unit in pairs(units) do
				if unit == unit1 or unit1 == hCaster then
					no_yet = false
					break
				end
			end
			if no_yet then
				table.insert(units, unit1)
				break
			end
		end
	end
	for i=1, #units - 1 do
		local pfx = ParticleManager:CreateParticle(strPfxName, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, units[i], PATTACH_POINT_FOLLOW, "attach_hitloc", units[i]:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, units[i+1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[i+1]:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 2, Vector(iItemLevel, 0, 0))
		ParticleManager:ReleaseParticleIndex(pfx)
		ApplyDamage({victim = units[i+1], attacker = hCaster, damage_type = DAMAGE_TYPE_MAGICAL, damage = damage, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = hAbility})
		damage = damage * (1 - iBDecay / 100)
		units[i+1]:EmitSound("DOTA_Item.Dagon5.Target")
	end
end

item_imba_dagon = class({})

function item_imba_dagon:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/items_fx/dagon.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
	end
end

item_imba_dagon_2 = class({})

function item_imba_dagon_2:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_2:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/items_fx/dagon.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
	end
end

item_imba_dagon_3 = class({})

function item_imba_dagon_3:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_3:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/items_fx/dagon.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
	end
end

item_imba_dagon_4 = class({})

function item_imba_dagon_4:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_4:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/items_fx/dagon.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
	end
end

item_imba_dagon_5 = class({})

function item_imba_dagon_5:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_5:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/items_fx/dagon.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
	end
end

item_imba_dagon_6 = class({})

function item_imba_dagon_6:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_6:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/items_fx/dagon.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
		IMBA_Dagon_Bounce_Target(self:GetLevel(), "particles/items_fx/dagon.vpcf", 0, self:GetCaster(), self:GetCursorTarget(), self, self:GetSpecialValueFor("bounce_damage"), self:GetSpecialValueFor("bounce_range"), self:GetSpecialValueFor("bounce_decay"))
	end
end

item_imba_dagon_7 = class({})

function item_imba_dagon_7:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_7:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/econ/events/ti4/dagon_ti4.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
		IMBA_Dagon_Bounce_Target(self:GetLevel(), "particles/econ/events/ti4/dagon_ti4.vpcf", 0, self:GetCaster(), self:GetCursorTarget(), self, self:GetSpecialValueFor("bounce_damage"), self:GetSpecialValueFor("bounce_range"), self:GetSpecialValueFor("bounce_decay"))
	end
end

item_imba_dagon_8 = class({})

function item_imba_dagon_8:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_8:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/econ/events/ti5/dagon_ti5.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
		IMBA_Dagon_Bounce_Target(self:GetLevel(), "particles/econ/events/ti5/dagon_ti5.vpcf", 0, self:GetCaster(), self:GetCursorTarget(), self, self:GetSpecialValueFor("bounce_damage"), self:GetSpecialValueFor("bounce_range"), self:GetSpecialValueFor("bounce_decay"))
	end
end

item_imba_dagon_9 = class({})

function item_imba_dagon_9:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_9:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/econ/events/ti5/dagon_lvl2_ti5.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
		IMBA_Dagon_Bounce_Target(self:GetLevel(), "particles/econ/events/ti5/dagon_lvl2_ti5.vpcf", 0, self:GetCaster(), self:GetCursorTarget(), self, self:GetSpecialValueFor("bounce_damage"), self:GetSpecialValueFor("bounce_range"), self:GetSpecialValueFor("bounce_decay"))
	end
end

item_imba_dagon_10 = class({})

function item_imba_dagon_10:GetIntrinsicModifierName() return "modifier_imba_dagon_passive" end

function item_imba_dagon_10:OnSpellStart()
	if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
		IMBA_Dagon_Main_Target(self:GetLevel(), "particles/item/dagon/dagon_green.vpcf", self:GetSpecialValueFor("damage"), self:GetCaster(), self:GetCursorTarget(), self)
		IMBA_Dagon_Bounce_Target(self:GetLevel(), "particles/item/dagon/dagon_green.vpcf", 0, self:GetCaster(), self:GetCursorTarget(), self, self:GetSpecialValueFor("bounce_damage"), self:GetSpecialValueFor("bounce_range"), self:GetSpecialValueFor("bounce_decay"))
	end
end
