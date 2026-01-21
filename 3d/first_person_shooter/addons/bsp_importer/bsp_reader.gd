extends Node

class_name BSPReader

const USE_BSPX_BRUSHES := true # If -wrbrushes is used, use the extra brush data for collision instead of the BSP tree collision.
const TEST_BOX_ONLY_COLLISION := false # For performance testing using only boxes.
# Documentation: https://docs.godotengine.org/en/latest/tutorials/plugins/editor/import_plugins.html
const SINGLE_STATIC_BODY := true

const CONTENTS_EMPTY := -1
const CONTENTS_SOLID := -2
const CONTENTS_WATER := -3
const CONTENTS_SLIME := -4
const CONTENTS_LAVA := -5
const SURFACE_FLAG_SKY := 4
const SURFACE_FLAG_NODRAW := 128
const SURFACE_FLAG_HINT := 256
const SURFACE_FLAG_SKIP := 512
#define CONTENTS_SKY          -6
#define CONTENTS_ORIGIN       -7
#define CONTENTS_CLIP         -8
#define CONTENTS_CURRENT_0    -9
#define CONTENTS_CURRENT_90   -10
#define CONTENTS_CURRENT_180  -11
#define CONTENTS_CURRENT_270  -12
#define CONTENTS_CURRENT_UP   -13
#define CONTENTS_CURRENT_DOWN -14
#define CONTENTS_TRANSLUCENT  -15

const BSPX_NAME_LENGTH := 24

const CLIPNODES_STRUCT_SIZE := (4 + 2 + 2) # 32bit int for plane index, 2 16bit children.
const NODES_STRUCT_SIZE_Q1BSP := (4 + 2 + 2 + 2 * 6 + 2 + 2) # 32bit int for plane index, 2 16bit children.  bbox short, face id, face num
const NODES_STRUCT_SIZE_Q1BSP2 := (4 + 4 + 4 + 4 * 6 + 4 + 4) # 32bit int for plane index, 2 32bit children.  bbox int32?, face id, face num

#typedef struct
#{ long type;                   // Special type of leaf
#  long vislist;                // Beginning of visibility lists
#                               //     must be -1 or in [0,numvislist[
#  bboxshort_t bound;           // Bounding box of the leaf
#  u_short lface_id;            // First item of the list of faces
#                               //     must be in [0,numlfaces[
#  u_short lface_num;           // Number of faces in the leaf  
#  u_char sndwater;             // level of the four ambient sounds:
#  u_char sndsky;               //   0    is no sound
#  u_char sndslime;             //   0xFF is maximum volume
#  u_char sndlava;              //
#} dleaf_t;

const LEAF_SIZE_Q1BSP := 4 + 4 + 2 * 6 + 2 + 2 + 1 + 1 + 1 + 1
const LEAF_SIZE_BSP2 := 4 + 4 + 4 * 6 + 4 + 4 + 1 + 1 + 1 + 1


class BSPEdge:
	var vertex_index_0 : int
	var vertex_index_1 : int
	func read_edge_16_bit(file : FileAccess) -> int:
		vertex_index_0 = file.get_16()
		vertex_index_1 = file.get_16()
		return 4 # 2 2 byte values
	func read_edge_32_bit(file : FileAccess) -> int:
		vertex_index_0 = file.get_32()
		vertex_index_1 = file.get_32()
		return 8 # 2 4 byte values


class BSPModelData:
	var bound_min : Vector3
	var bound_max : Vector3
	var origin : Vector3
	var node_id0 : int
	var node_id1 : int
	var node_id2 : int
	var node_id3 : int
	var num_leafs : int # For vis?
	var face_index : int
	var face_count : int

const MODEL_DATA_SIZE_Q1_BSP := 2 * 3 * 4 + 3 * 4 + 7 * 4

func read_model_data_q1_bsp(model_data : BSPModelData):
	# Since some axes are negated here, min/max is funky.
	var mins := read_vector_convert_scaled()
	var maxs := read_vector_convert_scaled()
	model_data.bound_min = Vector3(min(mins.x, maxs.x), min(mins.y, maxs.y), min(mins.z, maxs.z))
	model_data.bound_max = Vector3(max(mins.x, maxs.x), max(mins.y, maxs.y), max(mins.z, maxs.z))
	# Not sure why, but it seems the mins/maxs are 1 unit inside of the actual mins/maxs, so increase bounds by 1 unit:
	model_data.bound_min -= Vector3(unit_scale, unit_scale, unit_scale)
	model_data.bound_max += Vector3(unit_scale, unit_scale, unit_scale)
	model_data.origin = read_vector_convert_scaled()
	model_data.node_id0 = file.get_32()
	model_data.node_id1 = file.get_32()
	model_data.node_id2 = file.get_32()
	model_data.node_id3 = file.get_32()
	model_data.num_leafs = file.get_32()
	model_data.face_index = file.get_32()
	model_data.face_count = file.get_32()


class BSPModelDataQ2:
	var bound_min : Vector3
	var bound_max : Vector3
	var origin : Vector3
	var node_id0 : int
	static func get_data_size() -> int:
		return 2 * 3 * 4 + 3 * 4 + 1 * 4
	func read_model(file : FileAccess):
		bound_min = Vector3(file.get_float(), file.get_float(), file.get_float())
		bound_max = Vector3(file.get_float(), file.get_float(), file.get_float())
		origin = Vector3(file.get_float(), file.get_float(), file.get_float())
		node_id0 = file.get_32()


# For load_or_create_material, because we can't return more than one thing...
class MaterialInfo:
	var width : int
	var height : int
	var material : Material


static var default_palette : PackedByteArray = []

class BSPTexture:
	var name : StringName
	var width : int
	var height : int
	var material : Material
	var is_warp := false
	var is_transparent := false
	var texture_data_offset : int

	static func get_data_size() -> int:
		return 40 # 16 + 4 * 6

	func read_texture(file : FileAccess, reader : BSPReader) -> int:
		var texture_header_file_offset := file.get_position()
		name = file.get_buffer(16).get_string_from_ascii()
		if (name.begins_with("*")):
			name = name.substr(1)
			is_warp = true
			is_transparent = true
		if (name.begins_with(reader.transparent_texture_prefix)):
			name = name.substr(reader.transparent_texture_prefix.length())
			is_transparent = true
		width = file.get_32()
		height = file.get_32()
		texture_data_offset = BSPReader.unsigned32_to_signed(file.get_32())
		if (texture_data_offset > 0):
			texture_data_offset += texture_header_file_offset
		file.get_32() # for mip levels
		file.get_32() # for mip levels
		file.get_32() # for mip levels
		name = name.to_lower()
		#current_file_offset = file.get_position()
		print("texture: ", name, " width: ", width, " height: ", height)
		if (name != &"skip" && name != &"trigger" && name != &"waterskip" && name != &"slimeskip" && name != &"clip" && (reader.include_sky_surfaces || !name.begins_with("sky"))):
			var material_info := reader.load_or_create_material(name, self)
			if (material_info):
				material = material_info.material
				width = material_info.width
				height = material_info.height
			else:
				printerr("Failed to load or create material for ", name)
		return get_data_size()


class BSPTextureInfo:
	var vec_s : Vector3
	var offset_s : float
	var vec_t : Vector3
	var offset_t : float
	var texture_index : int
	var flags : int
	# Q2 stuff:
	var value : int
	var texture_path : String
	static func get_data_size() -> int:
		return 40 # 3 * 2 * 4 + 4 * 2 + 2 * 4
	func read_texture_info(file : FileAccess) -> int:
		#vec_s = BSPImporterPlugin.convert_normal_vector_from_quake(Vector3(file.get_float(), file.get_float(), file.get_float()))
		vec_s = BSPReader.read_vector_convert_unscaled(file)
		offset_s = file.get_float()
		#vec_t = BSPImporterPlugin.convert_normal_vector_from_quake(Vector3(file.get_float(), file.get_float(), file.get_float()))
		vec_t = BSPReader.read_vector_convert_unscaled(file)
		offset_t = file.get_float()
		texture_index = file.get_32()
		#print("texture_index: ", texture_index)
		flags = file.get_32()
		return get_data_size()


class BSPFace:
	var plane_id : int
	var plane_side : int
	var edge_list_id : int # var first_edge?
	var num_edges : int
	var texinfo_id : int
	var light_type : int
	var light_base : int
	var light_model_0 : int
	var light_model_1 : int
	var lightmap : int
	var lightmap_start : Vector2i
	var lightmap_size : Vector2i
	
	# most Q3 stuff isnt needed with the current construction method but i'll probably figure that out later, otherwise that would go here. - cs
	
	var verts : PackedVector3Array = [] # For Mesh Construction
	var q3_uv : PackedVector2Array
	var q3_uv2 : PackedVector2Array
	var vert_normal : Vector3 = Vector3.ZERO
	var face_normal : Vector3 = Vector3.ZERO
	
	static func get_data_size_q1bsp() -> int:
		return 20
	static func get_data_size_bsp2() -> int: # for bsp2
		return 20 + 2 * 4 # plane id, side, num edges all have an extra 2 bytes going from 16 to 32 bit
	func print_face():
		print("BSPFace: plane_id: ", plane_id, " side: ", plane_side, " edge_list_id: ", edge_list_id, " num_edges: ", num_edges, " texinfo_id: ", texinfo_id)
	func read_face_q1bsp(file : FileAccess) -> int:
		plane_id = file.get_16()
		plane_side = file.get_16()
		edge_list_id = file.get_32()
		num_edges = file.get_16()
		texinfo_id = file.get_16()
		light_type = file.get_8()
		light_base = file.get_8()
		light_model_0 = file.get_8()
		light_model_1 = file.get_8()
		lightmap = file.get_32()
		return get_data_size_q1bsp()
	func read_face_bsp2(file : FileAccess) -> int:
		plane_id = file.get_32()
		#print("plane_id ", plane_id)
		plane_side = file.get_32()
		#print("side ", side)
		edge_list_id = file.get_32()
		#print("edge_list_id ", edge_list_id)
		num_edges = file.get_32()
		#print("num_edges ", num_edges)
		texinfo_id = file.get_32()
		#print("texinfo_id ", texinfo_id)
		light_type = file.get_8()
		light_base = file.get_8()
		light_model_0 = file.get_8()
		light_model_1 = file.get_8()
		lightmap = file.get_32()
		#print("lightmap ", lightmap)
		return get_data_size_bsp2()


const MAX_15B := 1 << 15
const MAX_16B := 1 << 16

static func unsigned16_to_signed(unsigned : int) -> int:
	return (unsigned + MAX_15B) % MAX_16B - MAX_15B


const MAX_31B = 1 << 31
const MAX_32B = 1 << 32

static func unsigned32_to_signed(unsigned : int) -> int:
	return (unsigned + MAX_31B) % MAX_32B - MAX_31B


# X is forward in Quake, -Z is forward in Godot.  Z is up in Quake, Y is up in Godot
static func convert_vector_from_quake_unscaled(quake_vector : Vector3) -> Vector3:
	return Vector3(-quake_vector.y, quake_vector.z, -quake_vector.x)


static func convert_vector_from_quake_scaled(quake_vector : Vector3, scale: float) -> Vector3:
	return Vector3(-quake_vector.y, quake_vector.z, -quake_vector.x) * scale


static func read_vector_convert_unscaled(file : FileAccess) -> Vector3:
	return convert_vector_from_quake_unscaled(Vector3(file.get_float(), file.get_float(), file.get_float()))


func read_vector_convert_scaled() -> Vector3:
	return convert_vector_from_quake_scaled(Vector3(file.get_float(), file.get_float(), file.get_float()), unit_scale)


var error := ERR_UNCONFIGURED
var save_separate_materials := false # Save material as separate resource.  Set to false when loading in-game.
var material_path_pattern : String
var texture_material_rename : Dictionary
var texture_path_pattern : String
var texture_emission_path_pattern : String
var texture_path_remap : Dictionary
var transparent_texture_prefix : String
var texture_palette_path : String
var entity_path_pattern : String
var water_template : PackedScene
var slime_template : PackedScene
var lava_template : PackedScene
var entity_remap : Dictionary
var entity_offsets_quake_units : Dictionary
var array_of_planes_array := []
var array_of_planes : PackedInt32Array = []
var water_planes_array := []  # Array of arrays of planes
var slime_planes_array := []
var lava_planes_array := []
var file : FileAccess
var leaves_offset : int
var nodes_offset : int
var root_node : Node3D
var plane_normals : PackedVector3Array
var plane_distances : PackedFloat32Array
var model_scenes : Dictionary = {}
var is_bsp2 := false
var unit_scale : float = 1.0 / 32.0
var import_lights := true
var light_brightness_scale := 16.0
var generate_occlusion_culling := true
var generate_shadow_mesh := false
var use_triangle_collision := false
var culling_textures_exclude : Array[StringName]
var generate_lightmap_uv2 := true
var post_import_script_path : String
var ignore_missing_entities := false
var separate_mesh_on_grid := false
var generate_texture_materials := false
var overwrite_existing_materials := false
var overwrite_existing_textures := false
var mesh_separation_grid_size := 256.0
var bspx_model_to_brush_map := {}
var fullbright_range : PackedInt32Array = [224, 255]
var ignored_flags : PackedInt64Array = []
var include_sky_surfaces := true

# used for reading wads for goldsource games.
var is_gsrc : bool = false 
var wad_paths : Array[WADReader] = []

func clear_data():
	error = ERR_UNCONFIGURED
	array_of_planes_array = []
	array_of_planes = []
	water_planes_array = []
	slime_planes_array = []
	lava_planes_array = []
	if (file):
		file.close()
		file = null
	root_node = null
	plane_normals = []
	plane_distances = []
	model_scenes = {}
	wad_paths.clear()

