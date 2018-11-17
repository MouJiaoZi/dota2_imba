
IllusionManager = class({})

if uniqueIllsuionTable == nil then
	uniqueIllsuionTable = {}
end

if illsuionTableByModel == nil then
	illsuionTableByModel = {}
end

LinkLuaModifier("modifier_imba_illusion", "libraries/illusionmanager", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_illusion_hidden", "libraries/illusionmanager", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_illusion_hidden_model", "libraries/illusionmanager", LUA_MODIFIER_MOTION_NONE)

modifier_imba_illusion = class({})

function modifier_imba_illusion:IsHidden() return true end
function modifier_imba_illusion:IsPurgable() return false end
function modifier_imba_illusion:IsPurgeException() return false end
function modifier_imba_illusion:DeclareFunctions() return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MIN_HEALTH} end

function modifier_imba_illusion:OnCreated(keys)
	if IsServer() then
		self.dmg_out = keys.dmg_out
		self.dmg_in = keys.dmg_in
		self:SetStackCount(keys.illusion_type)
	end
end

function modifier_imba_illusion:OnRefresh(keys) self:OnCreated(keys) end

function modifier_imba_illusion:GetModifierTotalDamageOutgoing_Percentage() return self.dmg_out end
function modifier_imba_illusion:GetModifierIncomingDamage_Percentage() return self.dmg_in end
function modifier_imba_illusion:GetMinHealth() return 1 end

function modifier_imba_illusion:OnTakeDamage(keys)
	if IsServer() and keys.unit == self:GetParent() and self:GetParent():GetHealth() == 1 then
		self:Destroy()
	end
end

function modifier_imba_illusion:OnDestroy()
	if IsServer() then
		local sound = CreateModifierThinker(self:GetCaster(), nil, "modifier_imba_illusion_hidden", {duration = 2.0}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
		sound:EmitSound("General.Illusion.Destroy")
		local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/illusion_killed.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, (self:GetParent():GetAbsOrigin()+Vector(0,0,100)))
		ParticleManager:ReleaseParticleIndex(pfx)
		IllusionManager:Wipe(self:GetParent())
		ProjectileManager:ProjectileDodge(self:GetParent())
		self:GetParent():AddNewModifier(self:GetCaster(), nil, "modifier_imba_illusion_hidden", {})
		if attacker and IsEnemy(self:GetParent(), attacker) then
			attacker:ModifyGold(5, true, DOTA_ModifyGold_CreepKill)
			SendOverheadEventMessage(PlayerResource:GetPlayer(attacker:GetPlayerID()), OVERHEAD_ALERT_GOLD, attacker, 5, nil)
		end
	end
end

modifier_imba_illusion_hidden = class({})

function modifier_imba_illusion_hidden:IsHidden() return true end
function modifier_imba_illusion_hidden:IsPurgable() return false end
function modifier_imba_illusion_hidden:IsPurgeException() return false end
function modifier_imba_illusion_hidden:CheckState() return {[MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end 
function modifier_imba_illusion_hidden:DeclareFunctions() return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_BONUS_DAY_VISION, MODIFIER_PROPERTY_MODEL_CHANGE} end
function modifier_imba_illusion_hidden:GetBonusDayVision() return -3000 end
function modifier_imba_illusion_hidden:GetBonusNightVision() return -3000 end
function modifier_imba_illusion_hidden:GetModifierTotalDamageOutgoing_Percentage() return -100 end
function modifier_imba_illusion_hidden:GetModifierIncomingDamage_Percentage() return -100 end
function modifier_imba_illusion_hidden:GetModifierModelChange() return "models/development/invisiblebox.vmdl" end

function modifier_imba_illusion_hidden:OnCreated()
	if IsServer() and self:GetParent():GetName() ~= "npc_dota_thinker" then
		--self:GetParent():AddNoDraw()
		self:OnIntervalThink()
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_illusion_hidden:OnIntervalThink()
	--local pos = self:GetCaster():GetAbsOrigin()
	if self:GetElapsedTime() >= 1.5 then
		self:GetParent():SetAbsOrigin(Vector(50000,50000,-1000))
	end
	self:GetParent():FindModifierByName("modifier_illusion"):SetDuration(2.0, true)
	self:GetParent():Stop()
	self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_imba_illusion_hidden_model", {duration = 1.1})
end

function modifier_imba_illusion_hidden:OnDestroy()
	if IsServer() then
		--self:GetParent():RemoveNoDraw()
		self:GetParent():RemoveModifierByName("modifier_imba_illusion_hidden_model")
	end
end

modifier_imba_illusion_hidden_model = class({})

function modifier_imba_illusion_hidden_model:IsHidden() return true end
function modifier_imba_illusion_hidden_model:IsPurgable() return false end
function modifier_imba_illusion_hidden_model:IsPurgeException() return false end
function modifier_imba_illusion_hidden_model:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE} end
function modifier_imba_illusion_hidden_model:GetModifierModelChange() return "models/development/invisiblebox.vmdl" end

