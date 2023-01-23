extends Control


# Various noise parameters.
var min_noise = -1
var max_noise = 1

# The OpenSimplexNoise object.
onready var noise: OpenSimplexNoise = $SeamlessNoiseTexture.texture.noise


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up noise with basic info.
	$ParameterContainer/SeedSpinBox.value = noise.seed
	$ParameterContainer/LacunaritySpinBox.value = noise.lacunarity
	$ParameterContainer/PeriodSpinBox.value = noise.period
	$ParameterContainer/PersistenceSpinBox.value = noise.persistence
	$ParameterContainer/OctavesSpinBox.value = noise.octaves

	# Render the noise.
	_refresh_shader_params()


func _refresh_shader_params():
	# Adjust min/max for shader.
	var _min = (min_noise + 1) / 2
	var _max = (max_noise + 1) / 2
	var _material = $SeamlessNoiseTexture.material
	_material.set_shader_param("min_value", _min)
	_material.set_shader_param("max_value", _max)


func _on_DocumentationButton_pressed():
	#warning-ignore:return_value_discarded
	OS.shell_open("https://docs.godotengine.org/en/latest/classes/class_opensimplexnoise.html")


func _on_RandomSeedButton_pressed():
	$ParameterContainer/SeedSpinBox.value = floor(rand_range(-2147483648, 2147483648))


func _on_SeedSpinBox_value_changed(value):
	noise.seed = value


func _on_LacunaritySpinBox_value_changed(value):
	noise.lacunarity = value


func _on_PeriodSpinBox_value_changed(value):
	noise.period = value


func _on_PersistenceSpinBox_value_changed(value):
	noise.persistence = value


func _on_OctavesSpinBox_value_changed(value):
	noise.octaves = value


func _on_MinClipSpinBox_value_changed(value):
	min_noise = value
	_refresh_shader_params()


func _on_MaxClipSpinBox_value_changed(value):
	max_noise = value
	_refresh_shader_params()
