//****************************************************************************************
//																						//
//									rd_hud_controller.nut								//
//																						//
//****************************************************************************************



// Returns array of all survivors (bots excluded)
// ----------------------------------------------------------------------------------------------------------------------------

::GetHumanPlayers <- function(){
	local ent = null
	while (ent = Entities.FindByClassname(ent, "player")){
		if (!IsPlayerABot(ent)){
			yield ent
		}
	}
}


// Iteration over all human player and pass them to different methods
// ----------------------------------------------------------------------------------------------------------------------------

function PlayerFunctions(){
	foreach(ent in GetHumanPlayers()){
		if(ent.IsValid()){
			PlayerTimer(ent)
		}
	}
}


::SetPlayerTimeActive <- function(ent, val){
	if(val){
		PlayerTimeData[ent].startTime = Time()
		PlayerTimeData[ent].timerActive = true;
		PlayerTimeData[ent].finished = false
	}else{
		PlayerTimeData[ent].endTime = Time()
		PlayerTimeData[ent].timerActive = false;
		PlayerTimeData[ent].finished = true
	}
}

// This will track timings of the survivor
// ----------------------------------------------------------------------------------------------------------------------------

::PlayerTimeData <- {}

function PlayerTimer(ent){

	if(!(ent in PlayerTimeData)){
		PlayerTimeData[ent] <- { timerActive = false, finished = false, startTime = Time(), endTime = Time() }
	}
}


// Flag and position tables
// ----------------------------------------------------------------------------------------------------------------------------

::HUDFlags <- {
	PRESTR = 1
	POSTSTR = 2
	BEEP = 4
	BLINK = 8
	AS_TIME = 16
	COUNTDOWN_WARN = 32
	NOBG = 64
	ALLOWNEGTIMER = 128
	ALIGN_LEFT = 256
	ALIGN_CENTER = 512
	ALIGN_RIGHT = 768
	TEAM_SURVIVORS = 1024
	TEAM_INFECTED = 2048
	TEAM_MASK = 3072
	NOTVISIBLE = 16384
}

::HUDPositions <- {
	LEFT_TOP = 0
	LEFT_BOT = 1
	MID_TOP = 2
	MID_BOT = 3
	RIGHT_TOP = 4
	RIGHT_BOT = 5
	TICKER = 6
	FAR_LEFT = 7
	FAR_RIGHT = 8
	MID_BOX = 9
	SCORE_TITLE = 10
	SCORE_1 = 11
	SCORE_2 = 12
	SCORE_3 = 13
	SCORE_4 = 14
}




// Main hud definition
// ----------------------------------------------------------------------------------------------------------------------------

RD_HUD <-
{
	Fields = 
	{
		timer = { slot = HUDPositions.MID_BOX, flags = HUDFlags.ALIGN_CENTER | HUDFlags.NOBG, name = "timer", datafunc = @()GetPlayerTimes() }
	}
}




// Returns one string for all survivors
// ----------------------------------------------------------------------------------------------------------------------------

::GetPlayerTimes <- function(){
	local str = ""
	
	foreach(ent in GetHumanPlayers()){
		str += (ent.GetPlayerName() + ": ")
		if(ent in PlayerTimeData){
			if(!ent.IsDead() && !ent.IsDying()){
				if(PlayerTimeData[ent].finished){
					str += "Finished(" + g_MapScript.TimeToDisplayString(PlayerTimeData[ent].endTime - PlayerTimeData[ent].startTime) + ")"
				}else{

					if(!PlayerTimeData[ent].timerActive){
						str += "0:00"
					}else{
						str += g_MapScript.TimeToDisplayString( Time() - PlayerTimeData[ent].startTime )
					}
				}
			}else{
				str += "(Dead)"
			}
		}
		str += "  "
	}
	return str
}




// Enable / disable the hud
// ----------------------------------------------------------------------------------------------------------------------------

function EnableTimerHud(){
	RD_HUD.Fields.timer.flags <- RD_HUD.Fields.timer.flags & ~HUDFlags.NOTVISIBLE
	HUDPlace(HUDPositions.MID_BOX, 0.0, 0.0, 1.0, 0.05)
}




function EnableTickerHud(){
	Ticker_AddToHud(RD_HUD, "!info in chat to print mutation details to your console", true)
	HUDPlace(HUDPositions.TICKER, 0.0, 0.0, 0.99, 0.25)
	Ticker_SetTimeout(16)
	Ticker_SetBlinkTime(16)
	RD_HUD.Fields.ticker.flags <- HUDFlags.ALIGN_CENTER | HUDFlags.NOBG | HUDFlags.BLINK
}




function DisableTimerHud(){
	RD_HUD.Fields.timer.flags <- RD_HUD.Fields.timer.flags | HUDFlags.NOTVISIBLE
}




// Checks if the timer hud is currently visible
// ----------------------------------------------------------------------------------------------------------------------------

function IsTimerHudActive(){
	return !(RD_HUD.Fields.timer.flags & HUDFlags.NOTVISIBLE)
}


EnableTimerHud()

EnableTickerHud()

HUDSetLayout(RD_HUD)




