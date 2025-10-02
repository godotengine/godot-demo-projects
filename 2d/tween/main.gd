extends Node

var tween: Tween
var sub_tween: Tween

@onready var icon: Sprite2D = %Icon
@onready var icon_start_position := icon.position

@onready var countdown_label: Label = %CountdownLabel
@onready var path: Path2D = $Path2D
@onready var progress: TextureProgressBar = %Progress

func _process(_delta: float) -> void:
	if not tween or not tween.is_running():
		return

	progress.value = tween.get_total_elapsed_time()


func start_animation() -> void:
	# Reset the icon to original state.
	reset()
	# Create the Tween. Also sets the initial animation speed.
	# All methods that modify Tween will return the Tween, so you can chain them.
	tween = create_tween().set_speed_scale(%SpeedSlider.value)

	# Sets the amount of loops. 1 loop = 1 animation cycle, so e.g. 2 loops will play animation twice.
	if %Infinite.button_pressed:
		tween.set_loops() # Called without arguments, the Tween will loop infinitely.
	else:
		tween.set_loops(%Loops.value)

	# Step 1

	if is_step_enabled("MoveTo", 1.0):
		# tween_*() methods return a Tweener object. Its methods can also be chained, but
		# it's stored in a variable here for readability (chained lines tend to be long).
		# Note the usage of ^"NodePath". A regular "String" is accepted too, but it's very slightly slower.
		var tweener := tween.tween_property(icon, ^"position", Vector2(400, 250), 1.0)
		tweener.set_ease(%Ease1.selected)
		tweener.set_trans(%Trans1.selected)

	# Step 2

	if is_step_enabled("ColorRed", 1.0):
		tween.tween_property(icon, ^"self_modulate", Color.RED, 1.0)

	# Step 3

	if is_step_enabled("MoveRight", 1.0):
		# as_relative() makes the value relative, so in this case it moves the icon
		# 200 pixels from the previous position.
		var tweener := tween.tween_property(icon, ^"position:x", 200.0, 1.0).as_relative()
		tweener.set_ease(%Ease3.selected)
		tweener.set_trans(%Trans3.selected)
	if is_step_enabled("Roll", 0.0):
		# parallel() makes the Tweener run in parallel to the previous one.
		var tweener := tween.parallel().tween_property(icon, ^"rotation", TAU, 1.0)
		tweener.set_ease(%Ease3.selected)
		tweener.set_trans(%Trans3.selected)

	# Step 4

	if is_step_enabled("MoveLeft", 1.0):
		tween.tween_property(icon, ^"position", Vector2.LEFT * 200, 1.0).as_relative()
	if is_step_enabled("Jump", 0.0):
		# Jump has 2 substeps, so to make it properly parallel, it can be done in a sub-Tween.
		# Here we are calling a lambda method that creates a sub-Tween.
		# Any number of Tweens can animate a single object in the same time.
		tween.parallel().tween_callback(func():
			# Note that transition is set on Tween, but ease is set on Tweener.
			# Values set on Tween will affect all Tweeners (as defaults) and values
			# on Tweeners can override them.
			sub_tween = create_tween().set_speed_scale(%SpeedSlider.value).set_trans(Tween.TRANS_SINE)
			sub_tween.tween_property(icon, ^"position:y", -150.0, 0.5).as_relative().set_ease(Tween.EASE_OUT)
			sub_tween.tween_property(icon, ^"position:y", 150.0, 0.5).as_relative().set_ease(Tween.EASE_IN)
		)

	# Step 5

	if is_step_enabled("Blink", 2.0):
		# Loops are handy when creating some animations.
		for i in 10:
			tween.tween_callback(icon.hide).set_delay(0.1)
			tween.tween_callback(icon.show).set_delay(0.1)

	# Step 6

	if is_step_enabled("Teleport", 0.5):
		# Tweening a value with 0 duration makes it change instantly.
		tween.tween_property(icon, ^"position", Vector2(325, 325), 0)
		tween.tween_interval(0.5)
		# Binds can be used for advanced callbacks.
		tween.tween_callback(icon.set_position.bind(Vector2(680, 215)))

	# Step 7

	if is_step_enabled("Curve", 3.5):
		# Method tweening is useful for animating values that can't be directly interpolated.
		# It can be used for remapping and some very advanced animations.
		# Here it's used for moving sprite along a path, using inline lambda function.
		var tweener := tween.tween_method(
				func(v: float) -> void:
					icon.position = path.position + path.curve.sample_baked(v), 0.0, path.curve.get_baked_length(), 3.0
		).set_delay(0.5)
		tweener.set_ease(%Ease7.selected)
		tweener.set_trans(%Trans7.selected)

	# Step 8

	if is_step_enabled("Wait", 2.0):
		# ...
		tween.tween_interval(2)

	# Step 9

	if is_step_enabled("Countdown", 3.0):
		tween.tween_callback(countdown_label.show)
		tween.tween_method(do_countdown, 4, 1, 3)
		tween.tween_callback(countdown_label.hide)

	# Step 10

	if is_step_enabled("Enlarge", 0.0):
		tween.tween_property(icon, ^"scale", Vector2.ONE * 5, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if is_step_enabled("Vanish", 1.0):
		tween.parallel().tween_property(icon, ^"self_modulate:a", 0.0, 1.0)

	if %Loops.value > 1 or %Infinite.button_pressed:
		tween.tween_callback(icon.show)
		tween.tween_callback(icon.set_self_modulate.bind(Color.WHITE))

	# RESET step

	if %Reset.button_pressed:
		tween.tween_callback(reset.bind(true))


func do_countdown(number: int) -> void:
	countdown_label.text = str(number)


func reset(soft: bool = false) -> void:
	icon.position = icon_start_position
	icon.self_modulate = Color.WHITE
	icon.rotation = 0
	icon.scale = Vector2.ONE
	icon.show()
	countdown_label.hide()

	if soft:
		# Only reset properties.
		return

	if tween:
		tween.kill()
		tween = null

	if sub_tween:
		sub_tween.kill()
		sub_tween = null

	progress.max_value = 0


func is_step_enabled(step: String, expected_time: float) -> bool:
	var enabled: bool = get_node("%" + step).button_pressed
	if enabled:
		progress.max_value += expected_time

	return enabled


func pause_resume() -> void:
	if tween and tween.is_valid():
		if tween.is_running():
			tween.pause()
		else:
			tween.play()

	if sub_tween and sub_tween.is_valid():
		if sub_tween.is_running():
			sub_tween.pause()
		else:
			sub_tween.play()


func kill_tween() -> void:
	if tween:
		tween.kill()
	if sub_tween:
		sub_tween.kill()


func speed_changed(value: float) -> void:
	if tween:
		tween.set_speed_scale(value)
	if sub_tween:
		sub_tween.set_speed_scale(value)

	%SpeedLabel.text = str("x", value)


func infinite_toggled(button_pressed: bool) -> void:
	%Loops.editable = not button_pressed
