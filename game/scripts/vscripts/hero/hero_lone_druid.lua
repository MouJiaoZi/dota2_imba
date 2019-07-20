CreateEmptyTalents("lone_druid")

imba_lone_druid_spirit_bear = class({})

LinkLuaModifier("modifier_imba_spirit_bear_base", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spirit_bear_clone", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_spirit_bear:IsHiddenWhenStolen() 		return false end
function imba_lone_druid_spirit_bear:IsRefreshable() 			return true end
function imba_lone_druid_spirit_bear:IsStealable() 				return false end
function imba_lone_druid_spirit_bear:IsNetherWardStealable()	return false end

function imba_lone_druid_spirit_bear:OnUpgrade()
	if IsServer() and self:GetCaster():IsRealHero() and not self:GetCaster():IsTempestDouble() then
		local caster = self:GetCaster()
		if not self.base_bear then
			self.base_bear = CreateUnitByName("npc_imba_lone_druid_bear", Vector(30000, 30000, 0), false, caster, caster, caster:GetTeamNumber())
			self.base_bear:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
			self.base_bear:AddNewModifier(caster, self, "modifier_imba_spirit_bear_base", {})
			self.base_bear:ForceKill(false)
		end
		if not self.clone_bear then
			self.clone_bear = CreateUnitByName("npc_imba_lone_druid_bear", Vector(30000, 30000, 0), false, caster, caster, caster:GetTeamNumber())
			self.clone_bear:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
			self.clone_bear:AddNewModifier(caster, self, "modifier_imba_spirit_bear_clone", {})
			self.clone_bear:SetCanSellItems(false)
			self.clone_bear:ForceKill(false)
		end
	end
end

function imba_lone_druid_spirit_bear:OnInventoryContentsChanged()
	if not self.clone_bear then
		return
	end
	local caster = self:GetCaster()
	Timers:CreateTimer(0.1, function()
			for i=0, 8 do
				local item = self.clone_bear:GetItemInSlot(i)
				if item then
					UTIL_Remove(item)
				end
			end
			for i=0, 8 do
				local item = caster:GetItemInSlot(i)
				if item then
					self.clone_bear:AddItemByName(item:GetAbilityName())
				else
					self.clone_bear:AddItemByName("item_imba_dummy")
				end
			end
			for i=0, 8 do
				local item = self.clone_bear:GetItemInSlot(i)
				if item and item:GetAbilityName() == "item_imba_dummy" then
					UTIL_Remove(item)
				end
			end
			return nil
		end
	)
end

function imba_lone_druid_spirit_bear:OnSpellStart()
	local caster = self:GetCaster()
	if self:GetAutoCastState() then
		self.base_bear:ForceKill(false)
		self.clone_bear:RespawnUnit()
		FindClearSpaceForUnit(self.clone_bear, caster:GetAbsOrigin(), true)
		self.clone_bear:SetHealth(self.clone_bear:GetMaxHealth())
		self.clone_bear:SetMana(self.clone_bear:GetMaxMana())
	else
		self.clone_bear:ForceKill(false)
		self.base_bear:RespawnUnit()
		FindClearSpaceForUnit(self.base_bear, caster:GetAbsOrigin(), true)
		self.base_bear:SetHealth(self.base_bear:GetMaxHealth())
		self.base_bear:SetMana(self.base_bear:GetMaxMana())
	end
end

modifier_imba_spirit_bear_base = class({})

function modifier_imba_spirit_bear_base:IsDebuff()			return false end
function modifier_imba_spirit_bear_base:IsHidden() 			return true end
function modifier_imba_spirit_bear_base:IsPurgable() 		return false end
function modifier_imba_spirit_bear_base:IsPurgeException() 	return false end
function modifier_imba_spirit_bear_base:RemoveOnDeath()     return false end
function modifier_imba_spirit_bear_base:IsPermanent() 		return true end

modifier_imba_spirit_bear_clone = class({})

function modifier_imba_spirit_bear_clone:IsDebuff()			return false end
function modifier_imba_spirit_bear_clone:IsHidden() 		return true end
function modifier_imba_spirit_bear_clone:IsPurgable() 		return false end
function modifier_imba_spirit_bear_clone:IsPurgeException() return false end
function modifier_imba_spirit_bear_clone:RemoveOnDeath()    return false end
function modifier_imba_spirit_bear_clone:IsPermanent() 		return true end

function modifier_imba_spirit_bear_clone:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_spirit_bear_clone:OnIntervalThink()
	for i=0, 8 do
		local item = self.parent:GetItemInSlot(i)
		if item then
			item:SetDroppable(false)
		end
		local hero_item = self.caster:GetItemInSlot(i)
		if hero_item and item then
			if item:IsCooldownReady() and not hero_item:IsCooldownReady() then
				item:EndCooldown()
				item:StartCooldown(hero_item:GetCooldownTimeRemaining())
			elseif not item:IsCooldownReady() and hero_item:IsCooldownReady() then
				hero_item:EndCooldown()
				hero_item:StartCooldown(item:GetCooldownTimeRemaining())
			end
		end
	end
end