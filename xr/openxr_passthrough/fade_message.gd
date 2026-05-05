@tool
class_name FadeMessage3D
extends Node3D

## Text to show, after assigning text it will disappear after a time.
@export var text : String = "":
	set(value):
		# Note, even if we don't change the value, we re-initiate our fade
		text = value
		if is_inside_tree():
			_update_text()

## Text color.
@export var text_color : Color = Color(1.0, 1.0, 1.0):
	set(value):
		text_color = value
		if is_inside_tree():
			_update_color()

## Duration the text stays on screen before it fades out.
@export_range(0.1, 10.0, 0.1, "suffix:s") var fade_duration : float = 0.5

## Duration of our fade out.
@export_range(0.1, 10.0, 0.1, "suffix:s") var fade_delay : float = 1.0


var _label : Label3D
var _delay : float = 1.0
var _modulate : float = 1.0

# Update our label text
func _update_text():
	if Engine.is_editor_hint():
		# In editor we don't apply the fade
		if text.is_empty():
			# and show a placeholder text
			_label.text = "FadeMessage3D"
			_update_color()
		else:
			_label.text = text
			_update_color()
	elif text.is_empty():
		_modulate = 0.0
		_label.visible = false
		set_process(false)
	else:
		_delay = fade_delay
		_modulate = 1.0
		_label.text = text
		_label.visible = true
		_update_color()
		set_process(true)


# Update our text color and modulation
func _update_color():
	_label.modulate = Color(text_color.r, text_color.g, text_color.b, _modulate)
	_label.outline_modulate = Color(0.0, 0.0, 0.0, _modulate)


# Called when the node enters the scene tree for the first time.
func _ready():
	_label = Label3D.new()
	_label.pixel_size = 0.002
	add_child(_label, false, Node.INTERNAL_MODE_BACK)

	_update_text()
	_update_color()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Don't run this in editor.
	if Engine.is_editor_hint():
		set_process(false)
		return

	# Once modulate reaches zero, hide and cleanup
	if _modulate == 0.00:
		_label.visible = false
		set_process(false)
		return

	# Apply our delay.
	if _delay > 0.0:
		_delay = max(0.0, _delay - delta)
		return

	# Fade out.
	_modulate = max(0.0, _modulate - delta / fade_duration)
	_update_color()
