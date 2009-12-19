--[[
	~ Lift Controller ~
	~ Lexi ~
--]]
MsgN"liftcontroller_cl.lua"
local bla = {x = 0, y = 0};
local function remakecover(cover, num, poly)
	for i in ipairs(cover) do
		cover[i] = nil;
	end
	cover.lnum = num;
	cover[1] = poly.cntr;
	for i = 2,num+1 do
		cover[i] = poly[i-1];
	end
	cover[num+2] = bla;
end
--[[
	This function adjusts the 'cover' poly so it
	 creates a pie-chart style poly that covers up
	 'time'% of the 'poly' poly.
--]]
function lift.adjustcover(time, cover, poly)
	local num,amt = math.ceil(time*8),2*math.pi*time;
	if (num ~= cover.lnum) then
		remakecover(cover, num, poly);
	end
	local tg = cover[num + 2];
	tg.x, tg.y = poly.cntr.x + math.sin(amt) * poly.r, poly.cntr.y + math.cos(amt) * -poly.r;
end
--[[ This makes an octagonal poly centred about x,y with radius r. ]]--
function lift.buildpoly(x,y,r)
	return {																-- Make a new circle.
		{x = x, 						y = y-r							},	-- Top of circle											
		{x = x+math.sin(  math.pi/4)*r,	y = y+math.cos(  math.pi/4)*-r	},	-- 1/8ths clockwise
		{x = x+r,						y = y							},	-- right corner of circle
		{x = x+math.sin(3*math.pi/4)*r,	y = y+math.cos(3*math.pi/4)*-r	},	-- 3/8ths clockwise
		{x = x,							y = y+r							},	-- bottom of circle
		{x = x+math.sin(5*math.pi/4)*r,	y = y+math.cos(5*math.pi/4)*-r	},	-- 5/8ths clockwise
		{x = x-r,						y = y							},	-- left corner of circle
		{x = x+math.sin(7*math.pi/4)*r,	y = y+math.cos(7*math.pi/4)*-r	},	-- 7/8ths clockwise
		cntr =  {x = x, y = y},
		r = r;
	};
end
usermessage.Hook("LiftStartedMoving",function(msg)
	hook.Call("LiftStartedMoving", GAMEMODE, msg:ReadChar(), msg:ReadChar());
end);
usermessage.Hook("LiftPassedFloor",function(msg)
	hook.Call("LiftPassedFloor", GAMEMODE, msg:ReadChar(), msg:ReadChar());
end);
usermessage.Hook("LiftStoppedAtFloor",function(msg)
	hook.Call("LiftStoppedAtFloor", GAMEMODE, msg:ReadChar());
end);