# To find the end of a block of l
static func get_lumps_end(current_end : int, offset : int, length : int) -> int:
	return max(current_end, offset + length)


class BSPXBrush:
	var mins : Vector3
	var maxs : Vector3
	var contents : int
	var planes : Array[Plane]



func read_bsp(source_file : String) -> Node:
	
	clear_data() # Probably not necessary, but just in case somebody reads a bsp file with the same instance
	print("Attempting to import %s" % source_file)
	print("Material path pattern: ", material_path_pattern)
	file = FileAccess.open(source_file, FileAccess.READ)
	
	if !(ignored_flags == PackedInt64Array([])): push_warning("Ignored Flags seems to have a value, this array's usage is only integrated for Quake 2/3 at the moment.")
	
	if (!file):
		error = FileAccess.get_open_error()
		print("Failed to open %s: %d" % [source_file, error])
		return null
	
	root_node = Node3D.new()
	root_node.name = source_file.get_file().get_basename() # Get the file out of the path and remove file extension
	
	# Read the header
	var is_q2 := false
	is_bsp2 = false
	var has_textures := true
	var has_clipnodes := true
	var has_brush_table := false
	var bsp_version := file.get_32()
	
	var index_bits_32 := false
	print("BSP version: %d\n" % bsp_version, " ")
	is_gsrc = (bsp_version == 30) # check if its goldsrc so it doesn't try to look for textures in WADs for non-goldsrc formats.
	if is_gsrc:
		create_wad_table()
		prints("WADs located.")
	
	if (bsp_version == 1347633737): # "IBSP" - Quake 2 BSP format, this also creates for Quake 3.
		var bsp_q2_texts = [
			"Moving File %s to QBSPi2" % source_file.get_file().get_basename(),
			"QBSPi2 is Our Lord and Savior!, said literally no one ever.",
			"Why did jitspoe decide QBSPi2 should be in here??",
			"Why did I decide QBSPi2 would be a fun project?? like?? why???",
			
		]
		
		prints("IBSP Format Detected.", bsp_q2_texts.pick_random())
		
		# Keeping these for safety!
		is_q2 = true
		has_textures = false
		has_clipnodes = false
		has_brush_table = true
		bsp_version = file.get_32()
		
		print("BSP sub-version: %d\n" % bsp_version)
		file.close()
		file = null
		return convertBSPtoScene(source_file)
	if (bsp_version == 1112756274): # "2PSB" - depricated extended quake BSP format.
		print("2PSB format not supported.")
		file.close()
		file = null
		return
	if (bsp_version == 844124994): # "BSP2" - extended Quake BSP format
		print("BSP2 extended Quake format.")
		is_bsp2 = true
		index_bits_32 = true
	
	var entity_offset := file.get_32()
	var entity_size := file.get_32()
	# Need to figure out the end of the vanilla BSP data so that we can get the BSPX data.
	var bsp_end := get_lumps_end(0, entity_offset, entity_size)
	var planes_offset := file.get_32()
	var planes_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, planes_offset, planes_size)
	var textures_offset := file.get_32() if has_textures else 0
	var textures_size := file.get_32() if has_textures else 0
	bsp_end = get_lumps_end(bsp_end, textures_offset, textures_size)
	var verts_offset := file.get_32()
	var verts_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, verts_offset, verts_size)
	var vis_offset := file.get_32()
	var vis_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, vis_offset, vis_size)
	nodes_offset = file.get_32()
	var nodes_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, nodes_offset, nodes_size)
	var texinfo_offset := file.get_32()
	var texinfo_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, texinfo_offset, texinfo_size)
	var faces_offset := file.get_32()
	var faces_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, faces_offset, faces_size)
	var lightmaps_offset := file.get_32()
	var lightmaps_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, lightmaps_offset, lightmaps_size)
	var clipnodes_offset := file.get_32() if has_clipnodes else 0
	var clipnodes_size := file.get_32() if has_clipnodes else 0
	bsp_end = get_lumps_end(bsp_end, clipnodes_offset, clipnodes_size)
	leaves_offset = file.get_32()
	var leaves_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, leaves_offset, leaves_size)
	var listfaces_size := file.get_32()
	var listfaces_offset := file.get_32()
	bsp_end = get_lumps_end(bsp_end, listfaces_offset, listfaces_size)
	var leaf_brush_table_offset := file.get_32() if has_brush_table else 0 # For Q2
	var leaf_brush_table_size := file.get_32() if has_brush_table else 0
	bsp_end = get_lumps_end(bsp_end, leaf_brush_table_offset, leaf_brush_table_size)
	var edges_offset := file.get_32()
	var edges_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, edges_offset, edges_size)
	var listedges_offset := file.get_32()
	var listedges_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, listedges_offset, listedges_size)
	var models_offset := file.get_32()
	var models_size := file.get_32()
	bsp_end = get_lumps_end(bsp_end, models_offset, models_size)
	# Q2-specific
	var brushes_offset := file.get_32() if has_brush_table else 0
	var brushes_size := file.get_32() if has_brush_table else 0
	bsp_end = get_lumps_end(bsp_end, brushes_offset, brushes_size)
	var brush_sides_offset := file.get_32() if has_brush_table else 0
	var brush_sides_size := file.get_32() if has_brush_table else 0
	bsp_end = get_lumps_end(bsp_end, brush_sides_offset, brush_sides_size)
	# Pop
	# Areas
	# Area portals
	
	# BSPX support: https://github.com/fte-team/fteqw/blob/master/specs/bspx.txt
	var has_bspx := false
	var bspx_offset := bsp_end
	# Needs to be aligned by 4.
	bspx_offset = ((bspx_offset + 3) / 4) * 4
	file.seek(bspx_offset)
	var bspx_check := file.get_32()
	var use_bspx_brushes := false
	if (bspx_check == 1481659202): # "BSPX"
		has_bspx = true
		print("Has BSPX.")
		var has_bspx_brushes := false
		var bspx_brushes_offset := 0
		var bspx_brushes_length := 0
		var num_bspx_entries := file.get_32()
		for i in num_bspx_entries:
			var entry_name := file.get_buffer(BSPX_NAME_LENGTH).get_string_from_ascii()
			print("BSPX entry: ", entry_name)
			if (entry_name == "BRUSHLIST"):
				print("Has BSPX brush list.")
				has_bspx_brushes = true
				bspx_brushes_offset = file.get_32()
				bspx_brushes_length = file.get_32()
		if (has_bspx_brushes && USE_BSPX_BRUSHES):
			use_bspx_brushes = true
			var bytes_read := 0
			file.seek(bspx_brushes_offset)
			while (file.get_position() < file.get_length()): # Safer than while (true)
				if (bytes_read >= bspx_brushes_length):
					break
				var version := file.get_32()
				bytes_read += 4
				if (version != 1):
					print("Only BSPX brush version 1 supported. Version: ", version)
					break
				var model_num := file.get_32()
				bytes_read += 4
				var get_whatever := bspx_model_to_brush_map.get(model_num)
				var brush_array : Array[BSPXBrush] = []
				if (get_whatever):
					brush_array = get_whatever # WHY?!??!?!?!?!?!?!
				var num_brushes := file.get_32()
				bytes_read += 4
				var num_planes_total := file.get_32()
				bytes_read += 4

				for brush_index in num_brushes:
					var bspx_brush := BSPXBrush.new()
					var mins := read_vector_convert_scaled()
					bytes_read += 3 * 4
					var maxs := read_vector_convert_scaled()
					bytes_read += 3 * 4
					bspx_brush.mins = Vector3(minf(mins.x, maxs.x), minf(mins.y, maxs.y), minf(mins.z, maxs.z))
					bspx_brush.maxs = Vector3(maxf(mins.x, maxs.x), maxf(mins.y, maxs.y), maxf(mins.z, maxs.z))
					bspx_brush.contents = unsigned16_to_signed(file.get_16())
					bytes_read += 2
					var num_bspx_planes := file.get_16()
					bytes_read += 2
					for plane_index in num_bspx_planes:
						var normal := read_vector_convert_unscaled(file)
						bytes_read += 3 * 4
						var dist := file.get_float() * unit_scale
						bytes_read += 4
						var plane := Plane(normal, dist)
						bspx_brush.planes.append(plane)
					brush_array.append(bspx_brush)
				bspx_model_to_brush_map[model_num] = brush_array
	else:
		print("Does not have BSPX.")
	


	# Read vertex data
	var verts : PackedVector3Array
	file.seek(verts_offset)
	var vert_data_left := verts_size
	var vertex_count := verts_size / (4 * 3)
	verts.resize(vertex_count)
	for i in vertex_count:
		verts[i] = convert_vector_from_quake_scaled(Vector3(file.get_float(), file.get_float(), file.get_float()), unit_scale)

	# Read entity data
	file.seek(entity_offset)
	var entity_string : String = file.get_buffer(entity_size).get_string_from_ascii()
	#print("Entity data: ", entity_string)
	var entity_dict_array := parse_entity_string(entity_string)
	convert_entity_dict_to_scene(entity_dict_array)

	#print("edges_offset: ", edges_offset)
	file.seek(edges_offset)
	var edges_data_left := edges_size
	var edges := []
	while (edges_data_left > 0):
		var edge := BSPEdge.new()
		if (index_bits_32):
			edges_data_left -= edge.read_edge_32_bit(file)
		else:
			edges_data_left -= edge.read_edge_16_bit(file)
		#print("edge v 0: ", edge.vertex_index_0)
		#print("edge v 1: ", edge.vertex_index_0)
		edges.append(edge)
	#print("edges_data_left: ", edges_data_left)

	var edge_list : PackedInt32Array
	var num_edge_list := listedges_size / 4
	edge_list.resize(num_edge_list)
	file.seek(listedges_offset)
	for i in num_edge_list:
		#edge_list[i] = unsigned16_to_signed(file.get_16())
		# Page was wrong, this is 32bit
		edge_list[i] = file.get_32()
		#print("edge list: ", edge_list[i])

	var num_planes := planes_size / (4 * 5) # vector, float, and int32
	plane_normals.resize(num_planes)
	plane_distances.resize(num_planes)
	file.seek(planes_offset)
	for i in num_planes:
		var quake_plane_normal := Vector3(file.get_float(), file.get_float(), file.get_float())
		plane_normals[i] = convert_vector_from_quake_unscaled(quake_plane_normal)
		plane_distances[i] = file.get_float() * unit_scale
		var _type = file.get_32() # 0 = X-Axial plane, 1 = Y-axial pane, 2 = z-axial plane, 3 nonaxial, toward x, 4 y, 5 z
		#print("Quake plane ", i, ": ", quake_plane_normal, " dist: ", plane_distances[i], " type: ", _type)
	#print("plane_normals: ", plane_normals)
	file.seek(clipnodes_offset)
	var num_clipnodes := clipnodes_size / CLIPNODES_STRUCT_SIZE
	print("clipnodes offset: ", clipnodes_offset, " clipnodes_size: ", clipnodes_size, " num_clipnodes: ", num_clipnodes)
	# todo
	
	# Read in the textures (to get the sizes for UV's)
	#print("textures offset: ", textures_offset)
	#var texture_data_left := textures_size
	#var num_textures := textures_size / BSPTexture.get_data_size()
	var textures := []
	var texture_offset_offsets : PackedInt32Array # Offset to texture area has an array of offsets relative to the start of this
	
	file.seek(textures_offset)
	var num_textures := file.get_32()
	texture_offset_offsets.resize(num_textures)
	print("num_textures: ", num_textures)
	textures.resize(num_textures)
	for i in num_textures:
		texture_offset_offsets[i] = file.get_32()
	for i in num_textures:
		var texture_offset := texture_offset_offsets[i]
		if (texture_offset < 0):
			print("Missing texture ", i, " make sure wad file is compiled into map.")
			var bad_tex := BSPTexture.new()
			bad_tex.width = 64
			bad_tex.height = 64
			bad_tex.name = "_bad_texture_"
			textures[i] = bad_tex
		else:
			var complete_offset := textures_offset + texture_offset
			file.seek(complete_offset)
			textures[i] = BSPTexture.new()
			textures[i].read_texture(file, self)

	# UV stuff
	file.seek(texinfo_offset)
	var num_texinfo := texinfo_size / BSPTextureInfo.get_data_size()
	var textureinfos := []
	textureinfos.resize(num_texinfo)
	for i in num_texinfo:
		textureinfos[i] = BSPTextureInfo.new()
		textureinfos[i].read_texture_info(file)
		#print("Textureinfo: ", textureinfos[i].vec_s, " ", textureinfos[i].offset_s, " ", textureinfos[i].vec_t, " ", textureinfos[i].offset_t, " ", textureinfos[i].texture_index)

	# Get model data:
	var model_data_size := MODEL_DATA_SIZE_Q1_BSP if !is_q2 else BSPModelDataQ2.get_data_size()
	var num_models := models_size / model_data_size
	var model_data := []
	model_data.resize(num_models)
	for i in num_models:
		if (is_q2):
			model_data[i] = BSPModelDataQ2.new()
			file.seek(models_offset + model_data_size * i) # We'll skip around in the file loading data
			model_data[i].read_model(file)
		else:
			model_data[i] = BSPModelData.new()
			file.seek(models_offset + model_data_size * i) # We'll skip around in the file loading data
			read_model_data_q1_bsp(model_data[i])

	file.seek(faces_offset)
	var face_data_left := faces_size
	var bsp_face := BSPFace.new()
	var begun := false
	var previous_tex_name := "UNSET"

	for model_index in num_models:
		#print("Model index ", model_index)
		var mesh_grid := {} # Dictionary of surface tools where the key is an integer vector3.
		water_planes_array = [] # Clear that out so water isn't duplicated for each mesh.
		slime_planes_array = []
		lava_planes_array = []
		var needs_import := false
		var parent_node : Node3D = root_node
		var parent_inv_transform := Transform3D() # If a world model is rotated (such as a trigger) we want to keep things in the correct spot
		var is_worldspawn := (model_index == 0)
		if (is_worldspawn):
			needs_import = true # Always import worldspawn.
			if (SINGLE_STATIC_BODY):
				var static_body := StaticBody3D.new()
				static_body.name = "StaticBody"
				root_node.add_child(static_body, true)
				static_body.owner = root_node
				parent_node = static_body
		if (model_scenes.has(model_index)):
			needs_import = true # Import supported entities.
			parent_node = model_scenes[model_index]
			parent_inv_transform = Transform3D(parent_node.transform.basis.inverse(), Vector3.ZERO) #parent_node.transform.inverse()
		if (needs_import):
			var bsp_model : BSPModelData = model_data[model_index]
			var face_size := BSPFace.get_data_size_q1bsp() if !is_bsp2 else BSPFace.get_data_size_bsp2()
			file.seek(faces_offset + bsp_model.face_index * face_size)
			var num_faces := bsp_model.face_count
			#print("num_faces: ", num_faces)
			for face_index in num_faces:
				if (is_bsp2):
					bsp_face.read_face_bsp2(file)
				else:
					bsp_face.read_face_q1bsp(file)
				if (bsp_face.texinfo_id > textureinfos.size()):
					printerr("Bad texinfo_id: ", bsp_face.texinfo_id)
					bsp_face.print_face()
					continue
				if (bsp_face.num_edges < 3):
					printerr("face with fewer than 3 edges.")
					bsp_face.print_face()
					continue

				var edge_list_index_start := bsp_face.edge_list_id
				var i := 0
				var face_verts : PackedVector3Array
				face_verts.resize(bsp_face.num_edges)
				var face_normals : PackedVector3Array
				face_normals.resize(bsp_face.num_edges)
				var face_normal := Vector3.UP
				if (bsp_face.plane_id < plane_normals.size()):
					face_normal = plane_normals[bsp_face.plane_id]
				else:
					print("Plane id out of bounds: ", bsp_face.plane_id)
				if (bsp_face.plane_side > 0):
					face_normal = -face_normal

				# Get the texture from the face
				var tex_info : BSPTextureInfo = textureinfos[bsp_face.texinfo_id]
				var texture : BSPTexture = textures[tex_info.texture_index]

				var vs := tex_info.vec_s
				var vt := tex_info.vec_t
				var s := tex_info.offset_s
				var t := tex_info.offset_t
				var tex_width : int = texture.width
				var tex_height : int = texture.height
				var tex_name : String = texture.name
				if (previous_tex_name != tex_name):
					previous_tex_name = tex_name
				#print("width: ", tex_width, " height: ", tex_height)
				var face_uvs : PackedVector2Array
				face_uvs.resize(bsp_face.num_edges)
				var tex_scale_x := 1.0 / (unit_scale * tex_width)
				var tex_scale_y := 1.0 / (unit_scale * tex_height)
				#print("normal: ", face_normal)
				var face_position := Vector3.ZERO
				for edge_list_index in range(edge_list_index_start, edge_list_index_start + bsp_face.num_edges):
					var vert_index_0 : int
					var reverse_order := false
					var edge_index := edge_list[edge_list_index]
					if (edge_index < 0):
						reverse_order = true
						edge_index = -edge_index
					
					if (reverse_order): # Not sure which way this should be flipped to get correct tangents
						vert_index_0 = edges[edge_index].vertex_index_1
					else:
						vert_index_0 = edges[edge_index].vertex_index_0
					var vert := verts[vert_index_0]
					#print("vert (%s): %d, " % ["r" if reverse_order else "f", vert_index_0], vert)
					face_verts[i] = vert
					face_normals[i] = face_normal
					face_uvs[i].x = vert.dot(vs) * tex_scale_x + s / tex_width
					face_uvs[i].y = vert.dot(vt) * tex_scale_y + t / tex_height
					#print("vert: ", vert, " vs: ", vs, " d: ", vert.dot(vs), " vt: ", vt, " d: ", vert.dot(vt))
					face_position += vert
					i += 1
				face_position /= i # Average all the verts
				var surf_tool : SurfaceTool
				if (texture.is_transparent):
					# Transparent meshes need to be sorted, so make each face its own mesh for now.
					surf_tool = SurfaceTool.new()
					surf_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
					surf_tool.set_material(texture.material)
				else:
					var grid_index
					if (separate_mesh_on_grid):
						grid_index = Vector3i(face_position / mesh_separation_grid_size)
					else:
						grid_index = 0
					
					var surface_tools : Dictionary = mesh_grid.get(grid_index, {})
					if (surface_tools.has(texture.name)):
						surf_tool = surface_tools[texture.name]
					else:
						surf_tool = SurfaceTool.new()
						surf_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
						surf_tool.set_material(texture.material)
						surface_tools[texture.name] = surf_tool
					mesh_grid[grid_index] = surface_tools
				surf_tool.add_triangle_fan(face_verts, face_uvs, [], [], face_normals)

				# Need to create unique meshes for each transparent surface so they sort properly.
				# These ignore the mesh grid.
				if (texture.is_transparent):
					var mesh_instance := MeshInstance3D.new()
					# Create a mesh out of all the surfaces
					surf_tool.generate_tangents()
					var array_mesh : ArrayMesh = null
					array_mesh = surf_tool.commit(array_mesh)
					mesh_instance.mesh = array_mesh
					mesh_instance.name = "TransparentMesh"
					parent_node.add_child(mesh_instance, true)
					mesh_instance.transform = parent_inv_transform
					mesh_instance.owner = root_node

			# Create meshes for each cell in the mesh grid.
			for grid_index in mesh_grid:
				var surface_tools = mesh_grid[grid_index] # Is there a way to loop through the keys instead?
				var mesh_instance := MeshInstance3D.new()
				var array_mesh : ArrayMesh = null
				var array_mesh_no_cull : ArrayMesh = null
				var has_nocull_materials := false
				for texture_name in surface_tools:
					var surf_tool : SurfaceTool = surface_tools[texture_name]
					surf_tool.generate_tangents()
					if (culling_textures_exclude.has(texture_name)):
						#array_mesh_no_cull = surf_tool.commit(array_mesh_no_cull)
						has_nocull_materials = true
						#print("Has no-cull materials")
					else:
						array_mesh = surf_tool.commit(array_mesh)

				if (array_mesh || has_nocull_materials):
					mesh_instance.name = "Mesh"
					parent_node.add_child(mesh_instance, true)
					mesh_instance.transform = parent_inv_transform
					mesh_instance.owner = root_node

					if (generate_occlusion_culling && array_mesh && is_worldspawn): # TOmaybeDO - optional flag on entities for like large doors or something to have occlusion culling?
						# Occlusion mesh data
						var vertices := PackedVector3Array()
						var indices := PackedInt32Array()
						# Build occlusion from all surfaces of the array mesh.
						for i in array_mesh.get_surface_count():
							var offset = vertices.size()
							var arrays := array_mesh.surface_get_arrays(i)
							vertices.append_array(arrays[ArrayMesh.ARRAY_VERTEX])
							if arrays[ArrayMesh.ARRAY_INDEX] == null:
								indices.append_array(range(offset, offset + arrays[ArrayMesh.ARRAY_VERTEX].size()))
							else:
								for index in arrays[ArrayMesh.ARRAY_INDEX]:
									indices.append(index + offset)
						# Create and add occluder and occluder instance.
						var occluder = ArrayOccluder3D.new()
						occluder.set_arrays(vertices, indices)
						var occluder_instance = OccluderInstance3D.new()
						occluder_instance.occluder = occluder
						occluder_instance.name = "Occluder"
						mesh_instance.add_child(occluder_instance, true)
						occluder_instance.owner = root_node

					var shadow_mesh : ArrayMesh = null
					if (generate_shadow_mesh):
						print("Generating shadow mesh...")
						# TODO: Merge verts.
						# Ideally create_shadow_mesh() from the engine could be exposed and placed on the ArrayMesh class.
						var vertices := PackedVector3Array()
						var indices := PackedInt32Array()
						for i in array_mesh.get_surface_count():
							var offset = vertices.size()
							var arrays := array_mesh.surface_get_arrays(i)
							vertices.append_array(arrays[ArrayMesh.ARRAY_VERTEX])
							if arrays[ArrayMesh.ARRAY_INDEX] == null:
								indices.append_array(range(offset, offset + arrays[ArrayMesh.ARRAY_VERTEX].size()))
							else:
								for index in arrays[ArrayMesh.ARRAY_INDEX]:
									indices.append(index + offset)
						if (indices.size() >= 3): # Make sure we have at least 1 face.
							shadow_mesh = ArrayMesh.new()
							var mesh_arrays := []
							mesh_arrays.resize(ArrayMesh.ARRAY_MAX)
							indices.resize(3) # TESTING
							mesh_arrays[ArrayMesh.ARRAY_VERTEX] = vertices
							mesh_arrays[ArrayMesh.ARRAY_INDEX] = indices
							shadow_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays, [], {}, ArrayMesh.ArrayFormat.ARRAY_FORMAT_VERTEX)

					# Add non-occluding materials to the mesh after we've generated occlusion
					if (has_nocull_materials):
						for texture_name in surface_tools:
							if (culling_textures_exclude.has(texture_name)):
								var surf_tool : SurfaceTool = surface_tools[texture_name]
								array_mesh = surf_tool.commit(array_mesh)

					array_mesh.shadow_mesh = shadow_mesh # This will be null if generate_shadow_mesh isn't set.
					mesh_instance.mesh = array_mesh
					#print("Shadow mesh: ", shadow_mesh.get_surface_count(), ", ", shadow_mesh.get_faces())
					if (shadow_mesh):
						print("Shadow mesh: ", shadow_mesh.get_surface_count())
					
					if (generate_lightmap_uv2):
						var err = mesh_instance.mesh.lightmap_unwrap(mesh_instance.global_transform, unit_scale * 4.0)
						#print("Lightmap unwrap result: ", err)

				if (use_triangle_collision):
					var collision_shape := CollisionShape3D.new()
					collision_shape.name = "CollisionShape"
					collision_shape.shape = mesh_instance.mesh.create_trimesh_shape()
					parent_node.add_child(collision_shape, true)
					mesh_instance.transform = parent_inv_transform
					collision_shape.owner = root_node
					# Apparently we have to let the gc handle this autamically now: file.close()
			if (use_bspx_brushes && !use_triangle_collision):
				var bspx_brushes := bspx_model_to_brush_map.get(model_index)
				if (bspx_brushes):
					#print("Number of brushes for model ", model_index, ": ", bspx_brushes.size())
					create_collision_from_brushes(parent_node, bspx_brushes, parent_inv_transform)
				else:
					printerr("Could not find bspx collision for ", model_index)
			elif (!use_triangle_collision): # Attempt to create collision out of BSP nodes
				# Clear these out, as we may be importing multiple models.
				array_of_planes_array = []
				array_of_planes = []
				if (0): # Clipnodes -- these are lossy and account for player size
					print("Node 0: ", bsp_model.node_id0, " Node 1: ", bsp_model.node_id1, " Node 2: ", bsp_model.node_id2, " Node 3: ", bsp_model.node_id3)
					file.seek(clipnodes_offset + bsp_model.node_id0 * CLIPNODES_STRUCT_SIZE) # Not sure which node I should be using here.  I think 0 is for rendering and 1 is point collision.
					#test_print_planes(file, planes_offset)
					read_clipnodes_recursive(file, clipnodes_offset)
				else:
					var seek_location := nodes_offset + bsp_model.node_id0 * (NODES_STRUCT_SIZE_Q1BSP if !is_bsp2 else NODES_STRUCT_SIZE_Q1BSP2)
					#print("Reading nodes: ", nodes_offset, " ", bsp_model.node_id0, " location: ", seek_location)
					file.seek(seek_location)
					read_nodes_recursive()
				#print("Array of planes array: ", array_of_planes_array)
				var model_mins := bsp_model.bound_min;
				var model_maxs := bsp_model.bound_max;
				#print("Model mins: ", model_mins, " Model maxs: ", model_maxs)
				#print("Origin: ", bsp_model.origin)
				var model_mins_maxs_planes : Array[Plane]
				model_mins_maxs_planes.push_back(Plane(Vector3.RIGHT, model_maxs.x))
				model_mins_maxs_planes.push_back(Plane(Vector3.UP, model_maxs.y))
				model_mins_maxs_planes.push_back(Plane(Vector3.BACK, model_maxs.z))
				model_mins_maxs_planes.push_back(Plane(Vector3.LEFT, -model_mins.x))
				model_mins_maxs_planes.push_back(Plane(Vector3.DOWN, -model_mins.y))
				model_mins_maxs_planes.push_back(Plane(Vector3.FORWARD, -model_mins.z))

				# Create collision shapes for world using BSP planes (we don't have brush data)
				create_collision_shapes(parent_node, array_of_planes_array, model_mins_maxs_planes, parent_inv_transform)

				# Create liquids (water, slime, lava)
				create_liquid_from_planes(parent_node, water_planes_array, model_mins_maxs_planes, parent_inv_transform, water_template)
				create_liquid_from_planes(parent_node, slime_planes_array, model_mins_maxs_planes, parent_inv_transform, slime_template)
				create_liquid_from_planes(parent_node, lava_planes_array, model_mins_maxs_planes, parent_inv_transform, lava_template)
	if (post_import_script_path):
		var post_import_node := Node.new()
		print("Loading post import script: ", post_import_script_path)
		var script = load(post_import_script_path)
		if (script && script is Script):
			post_import_node.set_script(script)
			if (post_import_node.has_method("post_import")):
				if (post_import_node.get_script().is_tool()):
					post_import_node.post_import(root_node)
				else:
					printerr("Post import script must have @tool set.")
			else:
				printerr("Post import script does not have post_import() function.")
		else:
			printerr("Invalid script path: ", post_import_script_path)
	#print("Post import nodes: ", post_import_nodes)
	for node in post_import_nodes:
		node.post_import(root_node)

	file.close()
	file = null
	print("BSP read complete.")
	return root_node