function IllusionManager:CreateIllusion(hBaseUnit, vSpawnAbs, vSpawnForward, iOutgoingDMG, iIncomingDMG, iIllsuionType, fDuration, hOwner, sUniqueString)
	local owner = hOwner or hBaseUnit
	local illusion

	if sUniqueString then
		if not uniqueIllsuionTable[sUniqueString] or uniqueIllsuionTable[sUniqueString]:IsNull() then
			uniqueIllsuionTable[sUniqueString] = CreateUnitByName(hBaseUnit:GetUnitName(), vSpawnAbs, true, owner, owner, owner:GetTeamNumber())
		end
		illusion = uniqueIllsuionTable[sUniqueString]
	else
		for _, illusionTable in pairs(illsuionTableByModel) do
			if illusionTable[1] == hBaseUnit:GetModelName() and illusionTable[2] and not illusionTable[2]:IsNull() and not IllusionManager:IsActive(illusionTable[2]) and illusionTable[2]:GetPlayerOwnerID() == hOwner:GetPlayerOwnerID() then
				illusion = illusionTable[2]
				break
			end
			illusion = nil
		end
		if illusion == nil then
			illusion = CreateUnitByName(hBaseUnit:GetUnitName(), vSpawnAbs, true, owner, owner, owner:GetTeamNumber())
			table.insert(illsuionTableByModel, {hBaseUnit:GetModelName(), illusion, owner})
		end
	end

	local forward = vSpawnForward or owner:GetForwardVector()
	illusion:Stop()
	illusion:SetForwardVector(forward)
	illusion:MakeIllusion()
	illusion:SetControllableByPlayer(owner:GetPlayerID(), false)
	Timers:CreateTimer(FrameTime(), function()
		FindClearSpaceForUnit(illusion, vSpawnAbs, true)
		return nil
	end
	)
	IllusionManager:SetUpIllusion(illusion, owner, hBaseUnit, iOutgoingDMG, iIncomingDMG, iIllsuionType, fDuration)
	return illusion
end

local forbidden_buff = {
	"modifier_medusa_stone_gaze",
	"modifier_morphling_replicate",
	"modifier_gyrocopter_flak_cannon_scepter",
	"modifier_morphling_replicate_manager",
	}

