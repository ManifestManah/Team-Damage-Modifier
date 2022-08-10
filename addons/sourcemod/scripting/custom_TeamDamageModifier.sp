#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo =
{
	name		= "[CS:GO] Team Damage Modifier",
	author		= "Manifest @Road To Glory & SanjayS",
	description	= "Prevents general damage from team attacking, but allows molotov, incendiary and high explosive grenades to deal damage.",
	version		= "V. 1.0.0 [Beta]",
	url			= "https://github.com/ManifestManah & https://github.com/sanjaysrocks"
};


// Global Weapon List - Add weapons here 
char weapons[2][] =
{
	/* NOTE:
	     If you wish to add any additional weapons, simply change the number 
	     in weapons[2] to match the current amount of weapons you wish to restrict.
	     Then also add your weapon to the list as seen below. */

	"inferno",
	"hegrenade_projectile",
}

// Global Handles - Used By ConVars
ConVar Cvar_TeamDamageModifier;

public void OnPluginStart()
{
	Cvar_TeamDamageModifier = CreateConVar("Manifest_TeamDamageModifier", "1", "Should friendly fire only damage teammates if the weapon used are molotovs, incendiary and high explosive grenades? - [Yes = 1 | No = 0]");

	Cvar_TeamDamageModifier.AddChangeHook(TeamDamageModifierChanged);

	int TeamDamageModifier = GetConVarInt(Cvar_TeamDamageModifier);
	if(TeamDamageModifier == 1)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client))
			{
				SDKHook(client, SDKHook_OnTakeDamage, Event_OnDamageTaken);
			}
		}
	}
}

 
public void TeamDamageModifierChanged(ConVar convar, char[] oldValue, char[] newValue)
{
	if(StringToInt(newValue) == 0)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client))
			{
				SDKUnhook(client, SDKHook_OnTakeDamage, Event_OnDamageTaken);
			}
		}
	}
	else
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client))
			{
				SDKHook(client, SDKHook_OnTakeDamage, Event_OnDamageTaken);
			}
		}
	}
}


public void OnClientPostAdminCheck(int client)
{
	int TeamDamageModifier = GetConVarInt(Cvar_TeamDamageModifier);
	if(TeamDamageModifier == 1)
	{
		if(IsValidClient(client))
		{
			SDKHook(client, SDKHook_OnTakeDamage, Event_OnDamageTaken);
		}
	}
}


public void OnClientDisconnect(int client)
{
	int TeamDamageModifier = GetConVarInt(Cvar_TeamDamageModifier);
	if(TeamDamageModifier == 1)
	{
		if(IsValidClient(client))
		{
			SDKUnhook(client, SDKHook_OnTakeDamage, Event_OnDamageTaken);
		}
	}
}


public Action Event_OnDamageTaken(int client, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	if(!IsValidClient(attacker))
	{
		return Plugin_Continue;
	}

	if(!IsValidEntity(inflictor))
	{
		return Plugin_Continue;
	}

	if(GetClientTeam(client) != GetClientTeam(attacker))
	{
		return Plugin_Continue
	}

	char classname[64];

	GetEdictClassname(inflictor, classname, sizeof(classname));

	for(int i = 0; i < sizeof(weapons); i++)
	{
		if(StrEqual(classname, weapons[i], false))
		{
			return Plugin_Continue;
		}
	}

	damage = 0.0;

	return Plugin_Changed;
}


public bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientConnected(client) || !IsClientInGame(client) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}

	return true;
}