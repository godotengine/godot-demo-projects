@tool
extends EditorPlugin


signal dialog_closed(canceled: bool)


enum TransformFlag {
	TRANSFORM_FLAG_POSITION = 1,
	TRANSFORM_FLAG_ROTATION = 2,
	TRANSFORM_FLAG_SCALE = 4,
}


enum StartPose {
	START_POSE_REST,
	START_POSE_RESET,
	START_POSE_CURRENT,
	START_POSE_FIRST_FRAME
}


const _PLUGIN_NAME: String = "Modifier Animation Baker..."


var _dialog: ConfirmationDialog
var _dialog_target: Button
var _dialog_library: OptionButton
var _dialog_animation_name: LineEdit
var _dialog_fps: SpinBox
var _dialog_pose: OptionButton
var _dialog_preprocess_delta: SpinBox
var _target_mixer: AnimationMixer
var _skeletons: Array[Skeleton3D] = []
var _skeleton_bones: Array = [] # Array[Bones as Array[int]]
var _skeleton_bone_track_paths: Array = [] # Array[Bones as Array[NodePath]]
var _skeleton_flags: Array = [] # Array[TransformFlags Array[int]]


func _enter_tree() -> void:
	add_tool_menu_item(_PLUGIN_NAME, self._main)
	_make_dialog()


func _exit_tree() -> void:
	remove_tool_menu_item(_PLUGIN_NAME)


func _make_label(text: String) -> Label:
	var ret: Label = Label.new()
	ret.custom_minimum_size = Vector2(200, 0)
	ret.text = text
	return ret


func _make_dialog() -> void:
	# New GUI elements.
	_dialog = ConfirmationDialog.new()
	_dialog.unresizable = true
	_dialog.title = "Modifier Animation Baker"
	_dialog_target = Button.new()
	_dialog_target.text = "Select Animation Mixer..."
	_dialog_library = OptionButton.new()
	_dialog_animation_name = LineEdit.new()
	_dialog_fps = SpinBox.new()
	_dialog_fps.step = 1
	_dialog_fps.min_value = 1
	_dialog_fps.max_value = 240
	_dialog_fps.allow_greater = true
	_dialog_fps.suffix = "FPS"
	_dialog_pose = OptionButton.new()
	_dialog_pose.add_item("Bone Rest", StartPose.START_POSE_REST)
	_dialog_pose.add_item("RESET", StartPose.START_POSE_RESET)
	_dialog_pose.add_item("Current Pose", StartPose.START_POSE_CURRENT)
	_dialog_pose.add_item("First Frame", StartPose.START_POSE_FIRST_FRAME)
	_dialog_preprocess_delta = SpinBox.new()
	_dialog_preprocess_delta.step = 0.001
	_dialog_preprocess_delta.min_value = 0.0
	_dialog_preprocess_delta.max_value = 10.0
	_dialog_preprocess_delta.allow_greater = true
	_dialog_preprocess_delta.suffix = "s"
	var grid: GridContainer = GridContainer.new()

	# Set default values.
	_dialog_fps.value = 30
	_dialog_pose.select(StartPose.START_POSE_CURRENT) # Default is do nothing.
	_dialog_preprocess_delta.value = 1.0

	# Add child GUI elements.
	grid.columns = 2
	add_child(_dialog, false, InternalMode.INTERNAL_MODE_BACK)
	_dialog.add_child(grid, false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_make_label("Target Animation Mixer"), false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_dialog_target, false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_make_label("Target Animation Library"), false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_dialog_library, false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_make_label("Animation Name"), false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_dialog_animation_name, false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_make_label("FPS"), false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_dialog_fps, false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_make_label("Start Pose"), false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_dialog_pose, false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_make_label("Wait Before Play"), false, InternalMode.INTERNAL_MODE_BACK)
	grid.add_child(_dialog_preprocess_delta, false, InternalMode.INTERNAL_MODE_BACK)
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialog_preprocess_delta.custom_minimum_size = Vector2(200, 0)
	_dialog_pose.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialog_fps.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialog_animation_name.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialog.connect("canceled", func (): dialog_closed.emit(true))
	_dialog.connect("confirmed", func (): dialog_closed.emit(false))
	_dialog_target.connect("pressed", _select_target)


func _select_target() -> void:
	_dialog.hide()
	EditorInterface.popup_node_selector(_on_target_selected, ["AnimationMixer"])


func _init_target() -> void:
	_target_mixer = null
	_dialog_target.text = "Select Animation Mixer..."
	_dialog_library.clear()


