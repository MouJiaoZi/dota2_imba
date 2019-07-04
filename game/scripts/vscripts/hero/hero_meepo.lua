modifier_imba_meepo_clone_controller = class({})

function modifier_imba_meepo_clone_controller:IsDebuff()			return false end
function modifier_imba_meepo_clone_controller:IsHidden() 			return true end
function modifier_imba_meepo_clone_controller:IsPurgable() 			return false end
function modifier_imba_meepo_clone_controller:IsPurgeException() 	return false end
function modifier_imba_meepo_clone_controller:RemoveOnDeath() 		return false end

function modifier_imba_meepo_clone_controller:OnCreated()
	if IsServer() then
		self.base = self:GetCaster()
		self.meepo = self:GetParent()
		self.base_item = {}
		self.clone_item = {}
		self:StartIntervalThink(0.5)
		self.meepo:AddNewModifier(self.meepo, nil, "modifier_imba_talent_modifier_adder", {})
		self.meepo:AddNewModifier(self.meepo, nil, "modifier_imba_movespeed_controller", {})
		self.meepo:AddNewModifier(self.meepo, nil, "modifier_imba_ability_layout_contoroller", {})
	end
end

function modifier_imba_meepo_clone_controller:OnIntervalThink()
	if self.base:GetModifierStackCount("modifier_imba_moon_shard_consume", nil) > 0 then
		self.meepo:AddNewModifier(self.base, nil, "modifier_imba_moon_shard_consume", {}):SetStackCount(self.base:GetModifierStackCount("modifier_imba_moon_shard_consume", nil))
	end
	if self.base:HasModifier("modifier_imba_consumable_scepter_consumed") then
		self.meepo:AddNewModifier(self.base, nil, "modifier_imba_consumable_scepter_consumed", {})
	end
	local base_item = {}
	local clone_item = {}
	--[[for i=0, 5 do
		base_item[i] = (self.base:GetItemInSlot(i) and self.base:GetItemInSlot(i):GetPurchaser() == self.base) and self.base:GetItemInSlot(i):GetAbilityName() or "nil"
		--clone_item[i] = self.meepo:GetItemInSlot(i) and self.meepo:GetItemInSlot(i):GetAbilityName() or nil
	end
	local same = true
	for i=0, 5 do
		if base_item[i] ~= self.base_item[i] then
			same = false
			break
		end
	end
	if not same then
		self.base_item = base_item
		-- Remove all clone's items
		for i=0, 5 do
			if self.meepo:GetItemInSlot(i) then
				UTIL_Remove(self.meepo:GetItemInSlot(i))
			end
		end
		for i=0, 5 do
			if self.base_item[i] and IMBA_BOOTS[ self.base_item[i] ] then
				self.meepo:AddItemByName(self.base_item[i])
			else
				self.meepo:AddItemByName("item_imba_dummy")
			end
		end
		for i=0, 5 do
			if self.meepo:GetItemInSlot(i) and self.meepo:GetItemInSlot(i):GetAbilityName() == "item_imba_dummy" then
				UTIL_Remove(self.meepo:GetItemInSlot(i))
			end
		end
	end]]
end

local IMBA_BOOTS = {}

IMBA_BOOTS['item_imba_arcane_boots'] = true
IMBA_BOOTS['item_imba_guardian_greaves'] = true
IMBA_BOOTS['item_imba_phase_boots_2'] = true
IMBA_BOOTS['item_imba_tranquil_boots_2'] = true
IMBA_BOOTS['item_imba_blink_boots'] = true
IMBA_BOOTS['item_imba_power_treads_2'] = true
IMBA_BOOTS['item_power_treads'] = true
IMBA_BOOTS['item_boots'] = true
IMBA_BOOTS['item_travel_boots'] = true
IMBA_BOOTS['item_travel_boots_2'] = true
IMBA_BOOTS['item_phase_boots'] = true
IMBA_BOOTS['item_tranquil_boots'] = true

imba_meepo_stand_we_divided = class({})

LinkLuaModifier("modifier_imba_stand_we_divided", "hero/hero_meepo.lua", LUA_MODIFIER_MOTION_NONE)

function imba_meepo_stand_we_divided:GetIntrinsicModifierName() return "modifier_imba_stand_we_divided" end
function imba_meepo_stand_we_divided:IsTalentAbility() return true end
function imba_meepo_stand_we_divided:OnAbilityPhaseStart() return false end

function imba_meepo_stand_we_divided:OnInventoryContentsChanged()
	if not self.buff then
		return
	end
	Timers:CreateTimer(0.1, function()
			for i=1, #self.buff.meepos do
				for j=0, 5 do
					local item = self.buff.meepos[i]:GetItemInSlot(j)
					local base_item = self.buff.base:GetItemInSlot(j)
					if item then
						UTIL_Remove(item)
					end
				end
				for j=0, 5 do
					local item = self.buff.base:GetItemInSlot(j)
					if item and IMBA_BOOTS[item:GetAbilityName()] then
						self.buff.meepos[i]:AddItemByName(item:GetAbilityName())
					else
						self.buff.meepos[i]:AddItemByName("item_imba_dummy")
					end
				end
				if not self.buff.meepos[i]:GetTP() then
					self.buff.meepos[i]:AddItemByName("item_tpscroll"):SetCurrentCharges(30)
					self.buff.meepos[i]:SwapItems(6, 15)
				end
				self.buff.meepos[i]:CalculateStatBonus()
				for j=0, 5 do
					local item = self.buff.meepos[i]:GetItemInSlot(j)
					if item and item:GetAbilityName() == "item_imba_dummy" then
						UTIL_Remove(item)
					end
				end
			end
			return nil
		end
	)
