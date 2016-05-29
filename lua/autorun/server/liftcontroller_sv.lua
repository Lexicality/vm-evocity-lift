--[[
	~ Lift Controller ~
	~ Lexi ~
--]]
-- require"tracktrain"

AddCSLuaFile("autorun/liftcontroller.lua");
AddCSLuaFile("autorun/client/liftcontroller_cl.lua");
local liftent,control;
local buttons = {};
local floors = {};
--[[ Each of these is a height above the ground where the lift should stop ]]--
--[[
	Three put because it's a bit of a whore sometimes, so we make
	 sure that it will stop somewhere in that vecinity.
]]--
floors[132]   = 1;--"Spawn";
floors[139]   = 1;--"Ground";
floors[140]   = 1;--"Ground";
floors[141]   = 1;--"Ground";
floors[902]   = 2;--"Cells";
floors[903]   = 2;--"Cells";
floors[904]   = 2;--"Cells";
floors[1543]  = 3;--"Quartermaster`s Office";
floors[1544]  = 3;--"Quartermaster`s Office";
floors[1545]  = 3;--"Quartermaster`s Office";
floors[2673]  = 4;--"Mayor`s Office";
floors[2674]  = 4;--"Mayor`s Office";
floors[2675]  = 4;--"Mayor`s Office";
-- These are for remembering where the lift is at.
local lastfloor,lastpos = 0,0;
-- This is what direction the lift should be going in, and how many units/frame it is actually going at. (negative is up, positive is down)
local dir,speed = LIFT_DIR_UP;
-- This is where the requested floors live
local requests = {};
-- Is the lift waiting at a floor?
local waiting;
-- So we don't define local variables every frame.
local floor,pos;
local timr = lift.WaitingPeriod;

local function calcup()
    for i = lastfloor, 4 do
        if (requests[i]) then
			control:SetDTInt(0,0);
            liftent:Fire("setspeeddir", LIFT_DIR_UP, 0);
			hook.Call("LiftStartedMoving", GAMEMODE, LIFT_DIR_UP, i);
            return true;
        end
    end
end
local function calcdown()
    for i = lastfloor, 1, -1 do
        if (requests[i]) then
			control:SetDTInt(0,0);
            liftent:Fire("setspeeddir", LIFT_DIR_DOWN, 0);
			hook.Call("LiftStartedMoving", GAMEMODE, LIFT_DIR_DOWN, i);
            return true;
        end
    end
end
local function calcnextstop()
    waiting = false;
    if (dir < 0) then
        return calcup() or calcdown();
    else
        return calcdown() or calcup();
    end
end


function lift.RequestStop(floor)
	floor = math.floor(floor);
	if (requests[floor] or not buttons[floor]) then return end
	requests[floor] = true;
    if (speed == 0) then
		if (floor == lastfloor) then
			requests[floor] = nil;
			return;
		elseif (not waiting) then
			calcnextstop();
		end
	end
	control:SetDTBool(floor-1,true);
	buttons[floor]:SetDTBool(0,true);
end

local poses = {
	{Vector(-7116.3062, -9381.0703,  131), Angle(90,-90,0)},
	{Vector(-7116.3062, -9381.0703,  900), Angle(90,-90,0)},
	{Vector(-7120.0703, -9407.0293, 1541), Angle(90,180,0)},
	{Vector(-7122.0703, -9407.0293, 2678), Angle(90,180,0)}
}
local buttposs = {
	Vector(-7106, -9382, 132 ),
	Vector(-7106, -9382, 894 ),
	Vector(-7122, -9382, 1530),
	Vector(-7124, -9379.2402, 2682.73),
	Vector(-7115, -9354, 138);
};