func _on_target_selected(np: NodePath) -> void:
	var node: Node = EditorInterface.get_edited_scene_root().get_node_or_null(np)
	if !node:
		_init_target()
		_dialog.show()
		return
	_target_mixer = node as AnimationMixer
	if !_target_mixer.has_animation("RESET"):
		printerr("ModifierAnimationBaker: Target AnimationMixer must have RESET animation to make bone list will be baked.")
		_init_target()
		_dialog.show()
		return
	_dialog_target.text = node.name
	_dialog_library.clear()
	var libraries: Array[StringName] = _target_mixer.get_animation_library_list()
	for l in libraries:
		if !_is_resource_editable(_target_mixer.get_animation_library(l).resource_path):
			continue
		var libname: String = "[Global]"
		if !l.is_empty():
			libname = l
		_dialog_library.add_item(libname)
	if _dialog_library.item_count == 0:
		printerr("ModifierAnimationBaker: Target AnimationMixer must have editable AnimationLibrary.")
		_init_target()
	_dialog.show()


func _is_resource_editable(resource_path: String) -> bool:
	var base: String = resource_path
	var srpos: int = base.find("::")
	if srpos != -1:
		base = base.substr(0, srpos);
	if FileAccess.file_exists(base + ".import"):
		return false
	return true


