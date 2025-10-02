extends CharacterBody2D

@rpc("call_local")
func exploded(by_who: int) -> void:
	$"../../Score".increase_score(by_who)
	$"AnimationPlayer".play("explode")
