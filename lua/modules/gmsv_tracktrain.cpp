#define GAME_DLL

#include <GMLuaModule.h>

#include <eiface.h>
#include <cbase.h>
#include <trains.h>

#include <windows.h>
#include <detours.h>

#include "cdetour.h"

#include "sigscan.h"

GMOD_MODULE(Open, Close);

ILuaInterface *gLua = NULL;
IVEngineServer *engine = NULL;

CSigScan CFTTBlocked_Sig;

void CDetour::CFTTBlockedD(CBaseEntity *pOther)
{
	ILuaObject *hookT = gLua->GetGlobal("hook");
		ILuaObject *callM = hookT->GetMember("Call");
			gLua->Push(callM);
	
			gLua->Push("TrackTrainBlocked");
			gLua->PushNil();
			gLua->PushDouble(((CFuncTrackTrain *)this)->entindex());
			gLua->PushDouble(pOther->entindex());

			gLua->Call(4, 1);
		callM->UnReference();
	hookT->UnReference();

	ILuaObject *returnL = gLua->GetReturn(0);
	
	if (returnL->isNil())
		(this->*CFTTBlocked)(pOther);

	returnL->UnReference();
}

int Open(lua_State *L)
{
	gLua = Lua();

	CreateInterfaceFn engineFactory = Sys_GetFactory("engine.dll");

	engine = (IVEngineServer *)engineFactory(INTERFACEVERSION_VENGINESERVER, NULL);

	CreateInterfaceFn serverFactory = Sys_GetFactory("server.dll");

	CSigScan::sigscan_dllfunc = (CreateInterfaceFn)serverFactory(INTERFACEVERSION_SERVERGAMEDLL, NULL);
	CSigScan::GetDllMemInfo();

	CFTTBlocked_Sig.Init((unsigned char *)"\x83\xEC\x64\x56\x57\x8B\x7C\x24\x70\xF6\x87\x00\x01\x00\x00\x01", "xxxxxxxxxxxxxxxx", 16);

	if (CFTTBlocked_Sig.is_set)
	{
		CDetour::CFTTBlocked = *((CFTTBlocked_t)&CFTTBlocked_Sig.sig_addr);

		DetourTransactionBegin();
		DetourUpdateThread(GetCurrentThread());

		DetourAttach(&(PVOID &)CDetour::CFTTBlocked, (PVOID)(&(PVOID &)CDetour::CFTTBlockedD));

		DetourTransactionCommit();
	}
	else
	{
		gLua->Msg("[CFuncTrackTrain::Blocked] Signature scan failed\n");
	}

	return 0;
}

int Close(lua_State *L)
{
	if (CFTTBlocked_Sig.is_set)
	{
		DetourTransactionBegin();
		DetourUpdateThread(GetCurrentThread());

		DetourDetach(&(PVOID &)CDetour::CFTTBlocked, (PVOID)(&(PVOID &)CDetour::CFTTBlockedD));

		DetourTransactionCommit();
	}

	return 0;
}