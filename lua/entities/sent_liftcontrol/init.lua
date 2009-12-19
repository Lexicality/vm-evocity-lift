include("shared.lua")
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

function ENT:Initialize()
	self:SetModel("models/props_junk/sawblade001a.mdl" );
	self:SetSolid  (SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:DrawShadow(false);
	self.PhysgunDisabled = true;
	self.m_tblToolsAllowed = {}
end
function ENT:Use(activator)
	if (not activator:IsPlayer()) then return end
	local pos = self:WorldToLocal(activator:GetEyeTrace().HitPos)
	local x,y = pos.x * 4, pos.y * -4 
	for k,v in ipairs(self.floorpose) do
		if (lift.isin(x,y,v[1],v[2],v[1]+20,v[2]+20)) then
			lift.RequestStop(k);
			return;
		end
	end
end