function IllusionManager:SetUpIllusion(hIllusion, hOwner, hBaseUnit, iOutgoingDMG, iIncomingDMG, iIllsuionType, fDuration)
	for i=1, (hBaseUnit:GetLevel() - hIllusion:GetLevel()) do
		if hIllusion:IsHero() then
			hIllusion:HeroLevelUp(false)
		end
	end
	IllusionManager:Wipe(hIllusion)
	hIllusion:SetAbilityPoints(0)
	hIllusion:RemoveModifierByName("modifier_imba_illusion_hidden")
	hIllusion:EmitSound("General.Illusion.Create")
	----------------
	local dummyAbilityName = "dummy_unit_state"
	local abilityTable = {}
	for i=0, 23 do
		local ability = hBaseUnit:GetAbilityByIndex(i)
		if ability then
			abilityTable[i] = {ability:GetAbilityName(), ability:GetLevel()}
		end
	end
	for i=0, 23 do
		if abilityTable[i] then
			local ability = hIllusion:AddAbility(abilityTable[i][1])
			if abilityTable[i][2] > 0 then
				ability:SetLevel(abilityTable[i][2])
			end
		else
			--hIllusion:AddAbility(dummyAbilityName)
		end
	end
	for i=0, 23 do
		hIllusion:RemoveAbility(dummyAbilityName)
	end
	----------------
	local dummyItemName = "item_imba_dummy"
	local itemTable = {}
	for i=0, 8 do
		local item = hBaseUnit:GetItemInSlot(i)
		if item then
			itemTable[i] = {item:GetName(), nil}
			if item:GetCurrentCharges() then
				itemTable[i][2] = item:GetCurrentCharges()
			end
		end
	end
	for i=0, 8 do
		if itemTable[i] then
			local item = hIllusion:AddItemByName(itemTable[i][1])
			if itemTable[i][2] ~= nil then
				item:SetCurrentCharges(itemTable[i][2])
			end
			if item:GetName() == "item_imba_armlet" and hBaseUnit:GetModifierStackCount("midifier_imba_armlet_active_unique", nil) > 0 then
				item:OnSpellStart()
			end
		else
			hIllusion:AddItemByName(dummyItemName)
		end
	end
	for i=0, 8 do
		local item = hIllusion:GetItemInSlot(i)
		if item and item:GetName() == dummyItemName then
			hIllusion:RemoveItem(item)
		end
	end
	-----------------
	local buffTable = hBaseUnit:FindAllModifiers()
	for _, buff in pairs(buffTable) do
		if string.find(buff:GetName(), "modifier_special_bonus_") or (buff:GetAbility() and buff:GetAbility():GetLevel() > 0) then
			if (buff.AllowIllusionDuplicate and not buff:AllowIllusionDuplicate()) or (buff:GetAbility():IsItem() and buff:GetName() ~= "midifier_imba_armlet_active_unique") or IsInTable(buff:GetName(), forbidden_buff) then
				--nothing
			else
				print(buff:GetName())
				local ibuff = hIllusion:AddNewModifier(hBaseUnit, buff:GetAbility(), buff:GetName(), {duration = buff:GetDuration()})
				if ibuff then
					ibuff:SetStackCount(buff:GetStackCount())
				end
			end
		end
	end
	-----------------
	local duration = 0
	if fDuration < 0 then
		duration = -1
	else
		duration = fDuration + FrameTime() * 2
	end
	if hIllusion:HasModifier("modifier_illusion") then
		hIllusion:FindModifierByName("modifier_illusion"):SetDuration(duration, true)
	else
		local illbuff = hIllusion:AddNewModifier(hOwner, nil, "modifier_illusion", {duration = duration})
		illbuff:SetDuration(duration, true)
	end
	local dmg_out = iOutgoingDMG - 100
	local dmg_in = iIncomingDMG - 100
	local illusion_type = iIllsuionType
	local illusionTable = {dmg_out = dmg_out, dmg_in = dmg_in, illusion_type = illusion_type, duration = fDuration}
	hIllusion:AddNewModifier(hOwner, nil, "modifier_imba_illusion", illusionTable)
	hIllusion:SetHealth(hBaseUnit:GetHealth())
	hIllusion:SetMana(hBaseUnit:GetMana())
end

function IllusionManager:Wipe(hIllusion)
	for i=0, 23 do
		local ability = hIllusion:GetAbilityByIndex(i)
		if ability and not ability:IsNull() then
			hIllusion:RemoveAbility(ability:GetAbilityName())
		end
	end
	for i=0, 8 do
		local item = hIllusion:GetItemInSlot(i)
		if item and not item:IsNull() then
			hIllusion:RemoveItem(item)
		end
	end
	hIllusion:RemoveModifierByName("modifier_imba_illusion")
	local buffs = hIllusion:FindAllModifiers()
	for _, buff in pairs(buffs) do
		if buff:GetName() ~= "modifier_imba_illusion_hidden" and buff:GetName() ~= "modifier_illusion" and not buff:IsNull() then
			buff:Destroy()
		end
	end
end

function IllusionManager:IsActive(hIllusion)
	if hIllusion:IsIllusion() and hIllusion:HasModifier("modifier_imba_illusion") then
		return true
	end
	if hIllusion:IsIllusion() and hIllusion:HasModifier("modifier_imba_illusion_hidden") then
		return false
	end
end
