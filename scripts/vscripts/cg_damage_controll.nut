//****************************************************************************************
//																						//
//									cg_damage_controll.nut								//
//																						//
//****************************************************************************************







// When to allow damage
// ----------------------------------------------------------------------------------------------------------------------------

function AllowTakeDamage(damageTable){
	local damageType = damageTable["DamageType"]
	local attacker = damageTable["Attacker"]
	local victim = damageTable["Victim"]
	local damageDone = damageTable["DamageDone"]
	
	return true
}
