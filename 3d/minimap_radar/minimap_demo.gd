extends Spatial


export(Color) var environment_color
export(Color) var minimap_geometry_color
export(Color) var minimap_enemy_color
export(Color) var minimap_player_color

# demo movement values, this part can be deleted
var _player_rotation_speed : float = 50.0
var _player_updown_speed : float = 6.0
var _updown_movement_cap : float = 25.0
var _move_player_up : bool = true

onready var _minimap_camera = $Minimap_Viewport/Minimap_Camera
onready var _player = $Player_Robot


func _ready():
	
	# set the minimap background color
	$CanvasLayer/PanelContainer.get("custom_styles/panel").set("bg_color", environment_color * Color.slategray)
	
	# set the environment fog effect color
	$Environment/WorldEnvironment.get_environment().background_color = environment_color
	$Environment/WorldEnvironment.get_environment().fog_color = environment_color
		
	#########################
	# LEVEL GEOMETRY
	
	# get all minimap environment meshes
	var _minimap_environment_meshes : Array = get_tree().get_nodes_in_group("minimap_environment_meshes")
	if _minimap_environment_meshes:
		
		# make sure all minimap meshes use the minimap render layer and not the default one
		for _minimap_mesh in _minimap_environment_meshes:
			_minimap_mesh.set_layer_mask_bit(0, false)
			_minimap_mesh.set_layer_mask_bit(9, true)

		# set the color and fade distances for the minimap level geometry (only need first mesh group member as material is shared)
		var _minimap_mesh_material = _minimap_environment_meshes[0].get_surface_material(0)
		if _minimap_mesh_material.is_class("SpatialMaterial"):
			_minimap_mesh_material.albedo_color = minimap_geometry_color
			_minimap_mesh_material.proximity_fade_enable = true
			_minimap_mesh_material.proximity_fade_distance = _minimap_camera.camera_up_clip_distance
			_minimap_mesh_material.distance_fade_mode = SpatialMaterial.DISTANCE_FADE_PIXEL_ALPHA
			_minimap_mesh_material.distance_fade_max_distance = _minimap_camera.camera_down_clip_distance + _minimap_camera.camera_up_clip_distance
	
	#########################
	# PLAYER
	
	# set player color for the minimap
	_player.get_node("Minimap_Orb").get_surface_material(0).albedo_color = minimap_player_color
	
	# make sure player minimap mesh use the minimap render layer and not the default one
	_player.get_node("Minimap_Orb").set_layer_mask_bit(0, false)
	_player.get_node("Minimap_Orb").set_layer_mask_bit(9, true)
	
	#########################
	# ENEMIES
	
	# get all minimap enemies
	var _enemies = get_tree().get_nodes_in_group("enemy")
	if _enemies:
		# make sure all minimap meshes use the minimap render layer and not the default one
		for _enemy in _enemies:
			_enemy.get_node("Minimap_Orb").set_layer_mask_bit(0, false)
			_enemy.get_node("Minimap_Orb").set_layer_mask_bit(9, true)
		
		# set enemy color for the minimap (only need first enemy group member as material is shared)
		var _enemy_material = _enemies[0].get_node("Minimap_Orb").get_surface_material(0)
		_enemy_material.albedo_color = minimap_enemy_color
		_enemy_material.proximity_fade_enable = true
		_enemy_material.proximity_fade_distance = _minimap_camera.camera_up_clip_distance * 0.5
		_enemy_material.distance_fade_mode = SpatialMaterial.DISTANCE_FADE_PIXEL_ALPHA
		_enemy_material.distance_fade_max_distance = (_minimap_camera.camera_down_clip_distance + _minimap_camera.camera_up_clip_distance) * 0.5

	set_process(true)


func _process(delta):
	
	# demo movement, this part can be deleted
	_player.rotation_degrees.y += delta * _player_rotation_speed
	if _move_player_up:
		_player.translation.y += delta * _player_updown_speed
		if _player.translation.y > _updown_movement_cap:
			_move_player_up = false
	else:
		_player.translation.y -= delta * _player_updown_speed
		if _player.translation.y < -_updown_movement_cap:
			_move_player_up = true
	
	# rotate minimap camera with the player
	_minimap_camera.rotation_degrees.y = _player.rotation_degrees.y
	
	# follow player position on the map but keep offset for clipping
	var _camera_translation = _player.translation
	_camera_translation.y = _camera_translation.y + _minimap_camera.camera_up_clip_distance
	_minimap_camera.translation = _camera_translation
	
	# update text label with our current height for orientation, this part can be deleted
	$CanvasLayer/VBoxContainer/Height_Value.text = "%*.*f" % [5, 2, _player.translation.y]
