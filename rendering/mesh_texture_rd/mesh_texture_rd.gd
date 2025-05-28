@tool
extends Texture2D
class_name MeshTextureRD

var rd := RenderingServer.get_rendering_device()

var framebuffer_texture_rid := RID()
var framebuffer_rid := RID()
var vertex_array_rid := RID()
var index_array_rid := RID()
var shader_rid := RID()
var pipeline_rid := RID()
var sampler_rid := RID()
var uniform_set_rid := RID()
var index_buffer_rid := RID()
var vertex_buffer_pos_rid := RID()
var vertex_buffer_uv_rid := RID()
var texture_rd := RenderingServer.texture_2d_placeholder_create()

var uniform_tex: RDUniform = RDUniform.new()
var vertex_attrs: Array[RDVertexAttribute]
var vertex_format: int

var shader_dirty := false
var pipeline_dirty := false
var mesh_dirty := false
var uniform_set_dirty := false
var is_2d_mesh := false

@export var size := Vector2i(256, 256):
	get: return size
	set(value):
		size = value
		_queue_update_pipeline()

@export var clear_color := Color.TRANSPARENT:
	get: return clear_color
	set(value):
		clear_color = value
		_queue_update()

@export var mesh: Mesh:
	get: return mesh
	set(value):
		if mesh != null: mesh.changed.disconnect(_queue_update_mesh)
		mesh = value
		_queue_update_mesh()
		if mesh != null: mesh.changed.connect(_queue_update_mesh)

@export var base_texture: Texture2D:
	get: return base_texture
	set(value):
		if (base_texture != null): base_texture.changed.disconnect(_queue_update_uniform_set)
		base_texture = value
		_queue_update_uniform_set()
		if (base_texture != null): base_texture.changed.connect(_queue_update_uniform_set)


@export var projection: Projection = Projection.IDENTITY:
	get: return projection
	set(value):
		projection = value
		_queue_update()

@export var glsl_file: RDShaderFile = preload("res://base_texture.glsl"):
	get: return glsl_file
	set(value):
		if (glsl_file != null): glsl_file.changed.disconnect(_queue_update_shader)
		glsl_file = value
		_queue_update_shader()
		if (glsl_file != null): glsl_file.changed.connect(_queue_update_shader)

var _update_queued := false

func _init() -> void:
	sampler_rid = rd.sampler_create(RDSamplerState.new())

	uniform_tex.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	uniform_tex.binding = 0

	var pos := RDVertexAttribute.new()
	pos.format = RenderingDevice.DATA_FORMAT_R32G32B32_SFLOAT
	pos.location = 0
	pos.stride = 4 * 3
	var uv := RDVertexAttribute.new()
	uv.format = RenderingDevice.DATA_FORMAT_R32G32_SFLOAT
	uv.location = 1
	uv.stride = 4 * 2
	vertex_attrs.clear()
	vertex_attrs.append_array([pos, uv])
	vertex_format = rd.vertex_format_create(vertex_attrs)
	if glsl_file and not glsl_file.changed.is_connected(_queue_update_shader):
		glsl_file.changed.connect(_queue_update_shader)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if framebuffer_texture_rid.is_valid(): rd.free_rid(framebuffer_texture_rid)
		if shader_rid.is_valid(): rd.free_rid(shader_rid)
		if sampler_rid.is_valid(): rd.free_rid(sampler_rid)
		if index_buffer_rid.is_valid(): rd.free_rid(index_buffer_rid)
		if vertex_buffer_pos_rid.is_valid(): rd.free_rid(vertex_buffer_pos_rid)
		if vertex_buffer_uv_rid.is_valid(): rd.free_rid(vertex_buffer_uv_rid)
		RenderingServer.free_rid(texture_rd)

func update(force: bool = false) -> void:
	if force:
		shader_dirty = true
		pipeline_dirty = true
		mesh_dirty = true
		uniform_set_dirty = true

	if shader_dirty:
		_reset_shader()
		_reset_pipeline()
		_reset_uniform()
		shader_dirty = false
	if pipeline_dirty:
		_reset_pipeline()
		pipeline_dirty = false
	if uniform_set_dirty:
		_reset_uniform()
		uniform_set_dirty = false
	if mesh_dirty:
		_reset_vertex()
		mesh_dirty = false

	_draw_list()
	emit_changed()
	_update_queued = false

func _queue_update() -> void:
	if _update_queued:
		return
	_update_queued = true
	update.call_deferred()

func _queue_update_shader() -> void:
	shader_dirty = true
	_queue_update()

func _queue_update_pipeline() -> void:
	pipeline_dirty = true
	_queue_update()


func _queue_update_uniform_set() -> void:
	uniform_set_dirty = true
	_queue_update()


func _queue_update_mesh() -> void:
	mesh_dirty = true
	_queue_update()


