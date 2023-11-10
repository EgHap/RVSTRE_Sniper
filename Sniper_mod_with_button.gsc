#include maps\mp\gametypes\_hud_util;
//#include common_scripts\utility;

Init()
{
    setDvar("sv_enableDoubleTaps", 1);

    SetDvar("g_TeamName_Axis", "^1Others");
    SetDvar("g_TeamName_Allies", "^5RVSTRE");

    SetDvar("g_TeamIcon_Allies", "iw5_cardicon_nuke");
    SetDvar("g_TeamIcon_Axis", "iw5_cardicon_smiley");

    level.switch_button = "+actionslot 5";
    level.switch_camo_button = "+actionslot 6";

    level.weaponList = [];

    level.weaponList[0] = ["iw5_msr_mp_msrscope_xmags_", "iw5_cheytac_mp_cheytacscope_xmags_", "iw5_l96a1_mp_l96a1scope_xmags_"];
    level.weaponList[1] = ["camo01", "camo02", "camo03", "camo04", "camo05", "camo06", "camo07", "camo08", "camo09", "camo10", "camo11"];
	
		
	level.callbackplayerdamagestub = level.callbackplayerdamage;
    level.callbackplayerdamage = ::DisableDamages;	

	level thread OnPlayerConnect();
	AntiPlant();
}

OnPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread OnPlayerSpawned();
		player thread killstreakPlayer();
		player.pers["currentWeaponIndex"] = 1;
		player.pers["currentCamoIndex"] = 11;
	}
}

OnPlayerSpawned()
{
    self endon("disconnect");

    for (;;)
    {
		self waittill("changed_kit");
	
		if (self.pers["currentWeaponIndex"] >= level.weaponList[0].size)
        {
            self.pers["currentWeaponIndex"] = 0;
        }
		if (self.pers["currentCamoIndex"] >= level.weaponList[1].size)
        {
            self.pers["currentCamoIndex"] = 0;
        }
        sniperWeapon = level.weaponList[0][self.pers["currentWeaponIndex"]];
        camo = level.weaponList[1][self.pers["currentCamoIndex"]];
        self.pers["weapon"] = sniperWeapon;
        self.pers["camo"] = camo;  
		
		self thread DisplayHud();
		self thread TakeSniperClass(sniperWeapon + camo);
		self thread AntiDS();
		self thread AntiHardscope();
		self thread OnSwitchButtonPressed(level.switch_button);
		self thread OnSwitchCamoButtonPressed(level.switch_camo_button);
    }
}


killstreakPlayer()
{
	self endon ("disconnect");
	level endon("game_ended");
	self.hudkillstreak = createFontString ("Objective", 1);
	self.hudkillstreak setPoint ("CENTER", "TOP", "CENTER", 10);
	self.hudkillstreak.label = &"^6KILLSTREAK: ^5";
	
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
    self.someText setPoint("TOPRIGHT", "TOPRIGHT");
    self.someText setText("^6Press ^5[{" + level.switch_button + "}] ^6to switch sniper\n^6Press ^5[{" + level.switch_camo_button + "}] ^6to switch camo");
}

OnSwitchButtonPressed(button)
{
    self endon("disconnect");
    level endon("game_ended");

    self notifyOnPlayerCommand("switch_button", button);
    while (1)
    {
        self waittill("switch_button");
        self.pers["currentWeaponIndex"]++;
        if (self.pers["currentWeaponIndex"] >= level.weaponList[0].size)
        {
            self.pers["currentWeaponIndex"] = 0;
        }
		if (self.pers["currentCamoIndex"] >= level.weaponList[1].size)
        {
            self.pers["currentCamoIndex"] = 0;
        }
        sniperWeapon = level.weaponList[0][self.pers["currentWeaponIndex"]];
        camo = level.weaponList[1][self.pers["currentCamoIndex"]];
        TakeSniperClass(sniperWeapon + camo);
        self.pers["weapon"] = sniperWeapon;
        self.pers["camo"] = camo;
    }
}
OnSwitchCamoButtonPressed(button)
{
    self endon("disconnect");
    level endon("game_ended");

    self notifyOnPlayerCommand("switch_camo_button", button);

    while (1)
    {
        self waittill("switch_camo_button");
		
        self.pers["currentCamoIndex"]++;
        if (self.pers["currentCamoIndex"] >= level.weaponList[1].size)
        {
            self.pers["currentCamoIndex"] = 0;
        }

        sniperWeapon = level.weaponList[0][self.pers["currentWeaponIndex"]];
        camo = level.weaponList[1][self.pers["currentCamoIndex"]];

        TakeSniperClass(sniperWeapon + camo);
        self.pers["weapon"] = sniperWeapon;
        self.pers["camo"] = camo;
    }
}

TakeSniperClass(sniper)
{

    self TakeAllWeapons();
    self GiveWeapon(sniper);
    self GiveWeapon("stinger_mp");
    self SetSpawnWeapon("stinger_mp");
    self SetSpawnWeapon(sniper);
    self GiveWeapon("throwingknife_mp");
    self GiveWeapon("trophy_mp");

    self.pers["current_weapon"] = sniper;
}


DisableDamages( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
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
				}
			}
			else
			{
				if(isSniper(sWeapon))
				{
					iDamage = 999;
				}
				if (sMeansOfDeath == "MOD_MELEE")
				{
					iDamage = 0;
				}				
				if (sMeansOfDeath == "MOD_FALLING")
				{
					iDamage = 0;
				}				
			}
		}
	}
		
	self [[level.callbackplayerdamagestub]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

AntiHardscope()
{
    self endon("disconnect");	
    adscycle = 0;
	for(;;)
    {
		
		if(self PlayerAds() >= 1 && isSniper(self GetCurrentWeapon()))
		{
			adscycle++;
		}
		else
		{
			adscycle = 0;
		}
		
		if(adscycle >= 12)
		{
			adscycle = 0;
			self AllowAds(false);
			self StunPlayer(true);
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


isSniper(weapon)
{
	if(self.pers["current_weapon"] == weapon)
	{ return true; }
	return false;
}

AntiDS()
{
    self endon("disconnect");

    for(;;)
    {
        if (self GetStance() == "prone")
        {
            self IPrintLnBold("^1DropShoting is not allowed");
            self SetStance("stand");
        }

        wait 0.05;
    }
}

AntiPlant()
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
		if ( !isDefined( sd_bomb ) )
		{
			print("No sd_bomb script_model found in map.");
			return;
		}
		sd_bomb_pickup_trig delete();
		sd_bomb delete();
	}
}
