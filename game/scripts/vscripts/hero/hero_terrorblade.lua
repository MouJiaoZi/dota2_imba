CreateEmptyTalents("terrorblade")

imba_terrorblade_demonic_power = class({})

LinkLuaModifier("modifier_imba_demonic_power", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)

function imba_terrorblade_demonic_power:IsTalentAbility() return true end
function imba_terrorblade_demonic_power:GetIntrinsicModifierName() return "modifier_imba_demonic_power" end

modifier_imba_demonic_power = class({})

function modifier_imba_demonic_power:IsDebuff()			return false end
function modifier_imba_demonic_power:IsHidden() 		return false end
function modifier_imba_demonic_power:IsPurgable() 		return false end
function modifier_imba_demonic_power:IsPurgeException() return false end
function modifier_imba_demonic_power:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_demonic_power:OnCreated()
	if IsServer() then
		self.attack_time = -10000
		self.pfx = ParticleManager:CreateParticle("particles/hero/terrorbalde/demonic_power.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(0,0,0))
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_demonic_power:OnStackCountChanged(stack)
	if IsServer() then
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(stack,0,0))
	end
end

function modifier_imba_demonic_power:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function modifier_imba_demonic_power:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or keys.target:IsBuilding() or not keys.target:IsAlive() then
		return
	end
	self:SetStackCount(math.min(self:GetStackCount() + self:GetAbility():GetSpecialValueFor("attack_gain"), self:GetAbility():GetSpecialValueFor("max_power")))
	self.attack_time = GameRules:GetGameTime()
end

function modifier_imba_demonic_power:OnIntervalThink()
	if self.attack_time < GameRules:GetGameTime() - self:GetAbility():GetSpecialValueFor("idle_time") then
		self:SetStackCount(math.max(self:GetStackCount() - self:GetAbility():GetSpecialValueFor("idle_lose"), self:GetAbility():GetSpecialValueFor("base_power")))
	end
end