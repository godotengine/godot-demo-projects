extends CharacterBody2D

@rpc("call_local")
func exploded(by_who):
	$"../../Score".increase_score(by_who)
	$"AnimationPlayer".play("explode")
