--[[
	~ sent_liftbutton init.lua ~
	~ Lexi ~
--]]
include("shared.lua")
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
resource.AddFile("materials/lift/arrow.vtf");

function ENT:Initialize()
	self:SetModel	("models//props_lab/clipboard.mdl");
	self:PhysicsInit(SOLID_VPHYSICS	);
	self:SetMoveType(MOVETYPE_NONE	);
	self:SetSolid   (SOLID_VPHYSICS	);
	self:SetUseType	(SIMPLE_USE		);
	self.PhysgunDisabled = true;
	self.m_tblToolsAllowed = {}
end

function ENT:Use(activator)
	if (not activator:IsPlayer()) then return end
	local pos = self:WorldToLocal(activator:GetEyeTrace().HitPos )--+ self:GetRight() - self:GetUp());
	local y,x = pos.x * 4, pos.y * 4 ;
	local v = self.buttonpos
	if (lift.isin(x,y,v[1],v[2],v[1]+10,v[2]+10)) then
		lift.RequestStop(self:GetDTInt(0));
	end
end