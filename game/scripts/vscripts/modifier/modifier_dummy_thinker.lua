modifier_dummy_thinker = class({})

function modifier_dummy_thinker:IsDebuff()			return false end
function modifier_dummy_thinker:IsHidden() 			return true end
function modifier_dummy_thinker:IsPurgable() 		return false end
function modifier_dummy_thinker:IsPurgeException() 	return false end
function modifier_dummy_thinker:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

--[[
	@params:
	string: destroy_sound
	string: create_sound
]]

function modifier_dummy_thinker:OnCreated(keys)
	if IsServer() and IsInToolsMode() and self:GetParent():GetName() == "npc_dota_thinker" then
		--self:StartIntervalThink(0.3)
		self:OnIntervalThink()
	end
	if IsServer() then
		self.kvtable = keys
		if self.kvtable.create_sound then
			self:GetParent():EmitSound(self.kvtable.create_sound)
		end
	end
end

function modifier_dummy_thinker:OnIntervalThink()
	DebugDrawCircle(self:GetParent():GetAbsOrigin(), Vector(255,0,0), 100, 50, true, 2.0)
	if self:GetAbility() then
		DebugDrawText(self:GetParent():GetAbsOrigin(), self:GetAbility():GetAbilityName(), false, 2.0)
	end
end

function modifier_dummy_thinker:OnDestroy()
	if IsServer() then
		if self.kvtable.destroy_sound then
			self:GetParent():EmitSound(self.kvtable.destroy_sound)
		end
		self.kvtable = nil
	end
end

-- DO NO THING

modifier_imba_base_protect = class({})

function modifier_imba_base_protect:IsDebuff()			return false end
function modifier_imba_base_protect:IsHidden() 			return true end
function modifier_imba_base_protect:IsPurgable() 		return false end
function modifier_imba_base_protect:IsPurgeException() 	return false end
function modifier_imba_base_protect:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

function modifier_imba_base_protect:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_base_protect:OnIntervalThink()
	local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(units) do
		if not unit:IsControllableByAnyPlayer() then
			unit:ForceKill(false)
		end
	end
end

modifier_imba_t2_tower_vision = class({})

function modifier_imba_t2_tower_vision:IsDebuff()			return false end
function modifier_imba_t2_tower_vision:IsHidden() 			return true end
function modifier_imba_t2_tower_vision:IsPurgable() 		return false end
function modifier_imba_t2_tower_vision:IsPurgeException() 	return false end

function modifier_imba_t2_tower_vision:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_t2_tower_vision:OnIntervalThink()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if self:GetParent():IsAlive() then
			AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 1400, 0.5, false)
		else
			self:Destroy()
		end
	end
end