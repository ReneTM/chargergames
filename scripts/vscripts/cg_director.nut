//****************************************************************************************
//																						//
//										cg_director.nut									//
//																						//
//****************************************************************************************




MutationOptions <-
{
	// General
	cm_NoSurvivorBots = 1

	ProhibitBosses = true
	
	// Special Infected
	MaxSpecials = 6

	function AllowWeaponSpawn(classname){
		return false
	}
	
	// Avoid fallen survivors carrying items
	function AllowFallenSurvivorItem(item){
		return false
	}
	
	// Get default items for survivors
	DefaultItems =
	[
		"weapon_pistol_magnum"
	]

	function GetDefaultItem( idx ){
		if ( idx < DefaultItems.len() ){
			return DefaultItems[idx]
		}
		return 0
	}
}
