extends StaticBody2D

signal raycast_hit

func _ready():
	connect("raycast_hit", self, "on_raycast_hit") # Will call on_raycast_hit() when raycast_hit signal is received

func on_raycast_hit():
	# NOTE: This is called on each frame the raycast hits this node
	#		Try uncommenting the following lines to prevent this
	#if get_node("AnimationPlayer").get_current_animation() != "bump" \
	#or !get_node("AnimationPlayer").is_playing():
		get_node("AnimationPlayer").play("bump")