# Traverse tree and create liquid.
# Note: Not used if we have the brush data.
func create_liquid_from_planes(parent_node : Node3D, planes_array : Array, model_mins_maxs_planes : Array[Plane], parent_inv_transform : Transform3D, template : PackedScene):
	if (planes_array.size() > 0 && template):
		var liquid_body : Node = template.instantiate()
		parent_node.add_child(liquid_body, true)
		liquid_body.transform = parent_inv_transform
		liquid_body.owner = root_node
		create_collision_shapes(liquid_body, planes_array, model_mins_maxs_planes, Transform3D())


func parse_entity_string(entity_string : String) -> Array:
	var ent_dict := {}
	var ent_dict_array := []
	var in_key_string := false
	var in_value_string := false
	var key : StringName
	var value : String
	var parsed_key := false
	for char in entity_string:
		if (in_key_string):
			if (char == '"'):
				in_key_string = false
				parsed_key = true
			else:
				key += char
		elif (in_value_string):
			if (char == '"'):
				in_value_string = false
				ent_dict[key] = value
				key = ""
				value = ""
				parsed_key = false
			else:
				value += char
		elif (char == '"'):
			if (parsed_key):
				in_value_string = true
			else:
				in_key_string = true
		elif (char == '}'):
			ent_dict_array.push_back(ent_dict)
		elif (char == '{'):
			ent_dict = {}
			parsed_key = false
	return ent_dict_array

