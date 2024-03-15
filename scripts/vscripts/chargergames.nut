
/*
	Charger Games Mutation by ReneTM
*/

getroottable()["TRACE_MASK_ALL"] <- -1
getroottable()["TRACE_MASK_SHOT"] <- 1174421507
getroottable()["TRACE_MASK_VISION"] <- 33579073
getroottable()["TRACE_MASK_NPC_SOLID"] <- 33701899
getroottable()["TRACE_MASK_PLAYER_SOLID"] <- 33636363
getroottable()["TRACE_MASK_VISIBLE_AND_NPCS"] <- 33579137

IncludeScript("cg_utils")
IncludeScript("cg_events")
IncludeScript("cg_lines")
IncludeScript("cg_path_data")
IncludeScript("cg_goal_shines")
IncludeScript("cg_damage_controll")
IncludeScript("cg_director")
IncludeScript("cg_hud_controller")

::g_mapname <- Director.GetMapName()

::servercommand <- SpawnEntityFromTable("point_servercommand", { targetname = "servercommander" })




function Think(){
	ConvarListener()
	ValidatePlayerInitialSurvivorData()
	PlayerFunctions()
}

// Precache Particle
// ----------------------------------------------------------------------------------------------------------------------------

trailTable <-
{
	classname = "info_particle_system"
	targetname = UniqueString("trail_")
	effect_name = "fire_jet_01"
	start_active = 1
	render_in_front = 0
	angles = "0 0 0"
}

PrecacheEntityFromTable(trailTable)




// Makes sure that theres an existing trail particle created and parented to the player
// ----------------------------------------------------------------------------------------------------------------------------

::validateChargerTrail <- function(player){
	local scope = GetValidatedScriptScope(player)
	if(!("particle" in scope)){
		local particle = SpawnEntityFromTable("info_particle_system", trailTable)
		scope["particle"] <- particle
		// Parenting
		particle.SetOrigin(player.GetOrigin())
		
		DoEntFire("!self", "SetParent", "!activator", 0.00, player, particle)
	}
}




// Start Particle
// ----------------------------------------------------------------------------------------------------------------------------

::enableChargerTrail <- function(player){
	local scope = GetValidatedScriptScope(player)
	local particle = scope["particle"]
	DoEntFire("!self", "start", "", 0.00, particle, particle)
}




// Stop Particle
// ----------------------------------------------------------------------------------------------------------------------------

::disableChargerTrail <- function(player){
	local scope = GetValidatedScriptScope(player)
	local particle = scope["particle"]
	DoEntFire("!self", "stop", "", 0.00, particle, particle)
}




// Makes sure that theres an existing script scope of the entity and returns it
// ----------------------------------------------------------------------------------------------------------------------------

::GetValidatedScriptScope <- function(ent){
	ent.ValidateScriptScope()
	return ent.GetScriptScope()
}




// Convars
// ----------------------------------------------------------------------------------------------------------------------------

::convarList <- {
	z_charge_interval = 2
	z_charge_duration = 999
	sb_all_bot_game = 1
	z_max_stagger_duration = 1
	
	// Votes
	sv_vote_creation_timer = 8
	sv_vote_plr_map_limit = 128
	// Misc
	z_spawn_flow_limit = 99999
	director_afk_timeout = 99999
	mp_allowspectators = 0
	// Disable Placeholder bots
	director_transition_timeout = 1
	director_no_death_check = 0
}

function ConvarListener(){
	foreach(key, val in convarList){
		if(Convars.GetFloat(key) != val.tofloat()){
			Convars.SetValue(key, val)
		}
	}
}





// ----------------------------------------------------------------------------------------------------------------------------

::TurnPlayerIntoCharger <- function(player){
	
	local invTable = {}
	GetInvTable(player, invTable)

	foreach(slot, weapon in invTable){
		weapon.Kill()
	}

	if("slot0" in invTable){
		player.DropItem(invTable.slot0.GetClassname());
	}

	NetProps.SetPropInt(player, "m_iTeamNum", 3)
	NetProps.SetPropInt(player, "m_zombieClass", 6)
	NetProps.SetPropInt(player, "m_iMaxHealth", 600)
	player.SetHealth(600);
	player.SetModel("models/infected/charger.mdl")
	player.GiveItem("weapon_charger_claw")
	local ability_charger = SpawnEntityFromTable("ability_charge", { targetname = UniqueString("newCharge") })
	NetProps.SetPropEntity(ability_charger, "m_owner", player)
	NetProps.SetPropEntity(player, "m_customAbility", ability_charger)
}




::TurnChargerIntoSurvivor <- function(player){
	
	local ability = null
	
	if(ability = NetProps.GetPropEntity(player, "m_customAbility")){
		NetProps.SetPropEntity(ability, "m_owner", null)
		ability.Kill()
	}

	local invTable = {}
	GetInvTable(player, invTable)

	if("slot0" in invTable){
		player.DropItem(invTable.slot0.GetClassname())
	}
	EntFire("worldspawn", "RunScriptCode", "GiveWeaponsNextTick(" + player.GetPlayerUserId()+ ")", 0.03)

	
	NetProps.SetPropInt(player, "m_iTeamNum", 2)
	NetProps.SetPropInt(player, "m_zombieClass", 9)
	NetProps.SetPropInt(player, "m_iMaxHealth", 100)
	player.SetHealth(100);

	local scope = GetValidatedScriptScope(player)
	player.SetModel(scope["init_w_model"])
	NetProps.SetPropInt(player,"m_Gender", scope["init_gender"])
}




// Iterates over all survivors and will give them a pistol to avoid t-posing
// ----------------------------------------------------------------------------------------------------------------------------

::GiveWeaponsNextTick <- function(id){
	local player = GetPlayerFromUserID(id)
	if(player){
		player.GiveItem("weapon_pistol_magnum")
		player.GiveItem("weapon_shotgun_chrome")
	}
}




// Time to think with these nuts ;D
// ----------------------------------------------------------------------------------------------------------------------------

createThinkTimer();










