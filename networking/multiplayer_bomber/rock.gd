extends KinematicBody2D

# Sent to everyone else
puppet func do_explosion():
	get_node("anim").play("explode")

# Received by owner of the rock
master func exploded(by_who):
	rpc("do_explosion") # Re-sent to puppet rocks
	get_node("../../score").rpc("increase_score", by_who)
	do_explosion()
