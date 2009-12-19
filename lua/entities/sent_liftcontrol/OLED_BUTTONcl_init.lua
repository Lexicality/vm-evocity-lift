MsgN"cl_init.lua"
include('shared.lua')
local timr = lift.WaitingPeriod;	-- Grab the length of the timer
local waiting = CurTime()	-- Initialize our waiting thingie
local wfloor = 0;			-- Default to not being on a floor to reduce code run between floors
local names = ENT.names;	-- Grab the names of the floors
local l = 10*math.sqrt(2);	-- Calculate the diagonal radius of the squares.
--[[
	Our 'circle' is an octogon whose diagonal radius is the same as the square it will be drawn in.
	Since this means there will be no edges, it will look the same as a circle. :>
--]]
local poly;
local cover = {};
local cntr = {x = 0, y = 0};	-- Centre of the circle
local posse = ENT.floorpose; -- store the top-left positions of each box in a local var for faster access

--[[ This hook be called when the lift hits a floor and starts waiting. ]]--
hook.Add("LiftStoppedAtFloor","Control Hook",function(floor)
	wfloor = floor;											-- Grab what floor we stopped at.
	if (not posse[wfloor]) then return end					-- If we're not on a valid floor don't bother
	local x, y = posse[wfloor][1]+10, posse[wfloor][2]+10	-- boxes are 20 wide and in the negative area, so add 10 to get the centre.
	poly = lift.buildpoly(x,y,l);							-- Make a new poly for this floor.
	waiting = CurTime() + timr;								-- Tell the draw function we're waiting
end);

--[[ This is the main draw function ]]--
local curtime,w,h,pos,x,y,todraw,amt,time,curfloor; -- These variables are used extensively by draw and don't need to be declared as local every frame.
function ENT:Draw()
	curfloor = self:GetDTInt(0);								-- This is the floor we are at, even if we're not waiting.
	pos = self:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)	-- This is where the player is looking at in terms of real space
	x,y = pos.x * 4, pos.y * -4 								-- This is where the player is looking at in terms of draw space
	curtime = CurTime();										-- Store the current time so we don't keep calling the function
	--[[ Start 3D2Din at 25% of normal size ]]--
	cam.Start3D2D(self.Entity:GetPos(), self.Entity:GetAngles() ,0.25)
		surface.SetFont"DefaultFixed"							-- We'll be using this font throught, for it's LED style.
		surface.SetTexture();									-- Ensure that no one's sneakily thrown a texture at us this frame that would mess up the pi.
		surface.SetDrawColor(200,200,200,255)					-- Choose a light gray (HEY GARRY MAKE THIS USE FUCKING COLOUR OBJECTS MAN)
		surface.DrawRect(-50,-25,105,50);						-- Draw the main background
		for k,v in ipairs(posse) do							-- Loop through each of the buttons
			surface.SetTextColor(0,0,0,255);					-- Unless a modifier happens, text will be black.
			surface.SetDrawColor(255,255,255,255);				-- Set the draw to white
			surface.DrawRect(v[1],v[2],20,20);					-- Draw the base background for the button
			--[[ If we're waiting at this button's floor. ]]--
			if (wfloor == k) then
				if (waiting < curtime) then						-- If we've been waiting too long then
					wfloor = 0;									-- Don't bother us about this again.
				else											-- Otherwise, let's get on with the pi.
					surface.SetDrawColor(92,189,70,255);		-- Set the background for the circle to a fairly plesant green
					surface.DrawPoly(poly);						-- Draw the base circle
					time = 1-(waiting - curtime)/timr			-- The time spent waiting so far, with 0 being no time and 1 being the entire length of the timer
					lift.adjustcover(time, cover, poly);		-- Adjust our cover based on that time
					surface.SetDrawColor(125,125,255,125);		-- Set the draw colour to a nice semi-transparent blue.
					surface.DrawPoly(cover);					-- Draw the cover.
					surface.SetTextColor(255,0,0,255);			-- Waiting floors have red text. TODO: Maybe different colour?
					surface.SetDrawColor(200,200,200,255);		-- Set the draw colour to the background one
					--[[ Draw four bars around the button so the circle's other corners aren't visible. ]]--
					surface.DrawRect(v[1],v[2]-5,20,5);
					surface.DrawRect(v[1],v[2]+20,20,5);
					surface.DrawRect(v[1]-5,v[2],5,20);
					surface.DrawRect(v[1]+20,v[2],5,20);
					--]]
				end
			--[[ If this floor is selected, or if we're at this floor but aren't moving after the waiting period. ]]--
			elseif (self:GetDTBool(k-1) or curfloor == k) then
				surface.SetDrawColor(92,189,70,255);			-- Set the draw colour to the same green as the circle
				surface.DrawRect(v[1],v[2],20,20);				-- Draw a new background for the button
				surface.SetTextColor(255,0,0,255);				-- Set the text (Again) to red
				if (curfloor == k) then								-- If we are waiting at this floor
					surface.SetDrawColor(125,125,255,125);		-- Set the darw colour to the blue we used above
					surface.DrawRect(v[1],v[2],20,20);			-- Make the current floor a nice greeny-blue.
				end
			--[[ If the player is looking at one of our buttons (the filthy swine) ]]--
			elseif (lift.isin(x,y,v[1],v[2],v[1]+20,v[2]+20)) then
				surface.SetDrawColor(125,125,255,125);			-- Set the draw colour to the infamous blue of above
				surface.DrawRect(v[1],v[2],20,20);				-- Highlight the button so they know they're looking at it
			end
			surface.SetDrawColor(100,100,100,255);				-- Pick a dark gray
			surface.DrawOutlinedRect(v[1],v[2],20,20);			-- Draw an outline for the button
			w,h = surface.GetTextSize(k);						-- Grab the size of the floor number so we can centre it
			surface.SetTextPos(v[1]+10-w/2,v[2]+10-h/2);		-- Offset the text pos so it draws in the centre
			surface.DrawText(k);								-- Draw the floor number						-- Draw the floor number
		end
		--[[ Meanwhile, outside of the world of buttonage ]]--
		surface.SetDrawColor(0,0,0,255);		-- Set the draw color to black
		surface.DrawRect(-45,5,95,15);			-- Draw a faux LED screen
		surface.SetDrawColor(100,100,100,255);	-- Set the draw colour to dark gray
		surface.DrawOutlinedRect(-45,5,95,15);	-- Make it somewhat more realistic with an outline
		curfloor = names[curfloor]				-- Grab the name of the floor we're at
		if (curfloor) then						-- Make sure this floor has a name
			surface.SetTextColor(255,0,0,255);	-- Red LED font
			w,h = surface.GetTextSize(curfloor);-- Get the width'n'height so we can offset the text
			surface.SetTextPos(0-w/2,12-h/2);	-- Centre the text
			surface.DrawText(curfloor);			-- Draw the name of the floor
		end
	cam.End3D2D()								-- And relax.
end