const WORLDSPAWN_STRING_NAME := &"worldspawn"
const LIGHT_STRING_NAME := &"light"
var post_import_nodes : Array[Node] = []


func convert_entity_dict_to_scene(ent_dict_array : Array):
	post_import_nodes = []
	for ent_dict in ent_dict_array:
		if (ent_dict.has("classname")):
			var classname : StringName = ent_dict["classname"].to_lower()
			var scene_path : String = ""
			if (entity_remap.has(classname)):
				scene_path = entity_remap[classname]
			else:
				if (classname != WORLDSPAWN_STRING_NAME):
					scene_path = entity_path_pattern.replace("{classname}", classname)
			
			if (!scene_path.is_empty() && ResourceLoader.exists(scene_path)):
				var scene_resource = load(scene_path)
				if (!scene_resource):
					print("Failed to load ", scene_path)
				else:
					var scene_node : Node = scene_resource.instantiate()
					if (!scene_node):
						print("Failed to instantiate scene: ", scene_path)
					else:
						if (scene_node.has_method("post_import")):
							post_import_nodes.append(scene_node)
						add_generic_entity(scene_node, ent_dict)

						# Imported script might need to know all values in the entity dictionary ahead of time, so optionally send that as well.
						if (scene_node.has_method("set_entity_dictionary")):
							if (!scene_node.get_script().is_tool()):
								printerr(scene_node.name + " has 'set_entity_dictionary()' function but must have @tool set to work for imports.")
							else:
								scene_node.set_entity_dictionary(ent_dict)

						# For every key/value pair in the entity, see if there's a corresponding
						# variable in the gdscript and set it.
						for key in ent_dict.keys():
							var string_value : String = ent_dict[key]
							var value = string_value
							if (key == "spawnflags"):
								value = value.to_int()

							# Allow scenes to have custom implementations of this so they can remap values or whatever
							# Returning true means it was handled.
							if (scene_node.has_method("set_import_value")):
								if (!scene_node.get_script().is_tool()):
									printerr(scene_node.name + " has 'set_import_value()' function but must have @tool set to work for imports.")
								else:
									if (scene_node.set_import_value(key, string_value)):
										continue

							var dest_value = scene_node.get(key) # Se if we can figure out the type of the destination value
							if (dest_value != null):
								var dest_type := typeof(dest_value)
								match (dest_type):
									TYPE_BOOL:
										value = convert_string_to_bool(string_value)
									TYPE_INT:
										value = string_value.to_int()
									TYPE_FLOAT:
										value = string_value.to_float()
									TYPE_STRING:
										value = string_value
									TYPE_STRING_NAME:
										value = string_value
									TYPE_VECTOR3:
										value = string_to_vector3(string_value)
									TYPE_COLOR:
										value = string_to_color(string_value)
									_:
										printerr("Key value type not handled for ", key, " : ", dest_type)
										value = string_value # Try setting it to the string value and hope for the best.
							scene_node.set(key, value)
			else: # No entity remap for this classname or no scene matching the entity path pattern
				if (classname == LIGHT_STRING_NAME):
					if (import_lights):
						add_light_entity(ent_dict)
				else:
					if (classname != WORLDSPAWN_STRING_NAME):
						if (!scene_path.is_empty()):
							if not ignore_missing_entities:
								printerr("Could not open ", scene_path, " for classname: ", classname)
						else:
							printerr("No entity remap found for ", classname, ".  Ignoring.")


func add_generic_entity(scene_node : Node, ent_dict : Dictionary):
	var origin := Vector3.ZERO
	if (ent_dict.has("origin")):
		var origin_string : String = ent_dict["origin"]
		origin = string_to_origin(origin_string, unit_scale)
	var offset : Vector3 = convert_vector_from_quake_scaled(entity_offsets_quake_units.get(ent_dict["classname"], Vector3.ZERO), unit_scale)
	origin += offset
	var mangle_string : String = ent_dict.get("mangle", "")
	var angle_string : String = ent_dict.get("angle", "")
	var angles_string : String = ent_dict.get("angles", "")
	var basis := Basis()
	if (angle_string.length() > 0):
		basis = angle_string_to_basis(angle_string)
	if (mangle_string.length() > 0):
		basis = mangle_string_to_basis(mangle_string)
	if (angles_string.length() > 0):
		basis = angles_string_to_basis(angles_string)
	var transform := Transform3D(basis, origin)
	root_node.add_child(scene_node, true)
	scene_node.transform = transform
	scene_node.owner = root_node
	if (ent_dict.has("model")):
		var model_value : String = ent_dict["model"]
		# Models that start with a * are contained with in the BSP file (ex: doors, triggers, etc)
		if (model_value[0] == '*'):
			model_scenes[model_value.substr(1).to_int()] = scene_node


const _COLOR_STRING_NAME := StringName("_color")
const COLOR_STRING_NAME := StringName("color")


func add_light_entity(ent_dict : Dictionary):
	var light_node := OmniLight3D.new()
	var light_value := 300.0
	var light_color := Color(1.0, 1.0, 1.0, 1.0)
	var color_string : String
	if (ent_dict.has(LIGHT_STRING_NAME)):
		light_value = ent_dict[LIGHT_STRING_NAME].to_float()
	if (ent_dict.has(_COLOR_STRING_NAME)):
		light_color = string_to_color(ent_dict[_COLOR_STRING_NAME])
	if (ent_dict.has(COLOR_STRING_NAME)):
		light_color = string_to_color(ent_dict[COLOR_STRING_NAME])
	light_node.omni_range = light_value * unit_scale
	light_node.light_energy = light_value * light_brightness_scale / 255.0
	light_node.light_color = light_color
	light_node.shadow_enabled = true # Might want to have an option to shut this off for some lights?
	add_generic_entity(light_node, ent_dict)


func string_to_color(color_string : String) -> Color:
	var color := Color(1.0, 1.0, 1.0, 1.0)
	var floats := color_string.split_floats(" ")
	var scale := 1.0
	# Sometimes color is in the 0-255 range, so if anything is above 1, divide by 255
	for f in floats:
		if f > 1.0:
			scale = 1.0 / 255.0
			break
	for i in min(3, floats.size()):
		color[i] = floats[i] * scale
	return color


static func string_to_origin(origin_string : String, scale: float) -> Vector3:
	var vec := string_to_vector3(origin_string)
	return convert_vector_from_quake_scaled(vec, scale)


static func string_to_vector3(vec_string : String) -> Vector3:
	var vec := Vector3.ZERO
	var split := vec_string.split(" ")
	var i := 0
	for pos in split:
		if (i < 3):
			vec[i] = pos.to_float()
		i += 1
	return vec


static func string_to_angles_pyr(angles_string : String, pitch_up_negative : bool) -> Vector3:
	var split := angles_string.split(" ")
	var angles := Vector3.ZERO
	var i := 0
	for pos in split:
		if (i < 3):
			angles[i] = deg_to_rad(pos.to_float())
		i += 1
	if (pitch_up_negative):
		angles[0] = -angles[0]
	return angles


static func angles_string_to_basis_pyr(angles_string : String, pitch_up_negative : bool) -> Basis:
	var angles := string_to_angles_pyr(angles_string, pitch_up_negative)
	return Basis.from_euler(angles)


static func mangle_string_to_basis(mangle_string : String) -> Basis:
	return angles_string_to_basis_pyr(mangle_string, true)


static func angle_string_to_basis(angle_string : String) -> Basis:
	# Special case for up and down:
	if (angle_string == "-1"): # Up, but Z is negative for forward, so we use DOWN
		return Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN)
	if (angle_string == "-2"): # Down, but Z is negative for forward, so we use UP
		return Basis(Vector3.RIGHT, Vector3.FORWARD, Vector3.UP)
	var angles := Vector3.ZERO
	angles[1] = deg_to_rad(angle_string.to_float())
	var basis := Basis.from_euler(angles)
	return basis


static func angles_string_to_basis(angles_string : String) -> Basis:
	# Sometimes this is the same as mangle, and sometimes it's yaw pitch roll, depending on the entity
	# Not sure 100% what the rules are, so just use mangle for now.
	return angles_string_to_basis_pyr(angles_string, true)


func create_collision_from_brushes(parent : Node3D, brushes : Array[BSPXBrush], parent_inv_transform : Transform3D):
	#print("create_collision_from_brushes\n")
	var water_body : Node3D
	var slime_body : Node3D
	var lava_body : Node3D
	var collision_index := 0
	#print("Total brushes: ", brushes.size())
	var brushes_added := 0
	for brush in brushes:
		collision_index += 1
		var aabb := AABB(brush.mins, Vector3.ZERO)
		aabb = aabb.expand(brush.maxs)
		var center := aabb.get_center()
		var body_to_add_to : Node3D = parent
		if (brush.contents == CONTENTS_SOLID):
			if (!SINGLE_STATIC_BODY):
				var static_body_child := StaticBody3D.new()
				static_body_child.name = "StaticBody%d" % collision_index
				#static_body_child.transform = collision_shape.transform
				#collision_shape.transform = Transform3D()
				parent.add_child(static_body_child, true)
				static_body_child.owner = root_node
				body_to_add_to = static_body_child
		elif (brush.contents == CONTENTS_WATER):
			if (!water_body):
				water_body = water_template.instantiate()
				parent.add_child(water_body)
				water_body.owner = root_node
			body_to_add_to = water_body
			print("water body ", water_body)
		elif (brush.contents == CONTENTS_SLIME):
			if (!slime_body):
				slime_body = slime_template.instantiate()
				parent.add_child(slime_body)
				slime_body.owner = root_node
			body_to_add_to = slime_body
		elif (brush.contents == CONTENTS_LAVA):
			if (!lava_body):
				lava_body = lava_template.instantiate()
				parent.add_child(lava_body)
				lava_body.owner = root_node
			body_to_add_to = lava_body
		else:
			print("Unknown brush contents: ", brush.contents)
		if (brush.planes.size() == 0): # If it's just an AABB, we can use a box.
			var collision_shape := CollisionShape3D.new()
			collision_shape.name = "CollisionBox%d" % collision_index
			var box := BoxShape3D.new()
			box.size = aabb.size
			collision_shape.position = center
			collision_shape.shape = box
			body_to_add_to.add_child(collision_shape)
			brushes_added += 1
			collision_shape.owner = root_node
			collision_shape.transform = parent_inv_transform * collision_shape.transform
		else: # Planes.  Can't do a simple box (Though maybe it could be a rotated box?)
			var planes := brush.planes
			planes.push_back(Plane(Vector3.RIGHT, brush.maxs.x))
			planes.push_back(Plane(Vector3.UP, brush.maxs.y))
			planes.push_back(Plane(Vector3.BACK, brush.maxs.z))
			planes.push_back(Plane(Vector3.LEFT, -brush.mins.x))
			planes.push_back(Plane(Vector3.DOWN, -brush.mins.y))
			planes.push_back(Plane(Vector3.FORWARD, -brush.mins.z))
			var convex_points := convert_planes_to_points(planes)
			if (convex_points.size() < 3):
				print("Convex shape creation failed ", collision_index)
			else:
				var collision_shape := CollisionShape3D.new()
				#print("Convex planes: ", convex_planes)
				collision_shape.name = "Collision%d" % collision_index
				collision_shape.shape = ConvexPolygonShape3D.new()
				for point_index in convex_points.size():
					convex_points[point_index] -= center
				collision_shape.shape.points = convex_points
				collision_shape.position = center
				collision_shape.transform = parent_inv_transform * collision_shape.transform
				#print("Convex points: ", convex_points)
				body_to_add_to.add_child(collision_shape)
				brushes_added += 1
				collision_shape.owner = root_node
	#print("Brushes added: ", brushes_added)

