modifier_dummy_thinker = class({})

function modifier_dummy_thinker:IsDebuff()			return false end
function modifier_dummy_thinker:IsHidden() 			return true end
function modifier_dummy_thinker:IsPurgable() 		return false end
function modifier_dummy_thinker:IsPurgeException() 	return false end
function modifier_dummy_thinker:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

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