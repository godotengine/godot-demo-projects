extends Node3D

enum GIMode {
	NONE,
#	BAKED_LIGHTMAP_ALL,
#	BAKED_LIGHTMAP_INDIRECT,
	VOXEL_GI,
	SDFGI,
	MAX,  # Maximum value of the enum, used internally.
}

# Keep this in sync with the GIMode enum (except for MAX).
const GI_MODE_TEXTS = [
	"Environment Lighting (Fastest)",
#	"Baked Lightmap All (Fast)",
#	"Baked Lightmap Indirect (Average)",
	"VoxelGI (Slow)",
	"SDFGI (Slow)",
]

enum SSILMode {
	NONE,
	SSAO,
	SSIL,
	SSAO_AND_SSIL,
	MAX,  # Maximum value of the enum, used internally.
}

# Keep this in sync with the SSILMode enum (except for MAX).
const SSIL_MODE_TEXTS = [
	"Disabled (Fastest)",
	"Screen-space ambient occlusion (Fast)",
	"Screen-space indirect lighting (Average)",
	"SSAO + SSIL (Slow)",
]

var gi_mode = GIMode.NONE
var use_reflection_probe = false
var ssil_mode = SSILMode.NONE

@onready var environment = $WorldEnvironment.environment
@onready var gi_mode_label = $GIMode
@onready var reflection_probe_mode_label = $ReflectionProbeMode
@onready var reflection_probe = $Camera/ReflectiveSphere/ReflectionProbe
@onready var ssil_mode_label = $SSILMode


func _ready():
	set_gi_mode(gi_mode)
	set_use_reflection_probe(use_reflection_probe)
	set_ssil_mode(ssil_mode)


func _input(event):
	if event.is_action_pressed("cycle_gi_mode"):
		set_gi_mode(wrapi(gi_mode + 1, 0, GIMode.MAX))

	if event.is_action_pressed("toggle_reflection_probe"):
		set_use_reflection_probe(not use_reflection_probe)

	if event.is_action_pressed("cycle_ssil_mode"):
		set_ssil_mode(wrapi(ssil_mode + 1, 0, SSILMode.MAX))


func set_gi_mode(p_gi_mode):
	gi_mode = p_gi_mode
	gi_mode_label.text = "Global illumination: %s " % GI_MODE_TEXTS[gi_mode]

	match p_gi_mode:
		GIMode.NONE:
#			$BakedLightmapIndirect.visible = false
#			$BakedLightmapAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			# There is no difference between Indirect and Disabled when no GI is used.
			# Pick the default value (which is Indirect).
			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC

#		GIMode.BAKED_LIGHTMAP_ALL:
#			$BakedLightmapIndirect.visible = false
#			$BakedLightmapAll.visible = true
#			$VoxelGI.visible = false
#			environment.sdfgi_enabled = false
#
#			# Make lights not affect baked surfaces by setting their bake mode to All.
#			$Sun.light_bake_mode = Light3D.BAKE_STATIC
#			$GrateOmniLight.light_bake_mode = Light3D.BAKE_STATIC
#			$GarageOmniLight.light_bake_mode = Light3D.BAKE_STATIC
#			$CornerSpotLight.light_bake_mode = Light3D.BAKE_STATIC

#		GIMode.BAKED_LIGHTMAP_INDIRECT:
#			$BakedLightmapIndirect.visible = true
#			$BakedLightmapAll.visible = false
#			$VoxelGI.visible = false
#			environment.sdfgi_enabled = false
#
#			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
#			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
#			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
#			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC

		GIMode.VOXEL_GI:
#			$BakedLightmapIndirect.visible = false
#			$BakedLightmapAll.visible = false
			$VoxelGI.visible = true
			environment.sdfgi_enabled = false

			# Bake mode must be Indirect, not Disabled. Otherwise, GI will
			# not be visible for those lights.
			# Moving/blinking lights should generally have their bake mode set to Disabled
			# to avoid visible GI pop-ins. This is because VoxelGI
			# can take a while to update.
			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC

		GIMode.SDFGI:
#			$BakedLightmapIndirect.visible = false
#			$BakedLightmapAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = true

			# Bake mode must be Indirect, not Disabled. Otherwise, GI will
			# not be visible for those lights.
			# Moving/blinking lights should generally have their bake mode set to Disabled
			# to avoid visible GI pop-ins. This is because SDFGI
			# can take a while to update.
			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC


func set_use_reflection_probe(p_visible):
	use_reflection_probe = p_visible

	if p_visible:
		reflection_probe_mode_label.text = "Reflection probe: Enabled - Using reflection probe (Average)"
	else:
		reflection_probe_mode_label.text = "Reflection probe: Disabled - Using environment, VoxelGI or SDFGI reflections (Fast)"

	reflection_probe.visible = p_visible


func set_ssil_mode(p_ssil_mode):
	ssil_mode = p_ssil_mode
	ssil_mode_label.text = "Screen-space lighting effects: %s " % SSIL_MODE_TEXTS[ssil_mode]

	match p_ssil_mode:
		SSILMode.NONE:
			environment.ssao_enabled = false
			environment.ssil_enabled = false
		SSILMode.SSAO:
			environment.ssao_enabled = true
			environment.ssil_enabled = false
		SSILMode.SSIL:
			environment.ssao_enabled = false
			environment.ssil_enabled = true
		SSILMode.SSAO_AND_SSIL:
			environment.ssao_enabled = true
			environment.ssil_enabled = true
