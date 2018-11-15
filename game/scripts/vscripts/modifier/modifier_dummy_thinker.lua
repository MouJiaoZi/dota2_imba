modifier_dummy_thinker = class({})

function modifier_dummy_thinker:IsDebuff()			return false end
function modifier_dummy_thinker:IsHidden() 			return false end
function modifier_dummy_thinker:IsPurgable() 		return false end
function modifier_dummy_thinker:IsPurgeException() 	return false end

-- DO NO THING