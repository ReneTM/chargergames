// Events
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_charger_charge_start(param){
	local player = GetPlayerFromUserID(param["userid"])
	NetProps.SetPropInt(player,"m_fFlags", NetProps.GetPropInt(player, "m_fFlags") &~ 32)		// Unlock player's view while charging
	validateChargerTrail(player)
	enableChargerTrail(player)
}




function OnGameEvent_charger_charge_end(param){
	local player = GetPlayerFromUserID(param["userid"])
	disableChargerTrail(player)
}

function OnGameEvent_round_end(param){
	switch(param.message){
		case "#L4D_Scenario_Restart" : MoveEverybodyToSurvivor(); break
		case "#L4D_Scenario_Survivors_Dead" : MoveEverybodyToSurvivor(); break
	}
}

function MoveEverybodyToSurvivor(){
	local ent = null
	while(ent = Entities.FindByClassname(ent, "player")){
		if(!IsPlayerABot(ent)){
			NetProps.SetPropInt(ent, "m_iTeamNum", 2)
		}
	}
}



/*
function OnGameEvent_charger_impact(param){
	local player = GetPlayerFromUserID(param["userid"])
	// Having one carry victim and hitting another surv	
}
*/


function OnGameEvent_player_first_spawn(params){
	if(params["isbot"] == 0){
		local player = GetPlayerFromUserID(params.userid)
		
	}
}

function OnGameplayStart(){
	
	local ent = null
	while(ent = Entities.FindByClassname(ent, "prop_door_rotating")){
		ent.Kill();
	}

	// Laser routes
	if(g_mapname in pathData){
	foreach(pos in pathData[g_mapname]){
		createLaser(pos)
	}
	
	// Start and End triggers + lights
	create_trigger(pathData[g_mapname][0], "start")
	create_trigger(pathData[g_mapname].top(), "end")

	createBubbleShine(pathData[g_mapname][0])
	createBubbleShine(pathData[g_mapname].top())
	}

	// Jumper and decals
	if(g_mapname in jumperData){
		foreach(pos in jumperData[g_mapname]){
			createJumper(pos)
			applyDecalAt(pos, "decals/slime")
		}
	}
}



__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)