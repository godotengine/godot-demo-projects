extends Control

#The OpenSimplexNoise object
var noise = OpenSimplexNoise.new()
var noise_texture = NoiseTexture.new()

#Various noise parameters
var noise_size = 500
var min_noise = -1
var max_noise = 1

#Are we using a NoiseTexture instead?
#Noise textures automatically grab and apply the noise data to an ImageTexture, instead of manually
const use_noise_texture = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Set up noise with basic info
	$ParameterContainer/SeedSpinBox.value = noise.seed
	$ParameterContainer/LacunaritySpinBox.value = noise.lacunarity
	$ParameterContainer/OctavesSpinBox.value = noise.octaves
	$ParameterContainer/PeriodSpinBox.value = noise.period
	$ParameterContainer/PersistenceSpinBox.value = noise.persistence
	
	#Render the noise
	_refresh_noise_images()
	
	#Do we need to set up a noise texture?
	if use_noise_texture:
		noise_texture.noise = noise
		$SeamlessNoiseTexture.texture = noise_texture
	

func _refresh_noise_images():
	
	#Adjust min/max for shader
	var _min = ((min_noise + 1)/2)
	var _max = ((max_noise + 1)/2)
	var _material = $SeamlessNoiseTexture.material
	_material.set_shader_param("min_value", _min)
	_material.set_shader_param("max_value", _max)
	
	#Are we using noise textures instead?
	if use_noise_texture:
		return
	
	#Get a new image if we aren't using a NoiseTexture
	var image = noise.get_seamless_image(500)
	var image_texture = ImageTexture.new()
	
	#Draw it
	image_texture.create_from_image(image)
	$SeamlessNoiseTexture.texture = image_texture
	

func _on_DocumentationButton_pressed():
	OS.shell_open("https://docs.godotengine.org/en/latest/classes/class_opensimplexnoise.html")
	

func _on_SeedSpinBox_value_changed(value):
	
	#Update the noise seed
	noise.seed = value
	_refresh_noise_images()
	

func _on_LacunaritySpinBox_value_changed(value):
	
	#Update noise
	noise.lacunarity = value
	_refresh_noise_images()
	

func _on_OctavesSpinBox_value_changed(value):
	
	#Update noise
	noise.octaves = value
	_refresh_noise_images()
	

func _on_PeriodSpinBox_value_changed(value):
	
	#Update noise
	noise.period = value
	_refresh_noise_images()
	

func _on_PersistenceSpinBox_value_changed(value):
	
	#Update noise
	noise.persistence = value
	_refresh_noise_images()
	

func _on_MinClipSpinBox_value_changed(value):
	
	#Just refresh
	min_noise = value
	_refresh_noise_images()
	

func _on_MaxClipSpinBox_value_changed(value):
	
	#Just refresh
	max_noise = value
	_refresh_noise_images()
	