func create_collision_shapes(body : Node3D, planes_array, model_mins_maxs_planes, parent_inv_transform : Transform3D):
	#print("Create collision shapes.")
	for i in planes_array.size():
		var plane_indexes : PackedInt32Array = planes_array[i]
		var convex_planes : Array[Plane]
		#print("Planes index: ", i)
		convex_planes.append_array(model_mins_maxs_planes)
		for plane_index in plane_indexes:
			# sign of 0 is 0, so we offset the index by 1.
			var plane := Plane(plane_normals[abs(plane_index) - 1] * sign(plane_index), (plane_distances[abs(plane_index) - 1]) * sign(plane_index))
			convex_planes.push_back(plane)
			#print("Plane ", plane_index, ": ", plane)
		var convex_points := convert_planes_to_points(convex_planes)
		if (convex_points.size() < 3):
			print("Convex shape creation failed ", i)
		else:
			var collision_shape := CollisionShape3D.new()
			#print("Convex planes: ", convex_planes)
			collision_shape.name = "Collision%d" % i
			var center := Vector3.ZERO
			for point in convex_points:
				center += point
			center /= convex_points.size()
			if (TEST_BOX_ONLY_COLLISION):
				var aabb := AABB(convex_points[0], Vector3.ZERO)
				for point in convex_points:
					aabb = aabb.expand(point)
				var box_shape := BoxShape3D.new()
				box_shape.size = abs(aabb.size)
				collision_shape.shape = box_shape
			else:
				collision_shape.shape = ConvexPolygonShape3D.new()
				for point_index in convex_points.size():
					convex_points[point_index] -= center
				collision_shape.shape.points = convex_points
			collision_shape.position = center
			collision_shape.transform = parent_inv_transform * collision_shape.transform
			#print("Convex points: ", convex_points)
			if (SINGLE_STATIC_BODY):
				body.add_child(collision_shape)
			else:
				var static_body := StaticBody3D.new()
				static_body.name = "StaticBody%d" % i
				static_body.transform = collision_shape.transform
				collision_shape.transform = Transform3D()
				body.add_child(static_body, true)
				static_body.owner = root_node
				static_body.add_child(collision_shape)
			collision_shape.owner = root_node


func read_nodes_recursive():
	var plane_index := file.get_32()
	var child0 := unsigned16_to_signed(file.get_16()) if !is_bsp2 else unsigned32_to_signed(file.get_32())
	var child1 := unsigned16_to_signed(file.get_16()) if !is_bsp2 else unsigned32_to_signed(file.get_32())
	#print("plane: ", plane_index, " child0: ", child0, " child1: ", child1)
	# Hack upon hack -- store the plane index offset by 1, so we can negate the first index
	array_of_planes.push_back(-(plane_index + 1)) # Stupid nonsense where the front plane is negative.  Store the index as negative so we know to negate the plane later
	handle_node_child(child0)
	array_of_planes.resize(array_of_planes.size() - 1) # pop back
	array_of_planes.push_back(plane_index + 1)
	handle_node_child(child1)
	array_of_planes.resize(array_of_planes.size() - 1) # pop back


func handle_node_child(child_value : int):
	if (child_value < 0): # less than 0 means its a leaf.
		var leaf_id := ~child_value
		var file_offset := leaves_offset + leaf_id * (LEAF_SIZE_Q1BSP if !is_bsp2 else LEAF_SIZE_BSP2)
		#print("leaf_id: ", leaf_id, " file offset: ", file_offset)
		file.seek(file_offset)
		var leaf_type := unsigned32_to_signed(file.get_32())
		#print("leaf_type: ", leaf_type)
		match leaf_type:
			CONTENTS_SOLID:
				array_of_planes_array.push_back(array_of_planes.duplicate())
			CONTENTS_WATER:
				water_planes_array.push_back(array_of_planes.duplicate())
			CONTENTS_SLIME:
				slime_planes_array.push_back(array_of_planes.duplicate())
			CONTENTS_LAVA:
				lava_planes_array.push_back(array_of_planes.duplicate())
	else:
		file.seek(nodes_offset + child_value * (NODES_STRUCT_SIZE_Q1BSP if !is_bsp2 else NODES_STRUCT_SIZE_Q1BSP2))
		read_nodes_recursive()


func read_clipnodes_recursive(file : FileAccess, clipnodes_offset : int):
	var plane_index := file.get_32()
	var child0 := unsigned16_to_signed(file.get_16()) # Need to handle BSP2 if we ever use this
	var child1 := unsigned16_to_signed(file.get_16())
	print("plane: ", plane_index, " child0: ", child0, " child1: ", child1)
	array_of_planes.push_back(-plane_index) # Stupid nonsense where the front plane is negative.  Store the index as negative so we know to negate the plane later
	handle_clip_child(file, clipnodes_offset, child0)
	array_of_planes.resize(array_of_planes.size() - 1) # pop back
	array_of_planes.push_back(plane_index)
	handle_clip_child(file, clipnodes_offset, child1)
	array_of_planes.resize(array_of_planes.size() - 1) # pop back


func handle_clip_child(file : FileAccess, clipnodes_offset : int, child_value : int):
	if (child_value < 0): # less than 0 means its a leaf.
		if (child_value == CONTENTS_SOLID):
			array_of_planes_array.push_back(array_of_planes.duplicate())
	else:
		file.seek(clipnodes_offset + child_value * CLIPNODES_STRUCT_SIZE)
		read_clipnodes_recursive(file, clipnodes_offset)


func convert_planes_to_points(convex_planes : Array[Plane]) -> PackedVector3Array :
	# If you get errors about this, you're using a godot version that doesn't have this 
	# function exposed, yet.  Comment it out and uncomment the code below.
	return Geometry3D.compute_convex_mesh_points(convex_planes)
#	var clipper := BspClipper.new()
#	clipper.begin()
#	for plane in convex_planes:
#		clipper.clip_plane(plane)
#	clipper.filter_and_clean()
#
#	return clipper.vertices

func create_wad_table():
	var wad_path = texture_path_pattern.replace("{texture_name}.png",  "wad/")
	if not DirAccess.dir_exists_absolute(wad_path): DirAccess.make_dir_recursive_absolute(wad_path)
	var files_in_dir = DirAccess.get_files_at(wad_path)
	
	for file in files_in_dir:
		if file.get_extension() == "wad":
			var w : WADReader = load(wad_path + file).instantiate()
			wad_paths.append(w)
			prints("loading", w)

# BSPTexture is optional, for handling Q1 BSP files that have textures embedded.
func load_or_create_material(name : StringName, bsp_texture : BSPTexture = null) -> MaterialInfo:
	var width := 0
	var height := 0
	var material : Material = null
	if (bsp_texture):
		width = bsp_texture.width
		height = bsp_texture.height
	var material_path : String
	if (texture_material_rename.has(name)):
		material_path = texture_material_rename[name]
	else:
		material_path = material_path_pattern.replace("{texture_name}", name)
	var image_path : String
	var texture : Texture2D = null
	var texture_emission : Texture2D = null
	var need_to_save_image := false
	if (texture_path_remap.has(name)):
		image_path = texture_path_remap[name]
	else:
		image_path = texture_path_pattern.replace("{texture_name}", name)
	var original_image_path := image_path
	
	if (!ResourceLoader.exists(image_path)):
		image_path = str(image_path.get_basename(), ".jpg") # Jpeg fallback
	if (!ResourceLoader.exists(image_path)):
		image_path = str(image_path.get_basename(), ".tga") # tga fallback
	if (ResourceLoader.exists(image_path)):
		texture = load(image_path)
		if (texture):
			width = texture.get_width()
			height = texture.get_height()
			print(name, ": External image width: ", width, " height: ", height)
	elif (!ResourceLoader.exists(image_path) && !is_gsrc):
		print("Could not load ", original_image_path)
	
	# finally, check for if it is goldsrc to read the wad.
	# this code is pretty sucky wucky :-( probably better for memory management
	if (!ResourceLoader.exists(image_path) && is_gsrc):
		for wad in wad_paths:
			var n = name.to_lower()
			if wad.resources.has(n):
				var struct = wad.resources.get(n)
				texture = wad.load_texture(struct, texture_path_pattern.replace("{texture_name}", struct.get("name")), true)
	
	
	var image_emission_path : String
	image_emission_path = texture_emission_path_pattern.replace("{texture_name}", name)
	if (ResourceLoader.exists(image_emission_path)):
		texture_emission = load(image_emission_path)
	if (ResourceLoader.exists(material_path)):
		material = load(material_path)
	if (material && !overwrite_existing_materials):
		# Try to get the width and height off of the material.
		if (width == 0 || height == 0):
			print(name, ": Texture size is 0.  Attempting to get texture size from material.")
			if (material is BaseMaterial3D):
				print("Attempting to get image size from base material.")
				texture = material.albedo_texture
			elif (material is ShaderMaterial):
				var parameters_to_check : PackedStringArray = [ "albedo_texture", "texture_albedo", "texture", "albedo", "texture_diffuse" ]
				for param_name in parameters_to_check:
					# Might not exist/be a texture, so we need to test for htat.
					var test = material.get_shader_parameter(param_name)
					if (test is Texture2D):
						print("Got ", param_name, " from ShaderMaterial.")
						texture = test
						break
				if (!texture):
					print("No texture found in shader material with these parameters: ", parameters_to_check)
			if (texture):
				width = texture.get_width()
				height = texture.get_height()
				print("Material texture width: ", width, " height: ", height)
			else:
				print("No texture found in material.")
	else: # Need to create a material.
		print(name, ": Need to create a material.")
		var image : Image = null
		var image_emission : Image = null
		if (!texture || overwrite_existing_textures): # Try creating image from the texture in the BSP file.
			var palette : PackedByteArray = []
			var palette_file := FileAccess.open(texture_palette_path, FileAccess.READ)
			if (palette_file):
				palette = palette_file.get_buffer(256 * 3)
			else: # No palette, load default palette.
				print("Could not load palette file: ", texture_palette_path, ".  loading built-in palette.")
				palette = generate_default_palette()
			if (bsp_texture):
				if (bsp_texture.texture_data_offset > 0):
					print("Reading texture from bsp file at ", bsp_texture.texture_data_offset)
					file.seek(bsp_texture.texture_data_offset)
					var num_pixels := width * height
					var image_data : PackedByteArray = []
					var image_data_emission : PackedByteArray = []
					image_data.resize(num_pixels * 3)
					var has_emission := false
					var image_cursor := 0
					for pixel_index in num_pixels:
						var indexed_color := file.get_8()
						if (is_fullbright_index(indexed_color)):
							if (!has_emission):
								has_emission = true
								image_data_emission.resize(num_pixels * 3)
							# If it's fullbright, write the color to emission and black to albedo.
							image_data[image_cursor] = 0
							image_data_emission[image_cursor] = palette[indexed_color * 3 + 0] # Sir_Kane thought it was disguisting that I didn't have a + 0 here.
							image_cursor += 1
							image_data[image_cursor] = 0
							image_data_emission[image_cursor] = palette[indexed_color * 3 + 1]
							image_cursor += 1
							image_data[image_cursor] = 0
							image_data_emission[image_cursor] = palette[indexed_color * 3 + 2]
							image_cursor += 1
						else: # Not fullbright
							image_data[image_cursor] = palette[indexed_color * 3 + 0] # Sir_Kane thought it was disguisting that I didn't have a + 0 here.
							image_cursor += 1
							image_data[image_cursor] = palette[indexed_color * 3 + 1]
							image_cursor += 1
							image_data[image_cursor] = palette[indexed_color * 3 + 2]
							image_cursor += 1
					image = Image.create_from_data(width, height, false, Image.FORMAT_RGB8, image_data)
					image.generate_mipmaps()
					if (has_emission):
						image_emission = Image.create_from_data(width, height, false, Image.FORMAT_RGB8, image_data_emission)
						image_emission.generate_mipmaps()
					texture = ImageTexture.create_from_image(image)
					need_to_save_image = true
					#file.seek(bsp_texture.current_file_offset) # Go back to where we were, in case that matters for reading the next texture.
				else:
					print("No texture data in BSP file.")
		if (texture && generate_texture_materials):
			print("Creating material with texture.")
			material = StandardMaterial3D.new()
			material.albedo_texture = texture
			#print("albedo_texture set to ", material.albedo_texture)
			if (image_emission):
				texture_emission = ImageTexture.create_from_image(image_emission)
			#print("texture_emission = ", texture_emission)
			if (texture_emission):
				print("Emission enabled.")
				material.emission_enabled = true
				material.emission_texture = texture_emission
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			material.diffuse_mode = BaseMaterial3D.DIFFUSE_BURLEY
			material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
			if (name.begins_with(transparent_texture_prefix)):
				print("Transparency enabled.")
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			if (save_separate_materials): # Write materials
				print("Save separate materials.")
				# Write texture if it wasn't in the project.
				if (image && need_to_save_image):
					image_path = str(image_path.get_basename(), ".png") # Make sure images we write have png extension
					print("Writing image to ", image_path)
					# Create image directory if it doesn't exist
					var image_dir := image_path.get_base_dir()
					if (!DirAccess.dir_exists_absolute(image_dir)):
						DirAccess.make_dir_recursive_absolute(image_dir)
					var err := image.save_png(image_path)
					if (err != OK):
						printerr("Failed to write to ", image_path, " (", err, ")")
					else:
						material.albedo_texture.resource_path = image_path
					if (image_emission):
						image_emission_path = str(image_emission_path.get_basename(), ".png") # Make sure we use the png extenison.
						err = image_emission.save_png(image_emission_path)
						if (err == OK):
							material.emission_texture.resource_path = image_emission_path
						else:
							printerr("Failed to write to ", image_emission_path, " (", err, ")")

				# Create directory if it doesn't exist
				var material_dir := material_path.get_base_dir()
				print("Material dir: ", material_dir)
				if (!DirAccess.dir_exists_absolute(material_dir)):
					DirAccess.make_dir_recursive_absolute(material_dir)
				var err := ResourceSaver.save(material, material_path) # Note: If we do map loading from within the game, we don't want to save this.
				if (err == OK):
					print("Wrote material: ", material_path)
					material.take_over_path(material_path) # Not sure why setting resource_path here doesn't save a reference to the resource.
				else:
					printerr("Failed to write to ", material_path)
		else:
			if (material):
				print("Material with no texture image.")
			if (!material):
				print("No texture found.  Assigning random color.")
				material = StandardMaterial3D.new()
				material.albedo_color = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	var material_info := MaterialInfo.new()
	material_info.material = material
	material_info.width = width
	material_info.height = height
	return material_info

