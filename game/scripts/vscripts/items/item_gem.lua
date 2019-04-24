item_imba_soul_of_truth = class({})

LinkLuaModifier("modifier_item_imba_soul_of_truth", "items/item_gem", LUA_MODIFIER_MOTION_NONE)

function item_imba_soul_of_truth:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Item.DropGemWorld")
	local buff = caster:AddNewModifier(caster, self, "modifier_item_imba_soul_of_truth", {duration = self:GetSpecialValueFor("duration")})
	caster:AddNewModifier(caster, self, "modifier_item_gem_of_true_sight", {duration = self:GetSpecialValueFor("duration")})
	buff.ability = self
	buff.armor = buff.ability:GetSpecialValueFor("armor")
	buff.health_regen = buff.ability:GetSpecialValueFor("health_regen")
	self:Destroy()
end

modifier_item_imba_soul_of_truth = class({})

function modifier_item_imba_soul_of_truth:GetTexture() return "imba_soul_of_truth" end
function modifier_item_imba_soul_of_truth:IsDebuff()			return false end
function modifier_item_imba_soul_of_truth:IsHidden() 			return false end
function modifier_item_imba_soul_of_truth:IsPurgable() 			return false end
function modifier_item_imba_soul_of_truth:IsPurgeException()	return false end
function modifier_item_imba_soul_of_truth:RemoveOnDeath() 		return false end

function modifier_item_imba_soul_of_truth:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and not keys.reincarnate then
		self:Destroy()
	end
end

function modifier_item_imba_soul_of_truth:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticleForTeam("particles/basic_ambient/generic_true_sight.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetParent():GetTeamNumber())
		self:AddParticle(pfx, false, false, 15, false, true)
	end
end

function modifier_item_imba_soul_of_truth:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_DEATH} end
function modifier_item_imba_soul_of_truth:GetModifierPhysicalArmorBonus() return self.armor end
function modifier_item_imba_soul_of_truth:GetModifierConstantHealthRegen() return self.health_regen end

function modifier_item_imba_soul_of_truth:OnDestroy()
	self.ability = nil
	self.armor = nil
	self.health_regen = nil
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_item_gem_of_true_sight")
	end
end
