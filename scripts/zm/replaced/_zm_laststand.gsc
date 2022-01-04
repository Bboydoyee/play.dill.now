#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;

revive_do_revive( playerbeingrevived, revivergun )
{
	revivetime = 3;
	if ( self hasperk( "specialty_quickrevive" ) )
	{
		revivetime /= 2;
	}
	if ( self maps/mp/zombies/_zm_pers_upgrades_functions::pers_revive_active() )
	{
		revivetime *= 0.5;
	}
	timer = 0;
	revived = 0;
	playerbeingrevived.revivetrigger.beingrevived = 1;
	playerbeingrevived.revive_hud settext( &"ZOMBIE_PLAYER_IS_REVIVING_YOU", self );
	playerbeingrevived maps/mp/zombies/_zm_laststand::revive_hud_show_n_fade( 3 );
	playerbeingrevived.revivetrigger sethintstring( "" );
	if ( isplayer( playerbeingrevived ) )
	{
		playerbeingrevived startrevive( self );
	}
	if ( !isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar = self createprimaryprogressbar();
        self.reviveprogressbar.bar.color = (0.5, 0.5, 1);
	}
	if ( !isDefined( self.revivetexthud ) )
	{
		self.revivetexthud = newclienthudelem( self );
	}
	self thread maps/mp/zombies/_zm_laststand::laststand_clean_up_on_disconnect( playerbeingrevived, revivergun );
	if ( !isDefined( self.is_reviving_any ) )
	{
		self.is_reviving_any = 0;
	}
	self.is_reviving_any++;
	self thread maps/mp/zombies/_zm_laststand::laststand_clean_up_reviving_any( playerbeingrevived );
	self.reviveprogressbar updatebar( 0.01, 1 / revivetime );
	self.revivetexthud.alignx = "center";
	self.revivetexthud.aligny = "middle";
	self.revivetexthud.horzalign = "center";
	self.revivetexthud.vertalign = "bottom";
	self.revivetexthud.y = -113;
	if ( self issplitscreen() )
	{
		self.revivetexthud.y = -347;
	}
	self.revivetexthud.foreground = 1;
	self.revivetexthud.font = "default";
	self.revivetexthud.fontscale = 1.8;
	self.revivetexthud.alpha = 1;
	self.revivetexthud.color = ( 1, 1, 1 );
	self.revivetexthud.hidewheninmenu = 1;
	if ( self maps/mp/zombies/_zm_pers_upgrades_functions::pers_revive_active() )
	{
		self.revivetexthud.color = ( 0.5, 0.5, 1 );
	}
	self.revivetexthud settext( &"ZOMBIE_REVIVING" );
	self thread maps/mp/zombies/_zm_laststand::check_for_failed_revive( playerbeingrevived );
	while ( self maps/mp/zombies/_zm_laststand::is_reviving( playerbeingrevived ) )
	{
		wait 0.05;
		timer += 0.05;
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			break;
		}
		else if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
		{
			break;
		}
		if ( timer >= revivetime )
		{
			revived = 1;
			break;
		}
	}
	if ( isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar destroyelem();
	}
	if ( isDefined( self.revivetexthud ) )
	{
		self.revivetexthud destroy();
	}
	if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
	{
	}
	else if ( !revived )
	{
		if ( isplayer( playerbeingrevived ) )
		{
			playerbeingrevived stoprevive( self );
		}
	}
	playerbeingrevived.revivetrigger sethintstring( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
	playerbeingrevived.revivetrigger.beingrevived = 0;
	self notify( "do_revive_ended_normally" );
	self.is_reviving_any--;

	if ( !revived )
	{
		playerbeingrevived thread maps/mp/zombies/_zm_laststand::checkforbleedout( self );
	}
	return revived;
}