func is_fullbright_index(index : int) -> bool:
	if (fullbright_range.size() == 0):
		return false
	if (index >= fullbright_range[0]):
		if (fullbright_range.size() > 1):
			if (index <= fullbright_range[1]):
				return true
		else:
			return true
	return false


func lerp_palette_range(start_index : int, end_index : int, start_color : Color, end_color : Color):
	var total := end_index - start_index + 1
	var byte_index := start_index * 3
	for i in total:
		var fraction := float(i) / float(total)
		var color := start_color.lerp(end_color, fraction)
		default_palette[byte_index] = int(roundf(color.r * 255))
		byte_index += 1
		default_palette[byte_index] = int(roundf(color.g * 255))
		byte_index += 1
		default_palette[byte_index] = int(roundf(color.b * 255))
		byte_index += 1


func generate_default_palette():
	if (default_palette.size() == 0):
		default_palette.resize(256 * 3)
		for i in (256 * 3):
			default_palette[i] = ((i * 256) / (256 * 3))
		# Generate an approximation of the Quake palette.  Supposedly it's public domain, but just to be safe, I'm doing my own thing:
		var index := 0
		lerp_palette_range(0, 15, Color.BLACK, Color(0.92, 0.92, 0.92))
		lerp_palette_range(16, 31, Color(0.06, 0.04, 0.03), Color(0.56, 0.44, 0.14))
		lerp_palette_range(32, 47, Color(0.04, 0.04, 0.06), Color(0.55, 0.55, 0.8))
		lerp_palette_range(48, 63, Color.BLACK, Color(0.42, 0.42, 0.06))
		lerp_palette_range(64, 79, Color(0.03, 0.0, 0.0), Color(0.5, 0.0, 0.0)) # reds
		lerp_palette_range(80, 95, Color(0.07, 0.07, 0.0), Color(0.69, 0.40, 0.14)) # dark green to light brown
		lerp_palette_range(96, 103, Color(0.14, 0.07, 0.03), Color(0.5, 0.23, 0.17)) # brown to yellow 1 (gold)
		lerp_palette_range(104, 111, Color(0.56, 0.26, 0.20), Color(1.00, 1.00, 0.11)) # brown to yellow, 2 (gold)
		lerp_palette_range(112, 119, Color(0.04, 0.03, 0.00), Color(0.44, 0.29, 0.20)) # tan/flesh 1
		lerp_palette_range(120, 127, Color(0.50, 0.33, 0.25), Color(0.89, 0.70, 0.60)) # tan/flesh 2
		lerp_palette_range(128, 143, Color(0.67, 0.54, 0.64), Color(0.06, 0.03, 0.03))
		lerp_palette_range(144, 159, Color(0.73, 0.45, 0.62), Color(0.06, 0.03, 0.03))
		lerp_palette_range(160, 167, Color(0.86, 0.76, 0.73), Color(0.48, 0.39, 0.33)) # tan 1
		lerp_palette_range(168, 175, Color(0.42, 0.34, 0.29), Color(0.06, 0.04, 0.03)) # tan 2
		lerp_palette_range(176, 191, Color(0.44, 0.51, 0.48), Color(0.03, 0.04, 0.03))
		lerp_palette_range(192, 207, Color(1.00, 0.95, 0.11), Color(0.04, 0.03, 0.00))
		lerp_palette_range(208, 223, Color(0.00, 0.00, 1.00), Color(0.04, 0.04, 0.06)) # blue
		lerp_palette_range(224, 231, Color(0.17, 0.00, 0.00), Color(0.64, 0.15, 0.04)) # dark red to light orange/tan 1 (lava)
		lerp_palette_range(232, 239, Color(0.72, 0.20, 0.06), Color(0.97, 0.83, 0.55)) # dark red to light orange/tan 2
		lerp_palette_range(240, 243, Color(167.0/255, 123.0/255, 59.0/255), Color(231.0/255, 227.0/255, 87.0/255))
		lerp_palette_range(244, 249, Color(127.0/255, 191.0/255, 255.0/255), Color(215.0/255, 255.0/255, 255.0/255))
		lerp_palette_range(247, 251, Color(0.40, 0.00, 0.00), Color(1.0, 0.0, 0.0)) # bright red
		lerp_palette_range(252, 254, Color(255.0/255, 243.0/255, 147.0/255), Color.WHITE)
		default_palette[255*3+0] = 160
		default_palette[255*3+1] = 92
		default_palette[255*3+2] = 84
	return default_palette


# CSLR's Q2BSP importer code -- probably lots of redundant stuff here that should be merged into a common code path.

enum {LUMP_OFFSET, LUMP_LENGTH}
var geometry := {}
var textures := {}
var lightmap_texture : Image

var entities := []

var models := []


class BSPPlane:
	var normal := Vector3.ZERO
	var distance : float = 0
	var type : int = 0 # ? 

class BSPBrush:
	var first_brush_side : int = 0
	var num_brush_side : int = 0
	var flags : int = 0

class BSPBrushSide:
	var plane_index : int = 0
	var texture_information : int = 0



func convertBSPtoScene(file_path : String) -> Node:
	prints("Converting File", file_path, ". Please Keep in Mind Quake 2 Support is Still in Development and has some issues. file an issue on github if an issue occurs -cs")
	
	var file_name = file_path.get_base_dir()
	print(file_name)
	
	root_node = StaticBody3D.new()
	var MeshInstance = convert_to_mesh(file_path) 
	var CollisionShape = CollisionShape3D.new()
	
	var cnn = str("BSP_", file_path.get_basename().trim_prefix(file_path.get_base_dir())).replace("/", "")
	root_node.name = cnn
	
	root_node.add_child(MeshInstance)
	
	MeshInstance.owner = root_node
	
	var collisions = create_collisions()
	
	for collision in collisions:
		var cs = CollisionShape3D.new()
		root_node.add_child(cs)
		cs.owner = root_node
		cs.shape = collision
		cs.name = str('brush', RID(collision).get_id())
	
	root_node.set_collision_layer_value(2, true)
	root_node.set_collision_mask_value(2, true)
	
	
	return root_node

const Q2_TABLE = [
  "LUMP_ENTITIES",
  "LUMP_PLANE",
  "LUMP_VERTEX",
  "LUMP_VIS",
  "LUMP_NODE",
  "LUMP_TEXTURE",
  "LUMP_FACE",
  "LUMP_LIGHTMAP",
  "LUMP_LEAVES",
  "LUMP_LEAF_FACE_TABLE",
  "LUMP_LEAF_BRUSH_TABLE",
  "LUMP_EDGE",
  "LUMP_FACE_EDGE",
  "LUMP_MODEL",
  "LUMP_BRUSH",
  "LUMP_BRUSH_SIDE"
];

const Q3_TABLE = [
  "LUMP_ENTITIES",
  "LUMP_TEXTURE",
  "LUMP_PLANE", 
  "LUMP_NODES",
  "LUMP_LEAVES",
  "LUMP_LEAF_FACE_TABLE",
  "LUMP_LEAF_BRUSH_TABLE",
  "LUMP_MODEL",
  "LUMP_BRUSH",
  "LUMP_BRUSH_SIDE",
  "LUMP_VERTEX",
  "LUMP_MESH_VERTEX",
  "LUMP_EFFECT",
  "LUMP_FACE",
  "LUMP_LIGHTMAP",
  "LUMP_LIGHTVOL",
  "LUMP_VISDATA",
]

var QBSPi3 = false
var QBSPi2 = false

## Central Function
func convert_to_mesh(file, table : PackedStringArray = Q2_TABLE):
	var bsp_bytes : PackedByteArray = FileAccess.get_file_as_bytes(file)
	var bsp_version = str(convert_from_uint32(bsp_bytes.slice(4, 8)))
	var magic_num = bsp_bytes.slice(0, 4).get_string_from_utf8()
	QBSPi2 = bsp_version == "38"
	
	prints("QBSPi2 Found BSP Version %s %s" % [magic_num, bsp_version])

	if bsp_version == "46":
		print("Quake 3 Magic num detected, switching to QBSPi3. yeah theres 3 now.")
		QBSPi3 = true
		table = Q3_TABLE
		
		#return MeshInstance3D.new();
	
	
	var directory : Dictionary = fetch_directory(bsp_bytes)
	var lmp_table : Dictionary = {}
	
	
	for entry in table:
		var entry_key = table.find(entry)
		lmp_table[entry] = range(directory[entry_key].get(LUMP_OFFSET), directory[entry_key].get(LUMP_OFFSET)+directory[entry_key].get(LUMP_LENGTH))
	
	geometry = {}
	textures = {}
	
	var mi := MeshInstance3D.new()
	
	process_entity_lmp(bytes(bsp_bytes, lmp_table.LUMP_ENTITIES))
	
	
	if QBSPi3:
		textures["lumps"] = get_texture_lmp(bytes(bsp_bytes, lmp_table.LUMP_TEXTURE))
		geometry["vertex"] = get_verts(bytes(bsp_bytes, lmp_table.LUMP_VERTEX))
		geometry["mesh_vertex"] = get_mesh_verts(bytes(bsp_bytes, lmp_table.LUMP_MESH_VERTEX))
		
		OS.delay_msec(100) # some weird issue here, delaying seems to fix it
		geometry["face"] = get_face_lump(bytes(bsp_bytes, lmp_table.LUMP_FACE))
		
		lightmap_texture = get_lightmap_lump(bytes(bsp_bytes, lmp_table.LUMP_LIGHTMAP))
		geometry["plane"] = get_planes(bytes(bsp_bytes, lmp_table.LUMP_PLANE))
		
		geometry["brush_side"] = get_brush_sides(bytes(bsp_bytes, lmp_table.LUMP_BRUSH_SIDE))
		geometry["brush"] = get_brushes(bytes(bsp_bytes, lmp_table.LUMP_BRUSH))
		
	
	
	if QBSPi2:
		
		models = get_models(bytes(bsp_bytes, lmp_table.LUMP_MODEL))
		
		geometry["plane"] = get_planes(bytes(bsp_bytes, lmp_table.LUMP_PLANE))
		geometry["vertex"] = get_verts(bytes(bsp_bytes, lmp_table.LUMP_VERTEX))
		geometry["face"] = get_face_lump(bytes(bsp_bytes, lmp_table.LUMP_FACE))
		geometry["edge"] = get_edges(bytes(bsp_bytes, lmp_table.LUMP_EDGE))
		geometry["face_edge"] = get_face_edges(bytes(bsp_bytes, lmp_table.LUMP_FACE_EDGE))
		geometry["brush"] = get_brushes(bytes(bsp_bytes, lmp_table.LUMP_BRUSH))
		geometry["brush_side"] = get_brush_sides(bytes(bsp_bytes, lmp_table.LUMP_BRUSH_SIDE))
		textures["lumps"] = get_texture_lmp(bytes(bsp_bytes, lmp_table.LUMP_TEXTURE))
		
		process_to_mesh_array(geometry)
	
	var mesh := create_mesh(geometry["face"])
	var arm := ArrayMesh.new()
	
	for surface in mesh.get_surface_count():
		arm.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.surface_get_arrays(surface))
		arm.surface_set_material(surface, mesh.surface_get_material(surface))
	if (generate_lightmap_uv2):
		arm.lightmap_unwrap(mi.global_transform, unit_scale * 4.0)
	mi.mesh = arm
	
	return mi

func origin_to_vec(origin : String) -> Vector3:
	var v = Vector3.ZERO
	var pos = origin.split(" ")
	var vec = Vector3(pos[0].to_int(), pos[1].to_int(), pos[2].to_int())
	v = BSPReader.new().convert_vector_from_quake_unscaled(vec)
	return v


func get_lightmap_lump(data : PackedByteArray) -> Image:
	var texture : Image = Image.create(1, 1, false, Image.FORMAT_RGB8)
	if QBSPi3:
		var count = data.size() / 49152
		texture = Image.create(128 * count + 128, 128, false, Image.FORMAT_RGB8)
		print(count, texture.get_size())
		for i in range(0, count, 1):
			for x in range(0, 128):
				for y in range(0, 128):
					var index : int = i * 49152 + y * (128 * 3) + x * 3
					var r : int = data[index]
					var g : int = data[index + 1]
					var b : int = data[index + 2]
					#prints(r, g, b)
					
					texture.set_pixel(x + (i * 128), y, Color(r, g, b) / 255.0)
		#texture.save_png("user://lightmap_data.png")
		#output.append(ImageTexture.create_from_image(texture))
	return texture

