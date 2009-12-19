--[[
	~ Liftcontroller - Shared ~
	~ Lexi ~
--]]
MsgN"liftcontroller.lua"
lift = {
	WaitingPeriod = 10; -- How long the lift should wait between floors.
}

--[[ Direction indicators ]]--
LIFT_DIR_UP 	= -1;
LIFT_DIR_DOWN	=  1;

--[[ This function checks if x,y is in the box defined by x2,y2 and x3, y3. ]]--
lift.isin = function(x,y,x2,y2,x3,y3)
	return (x < math.max(x2,x3) and x > math.min(x2,x3) and
			y < math.max(y2,y3) and y > math.min(y2,y3));
end