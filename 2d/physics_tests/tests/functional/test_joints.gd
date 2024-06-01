extends Test

const OPTION_JOINT_TYPE = "Joint Type/%s Joint (%d)"

const OPTION_TEST_CASE_BODIES_COLLIDE = "Test case/Attached bodies collide"
const OPTION_TEST_CASE_WORLD_ATTACHMENT = "Test case/No parent body"
const OPTION_TEST_CASE_DYNAMIC_ATTACHMENT = "Test case/Parent body is dynamic (no gravity)"
const OPTION_TEST_CASE_DESTROY_BODY = "Test case/Destroy attached body"
const OPTION_TEST_CASE_CHANGE_POSITIONS = "Test case/Set body positions after added to scene"

const BOX_SIZE = Vector2(64, 64)

var _update_joint := false
var _selected_joint: Joint2D = null

var _bodies_collide := false
var _world_attachement := false
var _dynamic_attachement := false
var _destroy_body := false
var _change_positions := false

var _joint_types := {}

func _ready() -> void:
	var options: OptionMenu = $Options

	var joints: Node2D = $Joints
	for joint_index in joints.get_child_count():
		var joint_node := joints.get_child(joint_index)
		joint_node.visible = false
		var joint_name := String(joint_node.name)
		var joint_short := joint_name.substr(0, joint_name.length() - 7)
		var option_name := OPTION_JOINT_TYPE % [joint_short, joint_index + 1]
		options.add_menu_item(option_name)
		_joint_types[option_name] = joint_node

	options.add_menu_item(OPTION_TEST_CASE_BODIES_COLLIDE, true, false)
	options.add_menu_item(OPTION_TEST_CASE_WORLD_ATTACHMENT, true, false)
	options.add_menu_item(OPTION_TEST_CASE_DYNAMIC_ATTACHMENT, true, false)
	options.add_menu_item(OPTION_TEST_CASE_DESTROY_BODY, true, false)
	options.add_menu_item(OPTION_TEST_CASE_CHANGE_POSITIONS, true, false)

	options.option_selected.connect(_on_option_selected)
	options.option_changed.connect(_on_option_changed)

	_selected_joint = _joint_types.values()[0]
	_update_joint = true


func _process(_delta: float) -> void:
	if _update_joint:
		_update_joint = false
		await _create_joint()
		$LabelJointType.text = "Joint Type: " + String(_selected_joint.name)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.pressed:
		var joint_index: int = event.keycode - KEY_1
		if joint_index >= 0 and joint_index < _joint_types.size():
			_selected_joint = _joint_types.values()[joint_index]
			_update_joint = true


func _on_option_selected(option: String) -> void:
	if _joint_types.has(option):
		_selected_joint = _joint_types[option]
		_update_joint = true


func _on_option_changed(option: String, checked: bool) -> void:
	match option:
		OPTION_TEST_CASE_BODIES_COLLIDE:
			_bodies_collide = checked
			_update_joint = true
		OPTION_TEST_CASE_WORLD_ATTACHMENT:
			_world_attachement = checked
			_update_joint = true
		OPTION_TEST_CASE_DYNAMIC_ATTACHMENT:
			_dynamic_attachement = checked
			_update_joint = true
		OPTION_TEST_CASE_DESTROY_BODY:
			_destroy_body = checked
			_update_joint = true
		OPTION_TEST_CASE_CHANGE_POSITIONS:
			_change_positions = checked
			_update_joint = true


func _create_joint() -> void:
	cancel_timer()

	var root: Node2D = $Objects

	while root.get_child_count():
		var last_child_index := root.get_child_count() - 1
		var last_child := root.get_child(last_child_index)
		root.remove_child(last_child)
		last_child.queue_free()

	var child_body := create_rigidbody_box(BOX_SIZE, true, true)
	if _change_positions:
		root.add_child(child_body)
		child_body.position = Vector2(0.0, 40)
	else:
		child_body.position = Vector2(0.0, 40)
		root.add_child(child_body)

	var parent_body: PhysicsBody2D = null
	if not _world_attachement:
		parent_body = create_rigidbody_box(BOX_SIZE, true, true)
		if _dynamic_attachement:
			parent_body.gravity_scale = 0.0
			child_body.gravity_scale = 0.0
		else:
			parent_body.freeze = true
		if _change_positions:
			root.add_child(parent_body)
			parent_body.position = Vector2(0.0, -40)
		else:
			parent_body.position = Vector2(0.0, -40)
			root.add_child(parent_body)

	var joint := _selected_joint.duplicate()
	joint.visible = true
	joint.disable_collision = not _bodies_collide
	root.add_child(joint)
	if parent_body:
		joint.set_node_a(joint.get_path_to(parent_body))
	joint.set_node_b(joint.get_path_to(child_body))

	if _destroy_body:
		await start_timer(0.5).timeout
		if is_timer_canceled():
			return

		child_body.queue_free()
