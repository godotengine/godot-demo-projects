extends KinematicBody2D

# Sent to everyone else
puppet func do_explosion():
	$"AnimationPlayer".play("explode")


# Received by owner of the rock
master func exploded(by_who):
	rpc("do_explosion") # Re-sent to puppet rocks
	$"../../Score".rpc("increase_score", by_who)
	do_explosion()