--[[Hooques]]--
hook.Add("InitPostEntity","LiftControl",function()
	if (game.GetMap():lower() ~= "rp_evocity_v2d") then return end
	liftent = ents.FindByName("PDElevatorIsAPainInYourAss")[1];
	if (not IsValid(liftent)) then
		error("No lift ent on map, cannot continue.");
	end
	liftent:SetKeyValue("dmg",20);
	liftent:SetKeyValue("spawnflags",530);
	control = ents.Create("sent_liftcontrol");
	control:SetAngles(Angle(180,90,-90));
	control:Spawn();
	control:Activate();
	if cider and cider.propprotection then
		cider.propprotection.GiveToWorld(control)
	end
	control:SetParent(liftent);
	control:SetLocalPos(Vector(82.3584, 6.0117, -5.5452));
	for _,pos in ipairs(buttposs) do
		local tab = ents.FindInSphere(pos,16);
		for _,ent in ipairs(tab) do
			if (IsValid(ent) and ent:GetClass() == "func_button") then
				ent:Remove();
			end
		end
	end
	--]]
	local btn
	for i,data in ipairs(poses) do
		btn = ents.Create("sent_liftbutton");
		btn:SetPos(data[1]);
		btn:SetAngles(data[2]);
		btn:Spawn();
		btn:Activate();
		btn:SetDTInt(0,i);
		if cider and cider.propprotection then
			cider.propprotection.GiveToWorld(btn)
		end
		buttons[i] = btn
	end
end);
--[
hook.Add("TrackTrainBlocked","Lift Blocking Preventer",function(train,blocker)--,train)
	train,blocker = Entity(train),Entity(blocker);
	if (not (IsValid(blocker) and IsValid(train))) then return end
    if (blocker:IsPlayer() or blocker:GetClass() == "player") then
--        blocker:TakeDamage(10,train,train);
        return
    end
	if (blocker:GetClass():find"prop_") then
		print("removing",blocker,"!")
		blocker:Remove();
	else
		print"setting pos"
		blocker:SetPos(Vector(-7149.0635, -9119.085, 1024.406));
	end
end)
--]]
umsg.PoolString("LiftStartedMoving")
umsg.PoolString("LiftPassedFloor")
umsg.PoolString("LiftStoppedAtFloor")
--[[ Call these hooks on the client as well as the server ]]--
hook.Add("LiftStartedMoving","Lift Moving Notifier",function(dir, target)
	umsg.Start("LiftStartedMoving");
	umsg.Char(dir);
	umsg.Char(target);
	umsg.End();
	print("The lift has started moving "..(dir == LIFT_DIR_DOWN and "down" or "up").." from "..lastfloor.." towards "..target..".");
end);
hook.Add("LiftPassedFloor","Lift Passing Notifier",function(floor,dir)
	umsg.Start("LiftPassedFloor");
	umsg.Char(floor);
	umsg.Char(dir);
	umsg.End();
	print("The lift has passed floor "..floor.." moving "..(dir == LIFT_DIR_DOWN and "down" or "up").."wards.");
end);
hook.Add("LiftStoppedAtFloor","Lift Stopping Notifier",function(floor)
	umsg.Start("LiftStoppedAtFloor");
	umsg.Char(floor);
	umsg.End();
	print("The lift has stopped at floor "..floor..".");
end);
	
hook.Add("Think", "Lift Pos Checker",function()
	if (not IsValid(liftent)) then return end
    pos = math.ceil(liftent:GetPos().z);
    speed = lastpos - pos;
    if (pos == lastpos) then return end
    lastpos = pos;
    floor = floors[pos];
    if (floor and floor ~= lastfloor) then
        lastfloor = floor;
		if floor == 1 then
			dir = LIFT_DIR_UP;
			liftent:Fire("setspeeddir",dir,0.01);
		elseif floor == 4 then
			dir = LIFT_DIR_DOWN;
			liftent:Fire("setspeeddir",dir,0.01);
		elseif requests[floor] then
			liftent:Fire("Stop","",0);
		else
			hook.Call("LiftPassedFloor", GAMEMODE, floor, dir);
			return;
		end
		requests[floor] = nil;
		control:SetDTBool(floor-1,false);
		buttons[floor]:SetDTBool(0,false);
		control:SetDTInt(0,floor);
		waiting = true;
		timer.Simple(timr,calcnextstop);
		hook.Call("LiftStoppedAtFloor",GAMEMODE,floor);
    end
end);
