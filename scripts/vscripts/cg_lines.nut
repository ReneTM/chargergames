/*
	Creates and saves a laser path
*/

PrecacheSound("player/laser_on.wav");

::lasers <- []


::createLaser <- function(pos){
	if(pos == null){
		pos = Entities.FindByClassname(null, "player").GetOrigin()
	}
	
	local position = pos
	

	local target = "";
	if(lasers.len() > 0){
		target = lasers.top().GetName();
	}
	
	local spawntable =
	{
		targetname = UniqueString("laser_")
		damage = 0
		dissolvetype = ""
		framestart = 0
		NoiseAmplitude = 0
		renderamt = 100
		rendercolor = "255 0 0"
		width = 2
		renderfx = 0
		TextureScroll = 35
		spawnflags = 1
		texture = "sprites/laserbeam.spr"
		LaserTarget = target
		origin = position + Vector(0,0,16)
	}
	lasers.append(SpawnEntityFromTable("env_laser", spawntable))
}

::createJumper <- function(pos){
	if(pos == null){
		pos = Entities.FindByClassname(null, "player").GetOrigin()
	}
	local position = pos

	local triggerMin = Vector(-32,-32,-64)
	local triggerMax = Vector(32,32,64)
	local zOffset = triggerMax.z

	local triggerName = UniqueString("CG_TRIGGER_")
	//
	local triggerTable =
	{
		targetname    = triggerName
		StartDisabled = 0
		spawnflags    = 1
		allowincap    = 1
		entireteam    = 0
		filtername    = "RD_FILTER_INFECTED"
		origin        = pos + Vector(0,0,zOffset/2)
	}

	local trigger = SpawnEntityFromTable( "trigger_multiple", triggerTable)

	setTriggerSize(trigger,triggerMin,triggerMax)
	NetProps.SetPropInt(trigger, "m_Collision.m_nSolidType", 2)

	EntFire( triggerName, "AddOutput",  "OnStartTouch worldspawn:RunScriptCode:UserJumper(activator):0:-1")
	DebugDrawBox( triggerTable.origin, triggerMin, triggerMax, 255, 255, 255, 0, 9999)
	
	//spawnArrow({origin = pos + Vector(0,0,64), angles = "-90 0 0"})
	
}

::UserJumper <- function(player){
	local currentVel = player.GetVelocity()
	currentVel.z = 512
	player.SetVelocity(currentVel)
	EmitAmbientSoundOn("player/laser_on.wav", 1, 100, 180, player)
}


::savePathAsFile <- function(){
	local str = "";
	foreach(ent in lasers){
		local orig = ent.GetOrigin()
		str += ( "Vector(" + orig.x + "," + orig.y + "," + orig.z + ")" + "\n")
	}
	local mapname = Director.GetMapName();
	StringToFile("chargergames/" + mapname + ".txt", str);
}