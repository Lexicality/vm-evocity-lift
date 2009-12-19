class CDetour
{
public:
	static void (CDetour::* CFTTBlocked)(CBaseEntity *);

	void CFTTBlockedD(CBaseEntity *);
};

void (CDetour::* CDetour::CFTTBlocked)(CBaseEntity *) = NULL;

typedef void (CDetour::* *CFTTBlocked_t)(CBaseEntity *);