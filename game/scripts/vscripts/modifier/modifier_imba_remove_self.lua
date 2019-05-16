modifier_imba_remove_self = class({})

function modifier_imba_remove_self:OnCreated(keys)
	if IsServer() then
		self.unit = EntIndexToHScript(keys.entid)
	end
end

function modifier_imba_remove_self:OnDestroy()
	if IsServer() then
		self.unit:RemoveSelf()
		self.unit = nil
	end
end