end

modifier_imba_stand_we_divided = class({})

function modifier_imba_stand_we_divided:IsDebuff()			return false end
function modifier_imba_stand_we_divided:IsHidden() 			return true end
function modifier_imba_stand_we_divided:IsPurgable() 		return false end
function modifier_imba_stand_we_divided:IsPurgeException() 	return false end
function modifier_imba_stand_we_divided:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_stand_we_divided:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end

function modifier_imba_stand_we_divided:OnCreated()
	if IsServer() then
		if not self:GetParent():IsTrueHero() then
			return
		end
		self.base = self:GetParent()
		self.meepos = {}
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.ability.buff = self
		local pfx = ParticleManager:CreateParticleForPlayer("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self.ability:GetSpecialValueFor("radius"), 0, 0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(10, 0, 0))
		ParticleManager:SetParticleControl(pfx, 3, Vector(100, 0, 0))
		ParticleManager:SetParticleControl(pfx, 15, Vector(PLAYER_COLORS[self:GetParent():GetPlayerOwnerID()][1], PLAYER_COLORS[self:GetParent():GetPlayerOwnerID()][2], PLAYER_COLORS[self:GetParent():GetPlayerOwnerID()][3]))
		self:AddParticle(pfx, true, false, 15, false, false)
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_stand_we_divided:OnIntervalThink()
	if not self.parent:HasAbility("meepo_divided_we_stand") then
		self:StartIntervalThink(-1)
		return
	end
	if not self.ability:IsCooldownReady() or self.ability:GetAutoCastState() then
		return
	end
	--Add new meepo to table
	local meepo_num = self.parent:FindAbilityByName("meepo_divided_we_stand"):GetLevel() + (self.parent:HasScepter() and 1 or 0)
	if meepo_num ~= #self.meepos then
		local meepo = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_ANY_ORDER, false)
		for i=1, #meepo do
			if meepo[i]:GetPlayerOwnerID() == self.parent:GetPlayerOwnerID() and meepo[i]:IsRealHero() and not IsInTable(meepo[i], self.meepos) and self.base ~= meepo[i] then
				self.meepos[#self.meepos + 1] = meepo[i]
			end
		end
		for i=0, 4 do
			self.base:SwapItems(i, i + 1)
			self.base:SwapItems(i, i + 1)
		end
	end
	local nearby_meepo = {}
	if self.base:IsAlive() then
		nearby_meepo[#nearby_meepo + 1] = self.base
	end
	for i=1, #self.meepos do
		if (self.base:GetAbsOrigin() - self.meepos[i]:GetAbsOrigin()):Length2D() <= self.ability:GetSpecialValueFor("radius") and self.meepos[i]:IsAlive() then
			nearby_meepo[#nearby_meepo + 1] = self.meepos[i]
		end
	end
	local not_full = false
	for i=1, #nearby_meepo do
		if nearby_meepo[i]:GetHealth() < nearby_meepo[i]:GetMaxHealth() then
			not_full = true
			break
		end
	end
	local hp_pct = 0
	if #nearby_meepo > 1 and not_full then
		for _, hero in pairs(nearby_meepo) do
			hp_pct = hp_pct + hero:GetHealthPercent()
		end
		hp_pct = (hp_pct / #nearby_meepo) / 100
		for _, hero in pairs(nearby_meepo) do
			local health = hero:GetMaxHealth() * hp_pct
			if health >= 1 then
				hero:SetHealth(health)
			end
		end
		self.ability:UseResources(true, true, true)
	end
end

function modifier_imba_stand_we_divided:OnDeath(keys)
	if not self.base then
		return
	end
	if IsServer() and (keys.unit == self.base or IsInTable(keys.unit, self.meepos)) then
		if self.base:IsAlive() then
			TrueKill2(self.base, self.base, nil)
		end
		for i=1, #self.meepos do
			if self.meepos[i]:IsAlive() then
				TrueKill2(self.meepos[i], self.meepos[i], nil)
			end
		end
		local ability = self.base:FindAbilityByName("imba_wraith_king_reincarnation")
		if self.base:HasModifier("modifier_imba_aegis") then
			self.base:RemoveModifierByName("modifier_imba_aegis")
		else
			if ability and ability:GetLevel() > 0 and ability:IsCooldownReady() and ability:IsOwnersManaEnough() then
				ability:UseResources(true, true, true)
			end
		end
		for i=1, #self.meepos do
			local ability = self.meepos[i]:FindAbilityByName("imba_wraith_king_reincarnation")
			if self.meepos[i] then
				self.meepos[i]:RemoveModifierByName("modifier_imba_aegis")
			else
				if ability and ability:GetLevel() > 0 and ability:IsCooldownReady() and ability:IsOwnersManaEnough() then
					ability:UseResources(true, true, true)
				end
			end
		end
	end
end
