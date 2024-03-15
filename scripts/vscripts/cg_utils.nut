// Creates the think timer which calls "Think()" every tick
// ----------------------------------------------------------------------------------------------------------------------------

function createThinkTimer(){
	local timer = null
	while (timer = Entities.FindByName(null, "thinkTimer")){
		timer.Kill()
	}
	timer = SpawnEntityFromTable("logic_timer", { targetname = "thinkTimer", RefireTime = 0.0 })
	timer.ValidateScriptScope()
	timer.GetScriptScope()["scope"] <-  this

	timer.GetScriptScope()["func"] <-  function(){
		scope.Think()
	}
	timer.ConnectOutput("OnTimer", "func")
	EntFire("!self", "Enable", null, 0, timer)
}




// Sets the trigger size
// ----------------------------------------------------------------------------------------------------------------------------

::setTriggerSize <- function(trigger, vectorMins, vectorMaxs){
	if(trigger.IsValid()){
		if(typeof(vectorMins) == "Vector"){
			if(typeof(vectorMaxs) == "Vector"){
				NetProps.SetPropVector(trigger, "m_Collision.m_vecMins", vectorMins)
				NetProps.SetPropVector(trigger, "m_Collision.m_vecMaxs", vectorMaxs)
			}else{
				error("setTriggerSize error: vectorMaxs ment to be datatype vector")
			}
		}else{
			error("setTriggerSize error: vectorMins ment to be datatype vector")
		}
	}
}




// Creates a start or finish trigger
// ----------------------------------------------------------------------------------------------------------------------------

SpawnEntityFromTable("filter_activator_team", { targetname = "RD_FILTER_INFECTED", origin = Vector(0,0,0), Negated = 0, filterteam = 3 } )
SpawnEntityFromTable("filter_activator_team", { targetname = "RD_FILTER_SURVIVOR", origin = Vector(0,0,0), Negated = 0, filterteam = 2 } )

::create_trigger <- function(pos,version){
	
	local outputstr = version == "start" ? "OnStartTouch worldspawn:RunScriptCode:PlayerBeganRun(activator):0:-1" : "OnStartTouch worldspawn:RunScriptCode:PlayerFinishedMap(activator):0:-1"
	
	local filter = version == "start" ? "RD_FILTER_SURVIVOR" : "RD_FILTER_INFECTED"
	
	local triggerMin = Vector(-32,-32,-64)
	local triggerMax = Vector(32,32,64)
	local zOffset = triggerMax.z

	local triggerName = UniqueString("CG_TRIGGER_")

	local triggerTable =
	{
		targetname    = triggerName
		StartDisabled = 0
		spawnflags    = 1
		allowincap    = 1
		entireteam    = 0
		filtername    = filter
		origin        = pos + Vector(0,0,zOffset / 2)
	}

	local trigger = SpawnEntityFromTable( "trigger_multiple", triggerTable)

	setTriggerSize(trigger,triggerMin,triggerMax)
	NetProps.SetPropInt(trigger, "m_Collision.m_nSolidType", 2)

	EntFire( triggerName, "AddOutput",  outputstr)
	DebugDrawBox( triggerTable.origin, triggerMin, triggerMax, 255, 255, 255, 0, 16)
}




::PlayerFinishedMap <- function(player){
	local scope = GetValidatedScriptScope(player)

	

	disableChargerTrail(player)

	if(AllPlayersPlayed()){
		
		EndMap()
		
		if(IsMissionFinalMap()){
			EndGame()
		}
	}
	TurnChargerIntoSurvivor(player)
	SetPlayerTimeActive(player, false);
}

::PlayerBeganRun <- function(player){
	local scope = GetValidatedScriptScope(player)
	SetPlayerTimeActive(player, true);
	TurnPlayerIntoCharger(player)
}

::CloseAllSaferoomDoors<-function(){
	local door = null;
	while(door = Entities.FindByClassname(door, "prop_door_rotating_checkpoint")){
		DoEntFire("!self", "close", "", 0.00, door, door)
	}
}

