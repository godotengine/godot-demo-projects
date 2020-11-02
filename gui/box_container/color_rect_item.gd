extends ColorRect
# The ColorRect code, it's only purpose is to send a signal
# Telling the scene root node,
# 'Hey!, The user click me, Here is my 4 digit node number'



var is_mouse_inside_rect = false

onready var root = get_tree().get_root()
onready var scene_root = root.get_child(root.get_child_count() - 1)


func _ready():
	get_child(0).hide()  # Hiding the OutLine ColorRect

func _input(event):
	if not event is InputEventMouseMotion:
		if event.is_action_pressed("ui_select") and is_mouse_inside_rect:
			scene_root.emit_signal("color_rect_notified", self)


# SIGNALS
func _on_ColorRect_mouse_entered():
	is_mouse_inside_rect = true

func _on_ColorRect_mouse_exited():
	is_mouse_inside_rect = false