func _main() -> void:
	_init_target()
	# Check if it select only one animation mixer.
	var selected: EditorSelection = EditorInterface.get_selection()
	if selected.get_selected_nodes().size() != 1 || selected.get_selected_nodes()[0].get_class() != "AnimationPlayer":
		printerr("ModifierAnimationBaker: You should select only one AnimationPlayer.")
	var selected_player: AnimationPlayer = selected.get_selected_nodes()[0]
	var selected_animation: String = selected_player.assigned_animation
	if selected_animation.is_empty():
		printerr("ModifierAnimationBaker: AnimationPlayer must assign Animation.")
		return
	var selected_animation_length: float = selected_player.get_animation(selected_animation).length

	# Open dialog and input settings.
	_dialog_animation_name.text = selected_player.assigned_animation + "_baked"
	_dialog.popup_centered(Vector2(400, 100) * EditorInterface.get_editor_scale())
	var is_dialog_canceled: bool = await self.dialog_closed
	if is_dialog_canceled:
		print("ModifierAnimationBaker: Process canceled.")
		return

	# Validation.
	if !_target_mixer:
		print("ModifierAnimationBaker: Target Animation Mixer must be selected.")
		return
	var baked_animation_library_name: String = _dialog_library.text
	if baked_animation_library_name == "[Global]":
		baked_animation_library_name = ""
	if !_target_mixer.has_animation_library(baked_animation_library_name):
		print("ModifierAnimationBaker: Target Animation Library is not found in the Target Animation Mixer.")
		return
	var baked_animation_library: AnimationLibrary = _target_mixer.get_animation_library(baked_animation_library_name)
	if !_is_resource_editable(baked_animation_library.resource_path):
		print("ModifierAnimationBaker: Target Animation Library is not editable in the Target Animation Mixer.")
		return
	var baked_animation_name: String = _dialog_animation_name.text
	if baked_animation_library.has_animation(baked_animation_name):
		print("ModifierAnimationBaker: Baked Animation name is already exist in the Target Animation Mixer.")
		return
	var fps: int = max(1, _dialog_fps.value)
	var delta: float = maxf(0.001, 1.0 / fps)
	var start_pose: StartPose = clampi(_dialog_pose.selected, 0, 3) as StartPose
	var preprocess_delta: float = maxf(0.0, _dialog_preprocess_delta.value)

	# Retrieve what track should be baked.
	print("ModifierAnimationBaker: Preparing...")
	var reset_anim: Animation = _target_mixer.get_animation_library("").get_animation("RESET")
	_skeletons = []
	_skeleton_bones = []
	_skeleton_bone_track_paths = []
	_skeleton_flags = []
	var track_count: int = reset_anim.get_track_count()
	for i in track_count:
		var type: Animation.TrackType = reset_anim.track_get_type(i)
		match i:
			Animation.TrackType.TYPE_ANIMATION, Animation.TrackType.TYPE_AUDIO, Animation.TrackType.TYPE_BEZIER, Animation.TrackType.TYPE_BLEND_SHAPE, Animation.TrackType.TYPE_METHOD:
				continue
		var path: NodePath = reset_anim.track_get_path(i)
		if path.get_subname_count() != 1:
			continue
		var node = _target_mixer.get_node_or_null(_target_mixer.root_node)
		if !node:
			continue
		node = node.get_node_or_null(path)
		if !node:
			continue
		var skeleton: Skeleton3D = node as Skeleton3D
		if !skeleton:
			continue
		if !_skeletons.has(skeleton):
			_skeletons.push_back(skeleton)
			_skeleton_bones.push_back([])
			_skeleton_bone_track_paths.push_back([])
			_skeleton_flags.push_back([])
		var skeleton_index: int = _skeletons.find(skeleton)
		var bones: Array = _skeleton_bones[skeleton_index]
		var paths: Array = _skeleton_bone_track_paths[skeleton_index]
		var flags: Array = _skeleton_flags[skeleton_index]
		var bone: int = skeleton.find_bone(path.get_subname(0))
		if !bones.has(bone):
			bones.push_back(bone)
			paths.push_back(reset_anim.track_get_path(i))
			flags.push_back(0)
		var bone_index: int = bones.find(bone)
		if type == Animation.TrackType.TYPE_POSITION_3D:
			flags[bone_index] |= TransformFlag.TRANSFORM_FLAG_POSITION
		if type == Animation.TrackType.TYPE_ROTATION_3D:
			flags[bone_index] |= TransformFlag.TRANSFORM_FLAG_ROTATION
		if type == Animation.TrackType.TYPE_SCALE_3D:
			flags[bone_index] |= TransformFlag.TRANSFORM_FLAG_SCALE

	# Prepare target resource.
	var write: Animation = Animation.new()
	write.length = selected_animation_length
	for sidx in _skeletons.size():
		for bidx in _skeleton_bones[sidx].size():
			if _skeleton_flags[sidx][bidx] & TransformFlag.TRANSFORM_FLAG_POSITION:
				var t: int = write.add_track(Animation.TYPE_POSITION_3D)
				write.track_set_path(t, _skeleton_bone_track_paths[sidx][bidx])
			if _skeleton_flags[sidx][bidx] & TransformFlag.TRANSFORM_FLAG_ROTATION:
				var t: int = write.add_track(Animation.TYPE_ROTATION_3D)
				write.track_set_path(t, _skeleton_bone_track_paths[sidx][bidx])
			if _skeleton_flags[sidx][bidx] & TransformFlag.TRANSFORM_FLAG_SCALE:
				var t: int = write.add_track(Animation.TYPE_SCALE_3D)
				write.track_set_path(t, _skeleton_bone_track_paths[sidx][bidx])

	# Set start pose.
	match start_pose:
		StartPose.START_POSE_REST:
			selected_player.stop(true)
			for s in _skeletons:
				s.reset_bone_poses()
		StartPose.START_POSE_RESET:
			selected_player.stop()
			selected_player.play("RESET")
			selected_player.advance(0)
		StartPose.START_POSE_CURRENT:
			selected_player.stop(true)
		StartPose.START_POSE_FIRST_FRAME:
			selected_player.stop()
			selected_player.play(selected_animation)
			selected_player.advance(0)

	# Wait while preprocess delta.
	print("ModifierAnimationBaker: Waiting...")
	var processed: float = 0.0
	while processed < preprocess_delta:
		for s in _skeletons:
			s.advance(delta)
			s.notification(Skeleton3D.NOTIFICATION_UPDATE_SKELETON)
		processed += delta

	# Init selected animation state.
	print("ModifierAnimationBaker: Initalizing...")
	processed = 0.0
	selected_player.play(selected_animation)
	selected_player.advance(0)
	for s in _skeletons:
		s.advance(0)
		s.connect("skeleton_updated", _bake_keys.bind(write, processed), CONNECT_ONE_SHOT)
		s.notification(Skeleton3D.NOTIFICATION_UPDATE_SKELETON)

	# Play selected animation and bake keys.
	print("ModifierAnimationBaker: Baking...")
	while processed < selected_animation_length:
		processed = processed + delta
		if processed >= selected_animation_length:
			delta = processed - selected_animation_length
			processed = selected_animation_length
		selected_player.advance(delta)
		for s in _skeletons:
			s.advance(delta)
			s.connect("skeleton_updated", _bake_keys.bind(write, processed), CONNECT_ONE_SHOT)
			s.notification(Skeleton3D.NOTIFICATION_UPDATE_SKELETON)

	# Store baked Animation.
	baked_animation_library.add_animation(baked_animation_name, write)
	print("ModifierAnimationBaker: Bake completed!")


func _bake_keys(animation: Animation, pos: float) -> void:
	var increment: int = 0
	for sidx in _skeletons.size():
		var skel: Skeleton3D = _skeletons[sidx]
		var bones: Array = _skeleton_bones[sidx]
		for bidx in bones.size():
			var bn: int = bones[bidx]
			if _skeleton_flags[sidx][bidx] & TransformFlag.TRANSFORM_FLAG_POSITION:
				animation.position_track_insert_key(increment, pos, skel.get_bone_pose_position(bn) / skel.motion_scale)
				increment += 1
			if _skeleton_flags[sidx][bidx] & TransformFlag.TRANSFORM_FLAG_ROTATION:
				animation.rotation_track_insert_key(increment, pos, skel.get_bone_pose_rotation(bn))
				increment += 1
			if _skeleton_flags[sidx][bidx] & TransformFlag.TRANSFORM_FLAG_SCALE:
				animation.scale_track_insert_key(increment, pos, skel.get_bone_pose_scale(bn))
				increment += 1