## takes the vertex, face, edge and face edge arrays and outputs an array of all the edge points.
func process_to_mesh_array(geometry : Dictionary) -> void:
	var output_verts = []
	var face_vertex_indices = []
	
	var verts = geometry.get("vertex")
	var edges = geometry.get("edge")
	var face_edges = geometry.get("face_edge")
	
	for face_index in geometry.get("face"):
		var face = face_index as BSPFace
		var first_edge = face.edge_list_id
		var num_edges = face.num_edges
		
		var edge_range = range(first_edge, first_edge + num_edges)
		
		var face_vert_list = []
		var face_vert_out = []
		
		for edge in edge_range:
			
			var face_edge = face_edges[edge]
			
			edge = edges[abs(face_edge)]
			
			var edge0 = edge[0]
			var edge1 = edge[1]
			
			if face_edge > 0:
				edge0 = edge[0]
				edge1 = edge[1]
			
			if face_edge < 0:
				edge0 = edge[1]
				edge1 = edge[0]
			
			var vert0 = verts[edge0]
			var vert1 = verts[edge1]
			
			face_vert_list.append_array([vert0, vert1])
			
		
		for v in range(0, face_vert_list.size()-2):
			
			var vert0 = face_vert_list[0]
			var vert1 = face_vert_list[v + 1]
			var vert2 = face_vert_list[v + 2]
			
			face_vert_out.append(vert0)
			face_vert_out.append(vert1)
			face_vert_out.append(vert2)
		
		face.verts = face_vert_out

func process_entity_lmp(ent_bytes : PackedByteArray) -> void:
	prints("a unicode passing error may accur, this is 'normal'.")
	var entity_string : String = ent_bytes.get_string_from_utf8()
	var entity_output = parse_entity_string(entity_string)
	var parsed = convert_entity_dict_to_scene(entity_output)
	

## grabs the directory
func fetch_directory(bsp_bytes):
	prints("QBSPi2 BSP File Size:", bsp_bytes.size())
	var i = 0
	var dir = {}
	var dir_lump = bytes( bsp_bytes, range(8, ( 19 * 8 ) ))
	
	for lump in range(0, dir_lump.size()-8, 8):
		
		var offset = bytes(dir_lump, range(lump+0, lump+4)).decode_u32(0)
		var length = bytes(dir_lump, range(lump+4, lump+8)).decode_u32(0)
		
		dir[lump / 8] = {LUMP_OFFSET: offset, LUMP_LENGTH: length}
		
		
	return dir

func get_planes(plane_bytes : PackedByteArray) -> Array[BSPPlane]:
	var planes : Array[BSPPlane] = []
	 
	# basically 
	
	if QBSPi3:
		
		var count = plane_bytes.size() / 16
		print("QBSPi3 Calculated Estimate of %s Planes." % count)
		for index in range(0, plane_bytes.size(), 16):
			var norm_x = bytes(plane_bytes, range(index + 0, index + 4)).decode_float(0)
			var norm_y = bytes(plane_bytes, range(index + 4, index + 8)).decode_float(0)
			var norm_z = bytes(plane_bytes, range(index + 8, index + 12)).decode_float(0)
			
			var distance = bytes(plane_bytes, range(index + 12, index + 16)).decode_float(0)
			
			var plane = BSPPlane.new()
			plane.normal = convert_vector_from_quake_unscaled(Vector3(norm_x, norm_y, norm_z))
			plane.distance = distance
			
			planes.append(plane)
	
	if QBSPi2:
		var count = plane_bytes.size() / 20
		print("QBSPi2 Calculated Estimate of %s Planes." % count)
		for index in range(0, plane_bytes.size(), 20):
			var norm_x = bytes(plane_bytes, range(index + 0, index + 4)).decode_float(0)
			var norm_y = bytes(plane_bytes, range(index + 4, index + 8)).decode_float(0)
			var norm_z = bytes(plane_bytes, range(index + 8, index + 12)).decode_float(0)
			
			var distance = bytes(plane_bytes, range(index + 12, index + 16)).decode_float(0)
			
			var type = bytes(plane_bytes, range(index + 16, index + 20)).decode_u32(0)
			
			var plane = BSPPlane.new()
			plane.normal = convert_vector_from_quake_unscaled(Vector3(norm_x, norm_y, norm_z))
			plane.distance = distance
			plane.type = type
			planes.append(plane)
	return planes


func get_brushes(brush_bytes : PackedByteArray):
	var count = brush_bytes.size() / 12
	print("QBSPi2 Calculated Estimate of %s Brushes" % count)
	var brushes = []
	
	for index in range(0, brush_bytes.size(), 12):
		var brush = BSPBrush.new()
		var first_brush_side = bytes(brush_bytes, range(index + 0, index + 4)).decode_u32(0)
		var num_brush_side = bytes(brush_bytes, range(index + 4, index + 8)).decode_u32(0)
		var flags = bytes(brush_bytes, range(index + 8, index + 10)).decode_u16(0) 
		
		if QBSPi3:
			first_brush_side = bytes(brush_bytes, range(index + 0, index + 4)).decode_s32(0) # Quake 3 moved to s32 for everything by the looks of it, accounting for it here
			num_brush_side = bytes(brush_bytes, range(index + 4, index + 8)).decode_s32(0)
			flags = bytes(brush_bytes, range(index + 8, index + 12)).decode_s32(0) # seems to be responsible for texture path in quake 3.
			#prints("brush flags:", flags, textures["lumps"][flags].texture_path)
		
		
		brush.first_brush_side = first_brush_side
		brush.num_brush_side = num_brush_side
		brush.flags = flags
		
		
		brushes.append(brush)
	return brushes

func get_brush_sides(brush_side_bytes : PackedByteArray):
	var count = brush_side_bytes.size() / 4
	print("QBSPi2 Calculated Estimate of %s Brush Sides" % count)
	var brush_sides = []
	for index in range(0, brush_side_bytes.size(), 8 if QBSPi3 else 4):
		
		var plane_index = bytes(brush_side_bytes, range(index + 0, index + 2)).decode_u16(0)
		var texture_information = bytes(brush_side_bytes, range(index + 2, index + 4)).decode_s16(0)
		
		if QBSPi3:
			plane_index = bytes(brush_side_bytes, range(index + 0, index + 4)).decode_u32(0)
			texture_information = bytes(brush_side_bytes, range(index + 4, index + 8)).decode_s32(0)
			
		
		var brush_side = BSPBrushSide.new()
		
		brush_side.plane_index = plane_index
		brush_side.texture_information = texture_information
		
		brush_sides.append(brush_side)
	return brush_sides

func get_mesh_verts(vert_bytes : PackedByteArray) -> PackedInt64Array:
	var vertex_array : PackedInt64Array = []
	
	if QBSPi3:
		var count = vert_bytes.size() / 4
		for i in range(0, vert_bytes.size(), 4):
			var vert = bytes( vert_bytes, range(i, i + 4) ).decode_s32(0)
			vertex_array.append(vert)
	
	return vertex_array

## returns vertex lump
func get_verts(vert_bytes : PackedByteArray) -> PackedVector3Array:
	var vertex_array : PackedVector3Array = []
	#return vertex_array
	if QBSPi3:
		geometry["vertex_uv_q3"] = []
		geometry["vertex_uv2_q3"] = []
		geometry["normal"] = []
		geometry["color"] = []
		#return vertex_array
		var count = vert_bytes.size() / 44
		print("QBSPi3 Calculated Estimate of %s Vertices, THIS MAY TAKE A WHILE" % count)
		
		var v = 0
		
		while v < count:
			var index = (v * 44)
			var xbytes = bytes(vert_bytes, range( index + 0, index + 4 )).decode_float(0)
			var ybytes = bytes(vert_bytes, range( index + 4, index + 8 )).decode_float(0)
			var zbytes = bytes(vert_bytes, range( index + 8, index + 12 )).decode_float(0)
			var vertex_vec = convert_vector_from_quake_unscaled(Vector3(xbytes, ybytes, zbytes))
			
			var u1 = (bytes(vert_bytes, range( index + 12, index + 16 )).decode_float(0))
			var v1 = (bytes(vert_bytes, range( index + 16, index + 20 )).decode_float(0))
			var u2 = bytes(vert_bytes, range( index + 20, index + 24 )).decode_float(0)
			var v2 = bytes(vert_bytes, range( index + 24, index + 28 )).decode_float(0)
			
			var nx = bytes(vert_bytes, range( index + 28, index + 32 )).decode_float(0)
			var ny = bytes(vert_bytes, range( index + 32, index + 36)).decode_float(0)
			var nz = bytes(vert_bytes, range( index + 36, index + 40)).decode_float(0)
			var normal_vec = convert_vector_from_quake_unscaled(Vector3(xbytes, ybytes, zbytes))
			
			var CR = bytes(vert_bytes, range( index + 40, index + 41)).decode_u8(0)
			var CG = bytes(vert_bytes, range( index + 41, index + 42)).decode_u8(0)
			var CB = bytes(vert_bytes, range( index + 42, index + 43)).decode_u8(0)
			var CA = bytes(vert_bytes, range( index + 43, index + 44)).decode_u8(0)
			var color = Color(CR / 255.0, CG / 255.0, CB / 255.0, CA / 255.0)
			
			
			geometry["vertex_uv_q3"].append(Vector2(u1, v1))
			geometry["vertex_uv2_q3"].append(Vector2(u2, v2))
			geometry["color"].append(color)
			geometry["normal"].append(normal_vec)
			
			vertex_array.append(vertex_vec)
			
			v += 1
			
		prints("QBPSi3 Vert construction complete", vertex_array.size())
	
	
	if QBSPi2:
		var count = vert_bytes.size() / 12
		
		print("QBSPi2 Calculated Estimate of %s Vertices" % count)
		
		var v = 0
		while v < count:
			
			var xbytes = bytes(vert_bytes, range( (v * 12) + 0, (v * 12) + 4 )).decode_float(0)
			var ybytes = bytes(vert_bytes, range( (v * 12) + 4, (v * 12) + 8 )).decode_float(0)
			var zbytes = bytes(vert_bytes, range( (v * 12) + 8, (v * 12) + 12 )).decode_float(0)
			
			var vec = convert_vector_from_quake_unscaled(Vector3(xbytes, ybytes, zbytes))
			vertex_array.append(vec)
			v += 1
	return vertex_array

## returns face lump
func get_face_lump(lump_bytes : PackedByteArray):
	var faces : Array[BSPFace] = []
	#prints("geometry", geometry)
	
	if QBSPi3:
		var count = lump_bytes.size() / 104
		var f = 0
		while f < count:
			var new_face := BSPFace.new()
			var base_index = f * 104
			var by = bytes(lump_bytes, range(base_index, base_index + 104))
			
			var texture = by.decode_s32(0)
			var effect = by.decode_s32(4)
			var type = by.decode_s32(8)
			
			var first_vert = by.decode_s32(12)
			var num_verts = by.decode_s32(16)
			
			var first_mesh_vert = by.decode_s32(20)
			var num_mesh_verts = by.decode_s32(24)
			
			var lightmap_index = by.decode_s32(28)
			
			var lightmap_stx = by.decode_s32(32) 
			var lightmap_sty = by.decode_s32(36)
			
			var lightmap_six = by.decode_s32(40) 
			var lightmap_siy = by.decode_s32(44)
			
			var lightmap_start = Vector2(lightmap_stx, lightmap_sty)
			var lightmap_size = Vector2(lightmap_six, lightmap_siy)
			
			
			var vert_range = range(first_vert, first_vert + num_verts)
			var mesh_vert_range = range(first_mesh_vert, first_mesh_vert + num_mesh_verts)
			
			var fnx = by.decode_float(88)
			var fny = by.decode_float(92)
			var fnz = by.decode_float(96)
			var face_normal = convert_vector_from_quake_unscaled(Vector3(fnx, fny, fnz))
			
			var out_verts : PackedVector3Array = []
			var out_uv = []
			var out_uv2 = []
			var temp_uv = []
			var temp_uv2 = []
			var polygon_verts : PackedVector3Array = []
			var mesh_verts = []
			
			for j in mesh_vert_range:
				mesh_verts.append(geometry["mesh_vertex"][j])
			match type:
				1: # Polygon face
					for i in vert_range: 
						polygon_verts.append(geometry["vertex"][i])
						temp_uv.append(geometry["vertex_uv_q3"][i])
						temp_uv2.append(geometry["vertex_uv2_q3"][i])
					
					for v in mesh_verts: 
						out_verts.append(polygon_verts[v])
						out_uv.append(temp_uv[v])
						out_uv2.append(temp_uv2[v])
			
			new_face.lightmap = lightmap_index
			new_face.lightmap_start = lightmap_start
			new_face.lightmap_size = lightmap_size
			new_face.texinfo_id = texture
			new_face.verts = out_verts
			new_face.face_normal = face_normal
			new_face.q3_uv = out_uv
			new_face.q3_uv2 = out_uv
			faces.append(new_face)
			f += 1
	
	if QBSPi2: 
		var count = lump_bytes.size() / 20
		prints("QBSPi2 Calculated Estimate of %s Faces" % count)
		var f = 0
		
		
		while f < count:
			var new_face := BSPFace.new()
			var base_index = f * 20
			
			var by = bytes(lump_bytes, range(base_index, base_index + 20))
			
			new_face.plane_id     = by.decode_u16(0)
			new_face.plane_side   = by.decode_u16(2)
			new_face.edge_list_id = by.decode_u32(4)
			new_face.num_edges    = by.decode_u16(8)
			new_face.texinfo_id   = by.decode_u16(10)
			
			faces.append(new_face)
			f += 1
		
	return faces



