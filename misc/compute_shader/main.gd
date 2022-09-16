extends Control

@export_file("*.glsl") var shader_file
@export_range(128, 4096, 1, "exp") var dimension: int = 512

@onready var seed_input: TextEdit = $CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/GridContainer/SeedInput
@onready var heightmap_rect: TextureRect = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer/RawHeightmap
@onready var island_rect: TextureRect = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer/ComputedHeightmap

var noise: FastNoiseLite
var gradient: Gradient
var gradient_tex: GradientTexture1D

var po2_dimensions: int
var start_time: int

func _init() -> void:
	randomize()
	# Create a noise function as the basis for our heightmap
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_octaves = 5
	noise.fractal_lacunarity = 1.9
	# Create a gradient to function as overlay
	gradient = Gradient.new()
#	gradient.add_point(0.3, Color(0.5, 0.5, 0.5, 1.0))
	gradient.add_point(0.6, Color(0.9, 0.9, 0.9, 1.0))
	gradient.add_point(0.8, Color(1.0, 1.0, 1.0, 1.0))
	# The gradient will start black, transition to grey in the first 70%, then to white in the last 30%
	gradient.reverse()
	# Create a 1D texture (single row of pixels) from gradient
	gradient_tex = GradientTexture1D.new()
	gradient_tex.gradient = gradient


func _ready() -> void:
	randomize_seed()
	# Round dimension to nearest power of 2
	print(dimension)
	po2_dimensions = nearest_po2(dimension)
	
	noise.frequency = 0.003 / (float(po2_dimensions) / float(512))


# Generate a random integer, convert it to a string and set it as text for the TextEdit field
func randomize_seed() -> void:
	seed_input.text = str(randi())


func prepare_image() -> Image:
	# Store starting time
	start_time = Time.get_ticks_usec()
	# Use the to_int() method on the String to convert to a valid seed
	noise.seed = seed_input.text.to_int()
	# Create image from noise
	var heightmap := noise.get_image(po2_dimensions, po2_dimensions, false, false)
	
	# Create ImageTexture to display original on screen
	var clone = Image.new()
	clone.copy_from(heightmap)
	clone.resize(512, 512, Image.INTERPOLATE_NEAREST)
	var clone_tex := ImageTexture.create_from_image(clone)
	heightmap_rect.texture = clone_tex
	
	return heightmap


func compute_island_gpu(heightmap: Image) -> void:
	# Create rendering device
	var rd := RenderingServer.create_local_rendering_device()
	# Prepare the shader
	var shader_rid := load_shader(rd, shader_file)
	
	# Create format for heightmap
	var heightmap_format := RDTextureFormat.new()
	# There are a lot of different formats, it might take some studying to be able to be able to
	# choose the right ones. In this case, we tell it to interpret the data as a single byte for red.
	# Even though the noise image only has a luminance channel, we can just interpret this as if it 
	# was the red channel. The byte latout is the same!
	heightmap_format.format = RenderingDevice.DATA_FORMAT_R8_UNORM
	heightmap_format.width = po2_dimensions
	heightmap_format.height = po2_dimensions
	# The TextureUsageBits are stored as 'bit fields', denoting what can be done with the data.
	# Because of how bit fields work, we can just sum the required ones: 8 + 64 + 128
	heightmap_format.usage_bits = \
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	# Store heightmap as texture
	var heightmap_rid := rd.texture_create(heightmap_format, RDTextureView.new(), [heightmap.get_data()])
	
	# Create uniform for heightmap
	var heightmap_uniform := RDUniform.new()
	heightmap_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	heightmap_uniform.binding = 0 # This matches the binding in the shader
	heightmap_uniform.add_id(heightmap_rid)
	
	# Create format for the gradient
	var gradient_format := RDTextureFormat.new()
	# The gradient could have been converted to a single channel like we did with the heightmap,
	# but for illustrative purposes we use four channels (RGBA)
	gradient_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	gradient_format.width = gradient_tex.width # default: 256
	# GradientTexture1D always has a height of 1
	gradient_format.height = 1
	gradient_format.usage_bits = \
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	
	# Storage gradient as texture
	var gradient_rid := rd.texture_create(gradient_format, RDTextureView.new(), [gradient_tex.get_image().get_data()])
	
	# Create uniform for gradient
	var gradient_uniform := RDUniform.new()
	gradient_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	gradient_uniform.binding = 1 # This matches the binding in the shader
	gradient_uniform.add_id(gradient_rid)
	
	var uniform_set := rd.uniform_set_create([heightmap_uniform, gradient_uniform], shader_rid, 0)
	
	var pipeline := rd.compute_pipeline_create(shader_rid)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	# This is where the magic happens! As our shader has a work group size of 1x1x1, we dispatch
	# one for each pixel here. This ratio is highly tunable, and performance may vary
	rd.compute_list_dispatch(compute_list, po2_dimensions, po2_dimensions, 1)
	rd.compute_list_end()
	
	rd.submit()
	# Wait for the GPU to finish
	rd.sync()
	
	# Retrieve processed data
	var output_bytes := rd.texture_get_data(heightmap_rid, 0)
	var island_img := Image.new()
	# Even though the GPU was working on the image as if each byte represented the red channel, we
	# will interpret the data as if it was the luminance channel.
	island_img.create_from_data(po2_dimensions, po2_dimensions, false, Image.FORMAT_L8, output_bytes)
	
	display_island(island_img)


# Import, compile and load shader, return reference
func load_shader(rd: RenderingDevice, path: String) -> RID:
	var shader_file_data := load(path)
	var shader_spirv: RDShaderSPIRV = shader_file_data.get_spirv()
	return rd.shader_create_from_spirv(shader_spirv)


func compute_island_cpu(heightmap: Image) -> void:
	var center := Vector2i(po2_dimensions, po2_dimensions) / 2
	# Loop over all pixel coords in the image
	for y in range(0, po2_dimensions):
		for x in range(0, po2_dimensions):
			var coord := Vector2i(x, y)
			var pixel := heightmap.get_pixelv(coord)
			# Calculate the distance between the coord and the center
			var distance := Vector2(center).distance_to(Vector2(coord))
			# As the X and Y dimensions are the same, we can use center.x as a proxy for the distance
			# from the center to an edge
			var gradient_color := gradient.sample(distance / float(center.x))
			# We use the v ('value') of the pixel here. This is not the same as the luminance we use
			# in the compute shader, but close enough for our purposes here
			pixel.v *= gradient_color.v
			if pixel.v < 0.2:
				pixel.v = 0.0
			heightmap.set_pixelv(coord, pixel)
	display_island(heightmap)


func display_island(island: Image) -> void:
	island.resize(512, 512, Image.INTERPOLATE_NEAREST)
	# Create ImageTexture to display original on screen
	var island_tex := ImageTexture.create_from_image(island)
	island_rect.texture = island_tex
	
	# Calculate and display elapsed time
	var stop_time := Time.get_ticks_usec()
	var elapsed := stop_time - start_time
	$CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer2/Label2.text = str(elapsed) + " μs"


# Called when RandomButton is pressed
func _on_random_button_pressed() -> void:
	randomize_seed()


# Called when CreateButton is pressed
func _on_create_button_pressed() -> void:
	var heightmap = prepare_image()
	call_deferred("compute_island_gpu", heightmap)


# Called when CreateButtonCPU is pressed
func _on_create_button_cpu_pressed():
	var heightmap = prepare_image()
	call_deferred("compute_island_cpu", heightmap)
