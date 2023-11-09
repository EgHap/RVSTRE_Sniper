#include maps\mp\gametypes\_hud_util;

Init()
{
	replacefunc(maps\mp\_utility::allowTeamChoice, ::ReplaceAllowTeamChoice);	
	
	level.Anti_Hardscope = true;
	level.Anti_DropShot = true;

	setDvar("sv_enableDoubleTaps", 1);
	setDvar("g_gametype", 1);

    	SetDvar("g_TeamName_Axis", "^1Others");
    	SetDvar("g_TeamName_Allies", "^5RVSTRE");

	SetDvar("g_TeamIcon_Allies", "iw5_cardicon_nuke");
    	SetDvar("g_TeamIcon_Axis", "iw5_cardicon_smiley");
	
	
	level.callbackplayerdamagestub = level.callbackplayerdamage;
    	level.callbackplayerdamage = ::DisableDamages;	
	
	DeletesBombs();
	
	
	level thread OnPlayerConnected();
}

ReplaceAllowTeamChoice()
{
	return false;
}

isSniper(WEAPON)
{
	if(isSubStr(WEAPON, "cheytac") ||
	isSubStr(WEAPON, "msr") ||
	isSubStr(WEAPON, "l96a1") ||
	//isSubStr(WEAPON, "barrett") ||
	//isSubStr(WEAPON, "dragunov") ||
	//isSubStr(WEAPON, "as50") ||
	WEAPON == "throwingknife_mp")
		return true;
	return false;
}


OnPlayerConnected()
{
    for (;;)
    {
        level waittill("connected", player);
		player thread OnPlayerSpawned();

		
		player thread DisplayHud();
		player thread KillstreakPlayer();
		player thread AntiHardscope();
	}
}
OnPlayerSpawned()
{    
	self endon("disconnect");
	for (;;)
    {
        self waittill("changed_kit");
		self thread AntiDS();
		if(isSubStr(self GetCurrentWeapon(), "usp") || isSniper(self GetCurrentWeapon()) == false)
			GiveIntervention();		
	}	
}

KillstreakPlayer()
{
	self endon ("disconnect");
	level endon("game_ended");
	self.hudkillstreak = createFontString ("Objective", 1);
	self.hudkillstreak setPoint ("CENTER", "TOP", "CENTER", 10);
	self.hudkillstreak.label = &"^5KILLSTREAK: ^7";
	
	while(true)
	{
		self.hudkillstreak setValue(self.pers["cur_kill_streak"]);
		wait 0.5;
	}	
}

DisplayHud()
{
    self endon("disconnect");
    level endon("game_ended");

    self.someText = self createFontString("Objective", 1f);
    self.someText setPoint("BOTTOMCENTER", "BOTTOMCENTER");
    self.someText setText("^5Name: ^7" + self.Name + " ^5Slot: ^7" + self GetEntityNumber());
}

AntiHardscope()
{
    self endon("disconnect");	
    adscycle = 0;
	for(;;)
    {
		
		if(self PlayerAds() >= 1 && isSniper(self GetCurrentWeapon()) && level.Anti_Hardscope == true)
		{
			adscycle++;
		}
		else
		{
			adscycle = 0;
		}
		
		if(adscycle >= 9)
		{
			adscycle = 0;
			self AllowAds(false);
			self IPrintLnBold("^1Hardscoping is not allowed");
			wait 0.05;
		}
		if(self AdsButtonPressed() == false)
		{
			self AllowAds(true);
		}
        wait 0.05;
    }
}

AntiDS()
{
    self endon("disconnect");

    for(;;)
    {
        if (self GetStance() == "prone" && self.name == "KC NoTzz" && level.Anti_DropShot == true)
        {
            self IPrintLnBold("^1casse toi nomerde");
            self SetStance("stand");
        }
        if (self GetStance() == "prone" && self.name != "KC NoTzz" && level.Anti_DropShot == true)
        {
            self IPrintLnBold("^1DropShoting is not allowed");
            self SetStance("stand");
        }
        wait 0.05;
    }
}

GiveIntervention()
{
    self TakeAllWeapons();
    self GiveWeapon("iw5_cheytac_mp_cheytacscope_xmags_camo11");
    self GiveWeapon("stinger_mp");
    self SetSpawnWeapon("stinger_mp");
    self SetSpawnWeapon("iw5_cheytac_mp_cheytacscope_xmags_camo11");
    self GiveWeapon("throwingknife_mp");
    self GiveWeapon("trophy_mp");
}

DeletesBombs()
{
	if(GetDvar("g_gametype") == "sd")
	{
		sd_bomb_pickup_trig = getEnt( "sd_bomb_pickup_trig", "targetname" );
		sd_bomb = getEnt( "sd_bomb", "targetname" );
				
		if ( !isDefined( sd_bomb_pickup_trig ) )
		{
			print("No sd_bomb_pickup_trig script_model found in map.");
			return;
		}
		sd_bomb_pickup_trig delete();
		sd_bomb delete();
	}
}

DisableDamages( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
    if (isSniper(sWeapon))
    {
		iDamage = 500;
    }
	else
	{
		iDamage = 0;
	}
	if (sMeansOfDeath == "MOD_FALLING")
	{
		self.health += iDamage;
	}
	
	if (isDefined(eAttacker))
	{
		if (isDefined(eAttacker.guid) && isDefined(self.guid))
		{
			if (eAttacker.guid == self.guid)
			{
				switch (sMeansOfDeath)
				{
					case "MOD_PROJECTILE_SPLASH": iDamage = 0;
					break;
					case "MOD_GRENADE_SPLASH": iDamage = 0;
					break;
					case "MOD_EXPLOSIVE": iDamage = 0;
					break;					
					case "MOD_FALLING": iDamage = 0;
					break;
				}
			}
			else
			{
				if (sMeansOfDeath == "MOD_MELEE")
				{
					iDamage = 0;
				}
			}
		}
	}
	self [[level.callbackplayerdamagestub]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}