::EndMap <- function(){
	//EntFire("worldspawn", "RunScriptCode", "Director.WarpAllSurvivorsToCheckpoint()", 0.5)	
}




::EndGame <- function(){
	local outro = null
	if(outro = Entities.FindByClassname(null, "env_outtro_stats")){
		DoEntFire("!self", "rollstatscrawl", "", 3.00, outro, outro)
	}
}




function IsCharging(ent){
	return NetProps.GetPropInt(ent, "m_isCharging")
}

function SetIsCharging(ent, val){
	NetProps.SetPropInt(ent, "m_isCharging", val)
}

function HasBeenUsed(ent){
	return NetProps.GetPropInt(ent, "m_hasBeenUsed")
}

function SetHasBeenUsed(ent, val){
	NetProps.SetPropInt(ent, "m_hasBeenUsed", val)
}






::AllPlayersPlayed <- function(){
	local player = null
	while(player = Entities.FindByClassname(player, "player")){
		if(!IsPlayerABot(player)){
			local scope = GetValidatedScriptScope(player)
			if(!("topTime" in scope)){
				return false
			}
		}
	}
	return true
}

::ResetCharger <- function(){
	
local player = Entities.FindByClassname(null,"player")	

local ability = NetProps.GetPropEntity(player, "ability_charge")

NetProps.SetPropInt(player,"m_isCharging",0)
NetProps.SetPropInt(player,"m_MoveType",2)
NetProps.SetPropFloat(ability,"m_chargeStartTime",Time() - 30.000)
NetProps.SetPropFloat(ability,"m_nextActivationTimer.m_timestamp",Time() - 30.000)
NetProps.SetPropFloat(ability,"m_nextActivationTimer.m_duration",Time() - 30.000)

NetProps.SetPropFloat(ability,"m_activationSupressedTimer.m_timestamp",Time() - 30.000)
NetProps.SetPropFloat(ability,"m_activationSupressedTimer.m_duration",Time() - 30.000)
NetProps.SetPropInt(ability,"m_isCharging",0)
}




// Applies a decal with texture X on position Y
// ----------------------------------------------------------------------------------------------------------------------------

::applyDecalAt <- function (pos, tex){
	local decal = SpawnEntityFromTable( "infodecal", { targetname = "rd_decal", texture = tex, LowPriority = 0, origin = pos } )
	DoEntFire( "!self", "Activate", "", 0.0, decal, decal )
}


::GetTracedPosition<-function(paramPos, dir){
	
	local offset;
	
	switch(dir){
		case "up" 		:	offset = Vector(0.0,0.0,64.0); break;
		case "down"		:	offset = Vector(0,0,0.0,-64.0); break;
	}

	local traceTable = { start = paramPos, end = (paramPos + offset), mask = TRACE_MASK_PLAYER_SOLID }
	
	local newOriginFound = false
	local newOrig = null
	if(TraceLine(traceTable)){
		if(traceTable.hit){
			if("pos" in traceTable){
				newOriginFound = true
				newOrig = traceTable.pos
			}
		}
	}

	

	local ret = (newOriginFound ? newOrig : paramPos )
	
	ClientPrint(null, 5, "Newfound: " + newOriginFound + "  Old: " +  paramPos + "   New: " + newOrig + " Ret:" + ret)

	return ret
}


function ValidatePlayerInitialSurvivorData(){
	local player = null
	while(player = Entities.FindByClassname(player, "player")){
		if(player.IsSurvivor() && !player.IsDead() && !player.IsDying()){
			player.ValidateScriptScope()
			local scope = player.GetScriptScope()
			if(!("validated" in scope)){
				scope["init_w_model"] <- player.GetModelName()
				scope["init_gender"] <- NetProps.GetPropInt(player, "m_Gender")
				scope["validated"] <- true
			}
		}
	}
}
