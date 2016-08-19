
extends KinematicBody2D

#sent to everyone else
slave func do_explosion():
	get_node("anim").play("explode")

#received by owner of the rock
master func exploded(by_who):
	rpc("do_explosion") #re-sent to slave rocks
	get_node("../../score").rpc("increase_score",by_who)
	do_explosion()
	
	