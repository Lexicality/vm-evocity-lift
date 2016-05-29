--[[
	~ sent_liftbutton cl_init.lua ~
	~ Lexi ~
--]]
include('shared.lua')
local timr = lift.WaitingPeriod;
local tex = surface.GetTextureID"lift/arrow"
local lfloor,dir = 0,0;
local waiting = 0;
hook.Add("LiftStartedMoving","Lift Moving buttons",function(ndir, target)
	dir = ndir;
end);
hook.Add("LiftPassedFloor","Lift Passing buttons",function(floor,ndir)
	lfloor = floor;
end);
hook.Add("LiftStoppedAtFloor","Lift Stopping buttons",function(floor)
	lfloor	= floor;
	dir		= 0;
	waiting	= CurTime() + timr;
end);
local downpoly = {
	{ x = -4, y = -4, u = 0, v = 0},
	{ x =  4, y = -4, u = 1, v = 0},
	{ x =  4, y =  4, u = 1, v = 1},
	{ x = -4, y =  4, u = 0, v = 1};
};
local uppoly = {
	{ x = -4, y = -4, u = 1, v = 1},
	{ x =  4, y = -4, u = 0, v = 1},
	{ x =  4, y =  4, u = 0, v = 0},
	{ x = -4, y =  4, u = 1, v = 0};
};
local bx,by		= ENT.buttonpos[1],ENT.buttonpos[2];
local bpoly		= lift.buildpoly(bx+5,by+5,5*math.sqrt(2));
local bcover	= {};
local ipoly = {
	{ x = -2, y = -4},
	{ x =  2, y = -4},
	{ x =  2, y = -4},
	{ x = -2, y = -4};
}
local w,h,ang,word,x,y,ctime,time,iwait;
function ENT:Draw()
	ctime = CurTime();
	iwait = waiting > ctime;
	mfloor = iwait and lfloor == self:GetDTInt(0);
	ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(),90)
	pos = self:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)	-- This is where the player is looking at in terms of real space
	y,x = pos.x * 4, pos.y * 4 								-- This is where the player is looking at in terms of draw space
	cam.Start3D2D(self:GetPos(), ang, 0.25)
		--[[ Background ]]--
		surface.SetDrawColor(200,200,200,255)
		surface.DrawRect(-18,-8,26,37);
		--[[ Screen	]]--
		surface.SetDrawColor(0,0,0,255);
		surface.DrawRect(-15,-5,20,11);	
		--[[ Direction indicator]]--
		if (dir ~= 0) then
			surface.SetDrawColor(255,255,255,255);
			surface.SetTexture(tex);
			if (dir < 0) then
				surface.DrawPoly(uppoly);
			else
				surface.DrawPoly(downpoly);
			end
		elseif (iwait) then
			time = 1-(waiting - ctime)/timr		-- The time spent waiting so far, with 0 being no time and 1 being the entire length of the timer
			surface.SetDrawColor(255,0,0,255);
			surface.DrawRect(-2,-4,4,8);
			surface.SetDrawColor(0,0,0,255);
			surface.SetTexture(0)
			ipoly[3].y = -4 + 8 * time;
			ipoly[4].y = -4 + 8 * time;
			surface.DrawPoly(ipoly);
--			surface.DrawRect(-2,-4,4,8*time);
		end
		--[[ Last Floor Passed Indicator ]]--
		surface.SetTextColor(255,0,0,255);
		surface.SetFont"DefaultFixed";
		w,h = surface.GetTextSize(lfloor);
		surface.SetTextPos(-9-w/2,1-h/2);
		surface.DrawText(lfloor);
		--[[ Screen Border ]]--
		surface.SetDrawColor(100,100,100,255);
		surface.DrawOutlinedRect(-16,-6,22,13);
		--[[ Button Border ]]--
		if (self:GetDTBool(0) or mfloor) then	
			surface.SetDrawColor(255,  0,  0,255);
		else
			surface.SetDrawColor(100,100,100,255);
		end
		surface.DrawRect(bx,by,10,10);
		if (mfloor) then
			lift.adjustcover(time, bcover, bpoly);	-- Adjust our cover based on that time
			surface.SetDrawColor(100,100,100,255);
			surface.DrawPoly(bcover);
			surface.SetDrawColor(200,200,200,255);	-- Set the draw colour to the background one
			--[[ Draw four bars around the button so the circle's other corners aren't visible. ]]--
			surface.DrawRect(bx,   by-3 ,10,3 );
			surface.DrawRect(bx,   by+10,10,3 );
			surface.DrawRect(bx-3 ,by   ,3 ,10);
			surface.DrawRect(bx+10,by   ,3 ,10);
		end
			
		--[[ Button ]]--
		surface.SetDrawColor(230,230,230,255);
		surface.DrawRect(bx+1,by+1,8,8);
		--[[ Make the button slightly darker if the player is looking at one of our buttons (the filthy swine) ]]--
		if (lift.isin(x,y,bx,by,bx+10,by+10)) then
			surface.SetDrawColor(0,0,0,40);
			surface.DrawRect(bx+1,by+1,8,8);
		end
	cam.End3D2D()
end
