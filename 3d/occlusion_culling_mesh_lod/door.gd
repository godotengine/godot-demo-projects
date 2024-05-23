extends Node3D

var open := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_doors"):
		if open:
			# Close the door.
			# The occluder will be re-enabled when the animation ends
			# using `_on_animation_player_animation_finished()`.
			$AnimationPlayer.play_backwards("open")
			open = false
		else:
			# Open the door.
			$AnimationPlayer.play("open")
			open = true
			# Disable the occluder as soon as the door starts opening.
			# The occluder is not part of the pivot to prevent it from having its
			# position changed every frame, which causes the occlusion culling BVH
			# to be rebuilt each frame. This causes a CPU performance penalty.
			$OccluderInstance3D.visible = false


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if not open:
		# Re-enable the occluder when the door is done closing.
		# To prevent overocclusion, the door must be fully closed before the occluder can be re-enabled.
		$OccluderInstance3D.visible = true