func _reset_vertex() -> void:
	if mesh == null or mesh.get_surface_count() == 0:
		return
	var surface_array := mesh.surface_get_arrays(0)
	var vertex_array: Variant = surface_array[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = surface_array[Mesh.ARRAY_INDEX]
	var uv_array: PackedVector2Array = surface_array[Mesh.ARRAY_TEX_UV]
	is_2d_mesh = false
	if vertex_array is PackedVector2Array:
		is_2d_mesh = true
		var vertex_array_vec3 := PackedVector3Array()
		vertex_array_vec3.resize(len(vertex_array))
		for i in range(len(vertex_array)):
			var v: Vector2 = vertex_array[i]
			# 2D Mesh needs to be downscaled to be visible in normal projection.
			vertex_array_vec3[i] = Vector3(v.x, v.y, 0) / 100
		vertex_array = vertex_array_vec3

	var points_bytes: PackedByteArray = vertex_array.to_byte_array()

	if indices.size() > 0:
		var indices_bytes := indices.to_byte_array()

		if index_buffer_rid.is_valid(): rd.free_rid(index_buffer_rid)
		index_buffer_rid = rd.index_buffer_create(indices.size(), RenderingDevice.INDEX_BUFFER_FORMAT_UINT32, indices_bytes)

		index_array_rid = rd.index_array_create(index_buffer_rid, 0, indices.size())

	var uv_bytes := uv_array.to_byte_array()

	if vertex_buffer_pos_rid.is_valid(): rd.free_rid(vertex_buffer_pos_rid)
	if vertex_buffer_uv_rid.is_valid(): rd.free_rid(vertex_buffer_uv_rid)
	vertex_buffer_pos_rid = rd.vertex_buffer_create(points_bytes.size(), points_bytes)
	vertex_buffer_uv_rid = rd.vertex_buffer_create(uv_bytes.size(), uv_bytes)

	var vertex_buffers := [vertex_buffer_pos_rid, vertex_buffer_uv_rid]

	vertex_array_rid = rd.vertex_array_create(int(float(points_bytes.size()) / 4 / 3), vertex_format, vertex_buffers)

func _reset_shader() -> void:
	var shader_spirv := glsl_file.get_spirv()
	if shader_rid.is_valid():
		rd.free_rid(shader_rid)
		pipeline_rid = RID()
		uniform_set_rid = RID()
	shader_rid = rd.shader_create_from_spirv(shader_spirv)

func _reset_pipeline() -> void:
	if glsl_file == null:
		return
	var tex_format := RDTextureFormat.new()
	var tex_view := RDTextureView.new()
	tex_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tex_format.width = size.x
	tex_format.height = size.y
	tex_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tex_format.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT

	var tex_rid := rd.texture_create(tex_format, tex_view)
	RenderingServer.texture_replace(texture_rd, RenderingServer.texture_rd_create(tex_rid) if tex_rid.is_valid() else RenderingServer.texture_2d_placeholder_create())
	if framebuffer_texture_rid.is_valid():
		rd.free_rid(framebuffer_texture_rid)
	framebuffer_texture_rid = tex_rid

	var blend := RDPipelineColorBlendState.new()
	blend.attachments.append(RDPipelineColorBlendStateAttachment.new())

	framebuffer_rid = rd.framebuffer_create([framebuffer_texture_rid])

	var rs := RDPipelineRasterizationState.new()
	rs.front_face = RenderingDevice.POLYGON_FRONT_FACE_COUNTER_CLOCKWISE
	rs.cull_mode = RenderingDevice.POLYGON_CULL_BACK if not is_2d_mesh else RenderingDevice.POLYGON_CULL_DISABLED

	pipeline_rid = rd.render_pipeline_create(
				   shader_rid,
				   rd.framebuffer_get_format(framebuffer_rid),
				   vertex_format,
				   RenderingDevice.RENDER_PRIMITIVE_TRIANGLES,
				   rs,
				   RDPipelineMultisampleState.new(),
				   RDPipelineDepthStencilState.new(),
				   blend
			   )

func _reset_uniform() -> void:
	if not sampler_rid.is_valid() or base_texture == null or not base_texture.get_rid().is_valid() or not shader_rid.is_valid():
		return

	uniform_tex.clear_ids()
	uniform_tex.add_id(sampler_rid)
	uniform_tex.add_id(RenderingServer.texture_get_rd_texture(base_texture.get_rid()))

	uniform_set_rid = UniformSetCacheRD.get_cache(shader_rid, 0, [uniform_tex])

func _draw_list() -> void:
	if not rd.render_pipeline_is_valid(pipeline_rid):
		print("draw failed, invalid pipeline")
		return
	elif not rd.framebuffer_is_valid(framebuffer_rid):
		print("draw failed, invalid framebuffer")
		return
	elif not rd.uniform_set_is_valid(uniform_set_rid):
		print("draw failed, invalid uniform set")
		return
	elif not vertex_array_rid.is_valid():
		print("draw failed, invalid vertex")
		return

	var xform_array: PackedFloat32Array = [
		projection[0][0], projection[0][1], projection[0][2], projection[0][3],
		projection[1][0], projection[1][1], projection[1][2], projection[1][3],
		projection[2][0], projection[2][1], projection[2][2], projection[2][3],
		projection[3][0], projection[3][1], projection[3][2], projection[3][3]
	]
	var xform_bytes := xform_array.to_byte_array()

	var draw_list := rd.draw_list_begin(framebuffer_rid, RenderingDevice.DRAW_CLEAR_COLOR_ALL, [clear_color])
	rd.draw_list_bind_render_pipeline(draw_list, pipeline_rid)
	rd.draw_list_bind_vertex_array(draw_list, vertex_array_rid)
	rd.draw_list_bind_uniform_set(draw_list, uniform_set_rid, 0)
	if index_array_rid.is_valid():
		rd.draw_list_bind_index_array(draw_list, index_array_rid)
	rd.draw_list_set_push_constant(draw_list, xform_bytes, len(xform_bytes))
	rd.draw_list_draw(draw_list, index_array_rid.is_valid(), 1)
	rd.draw_list_end()

func _get_rid() -> RID:
	return texture_rd

func _get_width() -> int:
	return size.x

func _get_height() -> int:
	return size.y