## returns texture lump
func get_texture_lmp(tex_bytes : PackedByteArray) -> Array:
	
	var output = []
	
	if QBSPi3:
		var count = float(tex_bytes.size()) / 72.0
		prints("QBSPi2 Calculated Estimate of %s Texture References" % count)
		for b in range(0, tex_bytes.size(), 72):
			var BSPTI := BSPTextureInfo.new()
			var texture_name = bytes(tex_bytes, range(b, b + 64)).get_string_from_ascii()
			BSPTI.texture_path = texture_name
			BSPTI.flags = bytes(tex_bytes, range(b + 64, b + 68)).decode_s32(0)
			#V not integrated V
			#BSPTI.contents = bytes(tex_bytes, range(b + 68, b + 72)).decode_s32(0)
			#^ not integrated ^
			
			output.append(BSPTI)
		
	if QBSPi2:
		var count = tex_bytes.size() / 76
		prints("QBSPi2 Calculated Estimate of %s Texture References" % count)
		
		
		for b in range(0, tex_bytes.size(), 76):
			var BSPTI := BSPTextureInfo.new()
			
			var ux = bytes(tex_bytes, range(b, b + 4)).decode_float(0)
			var uy = bytes(tex_bytes, range(b + 4, b + 8)).decode_float(0)
			var uz = bytes(tex_bytes, range(b + 8, b + 12)).decode_float(0)
			
			var uoffset = bytes(tex_bytes, range(b + 12, b + 16)).decode_float(0)
			
			var vx = bytes(tex_bytes, range(b + 16, b + 20)).decode_float(0)
			var vy = bytes(tex_bytes, range(b + 20, b + 24)).decode_float(0)
			var vz = bytes(tex_bytes, range(b + 24, b + 28)).decode_float(0)
			
			var voffset = bytes(tex_bytes, range(b + 28, b + 32)).decode_float(0)
			
			var flags = bytes(tex_bytes, range(b + 32, b + 36)).decode_u32(0)
			var value = bytes(tex_bytes, range(b + 36, b + 40)).decode_u32(0)
			
			var texture_path = bytes(tex_bytes, range(b + 40, b + 72)).get_string_from_utf8()
			
			var next_texinfo = bytes(tex_bytes, range(b + 72, b + 76)).decode_s32(0)
			
			BSPTI.vec_s = convert_vector_from_quake_unscaled(Vector3(ux, uy, uz))
			BSPTI.offset_s = uoffset
			BSPTI.vec_t = convert_vector_from_quake_unscaled(Vector3(vx, vy, vz))
			BSPTI.offset_t = voffset
			BSPTI.flags = flags
			BSPTI.value = value
			BSPTI.texture_path = texture_path
			
			output.append(BSPTI)
			
		
	return output

## returns edge lump
func get_edges(edge_bytes : PackedByteArray):
	var count = edge_bytes.size() / 4
	var e = 0
	var edges = []
	while e < count:
		var index = e * 4
		var edge_1 = bytes(edge_bytes, range(index + 0, index + 2)).decode_u16(0)
		var edge_2 = bytes(edge_bytes, range(index + 2, index + 4)).decode_u16(0)
		
		
		edges.append([edge_1, edge_2])
		e += 1
	
	return edges

## returns face edge lump
func get_face_edges(face_bytes : PackedByteArray):
	var count = face_bytes.size() / 4
	prints("QBSPi2 Calculated Estimate of %s Face Edges" % count)
	var f = 0
	var face_edges = []
	while f < count:
		var index = f * 4 
		var f1 = bytes(face_bytes, range(index + 0, index + 4)).decode_s32(0)
		face_edges.append(f1)
		f += 1
	
	return face_edges
## i dont know what models are used for but if someone could tell me that would be good.
func get_models(model_bytes : PackedByteArray):
	var count = model_bytes.size() / 48 
	prints("QBSPi2 Calculated Estimate of %s Models" % count)
	
	for m in range(0, model_bytes.size(), 48):
		var a1 = bytes(model_bytes, range(m + 0, m + 4)).decode_float(0)
		var a2 = bytes(model_bytes, range(m + 4, m + 8)).decode_float(0)
		var b1 = bytes(model_bytes, range(m + 8, m + 12)).decode_float(0)
		var b2 = bytes(model_bytes, range(m + 12, m + 16)).decode_float(0)
		var c1 = bytes(model_bytes, range(m + 16, m + 20)).decode_float(0)
		var c2 = bytes(model_bytes, range(m + 20, m + 24)).decode_float(0)
		
		var ox = bytes(model_bytes, range(m + 24, m + 28)).decode_float(0)
		var oy = bytes(model_bytes, range(m + 28, m + 32)).decode_float(0)
		var oz = bytes(model_bytes, range(m + 32, m + 36)).decode_float(0)
		
		var head = bytes(model_bytes, range(m + 36, m + 40)).decode_s32(0)
		
		var first_face = bytes(model_bytes, range(m + 40, m + 44)).decode_u32(0)
		var num_faces = bytes(model_bytes, range(m + 44, m + 48)).decode_u32(0)
		
	return []

func create_collisions():
	var collisions = []
	var final_verts = []
	if geometry.has("brush"):
		for brush in geometry["brush"]:
			var brush_planes : Array[Plane] = []
			brush = brush as BSPBrush
			var brush_side_range = range(brush.first_brush_side, (brush.first_brush_side + brush.num_brush_side))
			var q3_compliant : bool = false
			
			if QBSPi3:
				var file_name = str(textures.lumps[brush.flags].texture_path).get_file()
				q3_compliant = !ignored_flags.has(brush.flags)
				
			
			if (QBSPi2 && brush.flags == 1) or q3_compliant:
				for brush_side_index in brush_side_range:
					var brush_side = geometry["brush_side"][brush_side_index]
					var plane = geometry["plane"][brush_side.plane_index] as BSPPlane
					
					var plane_vec = Plane(plane.normal, plane.distance * unit_scale)
					
					brush_planes.append(plane_vec)
				
				var verts = Geometry3D.compute_convex_mesh_points(brush_planes)
				var collision = ConvexPolygonShape3D.new()
				
				collision.set_points(verts)
				collisions.append(collision)
	
	return collisions

func convert_face_uv2_for_lightmap(lightmap_index : int, lm_start : Vector2i, lm_size : Vector2i, lightmap_uv : Vector2) -> Vector2:
	var atlas_size = Vector2(lightmap_texture.get_size()) # Size of the entire atlas
	var lightmap_offset_in_atlas = Vector2i(lightmap_index * 128, 0)
	var absolute_lm_start = Vector2(lightmap_offset_in_atlas) + Vector2(lm_start) 
	var uv_offset_in_lightmap = Vector2(lightmap_uv) * Vector2(lm_size)
	var absolute_uv = Vector2(absolute_lm_start) + Vector2(uv_offset_in_lightmap)
	var normalized_uv = Vector2(absolute_uv) / Vector2(atlas_size)
	return normalized_uv


func create_mesh(face_data : Array[BSPFace]) -> Mesh:
	var mesh = ArrayMesh.new()
	var texture_list = textures["lumps"] if textures.has("lumps") else []
	var surface_list := {}
	var material_info_lookup := {}
	var missing_textures := []
	var mesh_arrays := []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	
	# seperating them for reasons
	if QBSPi3:
		for texture in texture_list:
			texture = texture as BSPTextureInfo
			
			if not surface_list.has(texture.texture_path):
				var st =  SurfaceTool.new()
				#prints("creating new tool for", texture.texture_path)
				surface_list[texture.texture_path] = st
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		for face in face_data:
			var texture : BSPTextureInfo = texture_list[face.texinfo_id]
			var ignore_surface := ignored_flags.has(texture.flags) # Can probably get rid of this once all the normal skipping flags are added
			if (texture.flags & (SURFACE_FLAG_NODRAW | SURFACE_FLAG_HINT | SURFACE_FLAG_SKIP)):
				ignore_surface = true
			if (!include_sky_surfaces && (texture.flags & SURFACE_FLAG_SKY)):
				ignore_surface = true
			if surface_list.has(texture.texture_path) and !ignore_surface:
				var surface_tool : SurfaceTool = surface_list.get(texture.texture_path)
				var material_info : MaterialInfo = material_info_lookup.get(surface_tool, null)
				if (!material_info):
					material_info = load_or_create_material(texture.texture_path)
					material_info_lookup[surface_tool] = material_info
				var material : StandardMaterial3D = material_info.material
				var width := material_info.width
				var height := material_info.height
				var verts = face.verts
				
				var tex_size_vec = Vector2(material_info.width, material_info.height)
				for vertIndex in range(0, verts.size(), 3):
					var v0 = verts[vertIndex + 0]
					var v1 = verts[vertIndex + 1]
					var v2 = verts[vertIndex + 2] 
					
					var uv0 : Vector2 = face.q3_uv[vertIndex + 0]
					var uv1 : Vector2 = face.q3_uv[vertIndex + 1]
					var uv2 : Vector2 = face.q3_uv[vertIndex + 2]
					
					var lm_uv0 = convert_face_uv2_for_lightmap(face.lightmap, face.lightmap_start, face.lightmap_size, face.q3_uv2[vertIndex + 0])
					var lm_uv1 = convert_face_uv2_for_lightmap(face.lightmap, face.lightmap_start, face.lightmap_size, face.q3_uv2[vertIndex + 1])
					var lm_uv2 = convert_face_uv2_for_lightmap(face.lightmap, face.lightmap_start, face.lightmap_size, face.q3_uv2[vertIndex + 2])
					
					surface_tool.set_material(material)
					surface_tool.set_normal(face.face_normal)
					surface_tool.set_uv(uv0)
					surface_tool.set_uv2(lm_uv0)
					surface_tool.add_vertex(v0 * unit_scale)
					surface_tool.set_uv(uv1)
					surface_tool.set_uv2(lm_uv1)
					surface_tool.add_vertex(v1 * unit_scale)
					surface_tool.set_uv(uv2)
					surface_tool.set_uv2(lm_uv2)
					surface_tool.add_vertex(v2 * unit_scale)
				
	if QBSPi2:
		for texture in texture_list:
			texture = texture as BSPTextureInfo
			
			if not surface_list.has(texture.texture_path):
				var st =  SurfaceTool.new()
				surface_list[texture.texture_path] = st
				st.begin(Mesh.PRIMITIVE_TRIANGLES)

		for face in face_data:
			var texture : BSPTextureInfo = texture_list[face.texinfo_id]
			
			if surface_list.has(texture.texture_path):
				var surface_tool : SurfaceTool = surface_list.get(texture.texture_path)
				var material_info : MaterialInfo = material_info_lookup.get(surface_tool, null)
				if (!material_info):
					material_info = load_or_create_material(texture.texture_path)
					material_info_lookup[surface_tool] = material_info
				var material := material_info.material
				var width := material_info.width
				var height := material_info.height
				var verts : PackedVector3Array = face.verts
				var ignore_surface := ignored_flags.has(texture.flags) # Can probably get rid of this once all the normal skipping flags are added
				if (texture.flags & (SURFACE_FLAG_NODRAW | SURFACE_FLAG_HINT | SURFACE_FLAG_SKIP)):
					ignore_surface = true
				if (!include_sky_surfaces && (texture.flags & SURFACE_FLAG_SKY)):
					ignore_surface = true
				if (!ignore_surface):
					for vertIndex in range(0, verts.size(), 3):
						var v0 = verts[vertIndex + 0]
						var v1 = verts[vertIndex + 1]
						var v2 = verts[vertIndex + 2]
						
						var uv0 = get_uv_q(v0, texture, width, height)
						var uv1 = get_uv_q(v1, texture, width, height)
						var uv2 = get_uv_q(v2, texture, width, height)
						
						#var plane = geometry["plane"][face.plane_id] as BSPPlane
						var normal : Vector3 = (v1 - v0).cross((v0 - v2))#FIXME: planes dont work for quake 2 for some reason, vector calculated by cross product 
						#var normal : Vector3 = plane.normal
						
						surface_tool.set_material(material)
						surface_tool.set_normal(normal.normalized())
						surface_tool.set_uv(uv0)
						surface_tool.add_vertex(v0 * unit_scale)
						surface_tool.set_uv(uv1)
						surface_tool.add_vertex(v1 * unit_scale)
						surface_tool.set_uv(uv2)
						surface_tool.add_vertex(v2 * unit_scale)

	for tool in surface_list.values():
		tool = tool as SurfaceTool
		mesh = tool.commit(mesh) as ArrayMesh
	prints("\n\n\n QBSPi2 - Completed Mesh With %s Surfaces" % mesh.get_surface_count())
	if missing_textures.size() > 0: prints(".\nMissing Textures:", missing_textures, "Some Faces may be invisible, Trust me they're there the surface albedo is just 0!")
	return mesh


func get_uv_q(vertex : Vector3, tex_info : BSPTextureInfo, width : float, height : float) -> Vector2:
	var u := (vertex.dot(tex_info.vec_s) + tex_info.offset_s) / width
	var v := (vertex.dot(tex_info.vec_t) + tex_info.offset_t) / height
	return Vector2(u, v)


## converts 2 bytes to a unsigned int16
func convert_from_uint16(uint16):
	var uint16_value = uint16.decode_u16(0)
	if uint16.size() < 4: return 0
	return uint16_value


## converts 4 bytes to a unsigned int32
func convert_from_uint32(uint32 : PackedByteArray):
	var uint32_value = uint32.decode_u32(0)
	if uint32.size() < 4: return 0
	return uint32_value


## Non-zero values are true, as do "t" and "y" for "true" and "yes".
static func convert_string_to_bool(string : String) -> bool:
	if (string.length() == 0):
		return false
	if (string.to_int() != 0):
		return true
	var first_character := string[0].to_lower()
	if (first_character == 't' || first_character == 'y'):
		return true
	return false


## returns bytes, indices should be an array e.g. [1, 2, 3, 4]
# TODO: Unoptimal, use slice() directly instead.
func bytes(input_array : PackedByteArray, indices : Array) -> PackedByteArray:
	if (indices.size() > 0):
		return input_array.slice(indices[0], indices[indices.size() - 1] + 1)
	else:
		return []
