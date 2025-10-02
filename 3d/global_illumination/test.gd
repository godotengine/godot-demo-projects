extends Node3D

enum GIMode {
	NONE,
	LIGHTMAP_GI_ALL,
	LIGHTMAP_GI_INDIRECT,
	VOXEL_GI,
	SDFGI,
	MAX,  # Maximum value of the enum, used internally.
}

# Keep this in sync with the GIMode enum (except for MAX).
const GI_MODE_TEXTS = [
	"Environment Lighting (Fastest)",
	"Baked Lightmap All (Fast)",
	"Baked Lightmap Indirect (Average)",
	"VoxelGI (Slow)",
	"SDFGI (Slow)",
]

enum ReflectionProbeMode {
	NONE,
	ONCE,
	ALWAYS,
	MAX,
}

# Keep this in sync with the ReflectionProbeMode enum (except for MAX).
const REFLECTION_PROBE_MODE_TEXTS = [
	"Disabled - Using environment, VoxelGI or SDFGI reflections (Fast)",
	"Enabled - \"Once\" Update Mode (Average)",
	"Enabled - \"Always\" Update Mode (Slow)",
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

var gi_mode := GIMode.NONE
var reflection_probe_mode := ReflectionProbeMode.NONE
var ssil_mode := SSILMode.NONE

@onready var environment: Environment = $WorldEnvironment.environment
@onready var gi_mode_label: Label = $GIMode
@onready var reflection_probe_mode_label: Label = $ReflectionProbeMode
@onready var reflection_probe: ReflectionProbe = $Camera/ReflectiveSphere/ReflectionProbe
@onready var ssil_mode_label: Label = $SSILMode

# Several copies of the level mesh are required to cycle between different GI modes.
@onready var zdm2_no_lightmap: Node3D = $Zdm2NoLightmap
@onready var zdm2_lightmap_all: Node3D = $Zdm2LightmapAll
@onready var zdm2_lightmap_indirect: Node3D = $Zdm2LightmapIndirect


func _ready() -> void:
	set_gi_mode(gi_mode)
	set_reflection_probe_mode(reflection_probe_mode)
	set_ssil_mode(ssil_mode)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_gi_mode"):
		set_gi_mode(wrapi(gi_mode + 1, 0, GIMode.MAX))

	if event.is_action_pressed("cycle_reflection_probe_mode"):
		set_reflection_probe_mode(wrapi(reflection_probe_mode + 1, 0, ReflectionProbeMode.MAX))

	if event.is_action_pressed("cycle_ssil_mode"):
		set_ssil_mode(wrapi(ssil_mode + 1, 0, SSILMode.MAX))


func set_gi_mode(p_gi_mode: GIMode) -> void:
	gi_mode = p_gi_mode
	gi_mode_label.text = "Global illumination: %s " % GI_MODE_TEXTS[gi_mode]

	match p_gi_mode:
		GIMode.NONE:
			$Zdm2NoLightmap.visible = true
			$Zdm2LightmapAll.visible = false
			$Zdm2LightmapIndirect.visible = false

			# Halve sky contribution to prevent shaded areas from looking too bright and blue.
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			# There is no difference between Indirect and Disabled when no GI is used.
			# Pick the default value (which is Indirect).
			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC

		GIMode.LIGHTMAP_GI_ALL:
			$Zdm2NoLightmap.visible = false
			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false

			# Halve sky contribution to prevent dynamic objects from looking too bright and blue.
			# (When using lightmaps, this property doesn't affect lightmapped surfaces.)
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = true
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			# Make lights not affect baked surfaces by setting their bake mode to All.
			$Sun.light_bake_mode = Light3D.BAKE_STATIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_STATIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_STATIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_STATIC

		GIMode.LIGHTMAP_GI_INDIRECT:
			$Zdm2NoLightmap.visible = false
			$Zdm2LightmapAll.visible = false
			$Zdm2LightmapIndirect.visible = true

			# Halve sky contribution to prevent dynamic objects from looking too bright and blue.
			# (When using lightmaps, this property doesn't affect lightmapped surfaces.)
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = true
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC

		GIMode.VOXEL_GI:
			$Zdm2NoLightmap.visible = true
			$Zdm2LightmapAll.visible = false
			$Zdm2LightmapIndirect.visible = false

			environment.ambient_light_sky_contribution = 1.0
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = true
			environment.sdfgi_enabled = false

			# Bake mode must be Indirect, not Disabled. Otherwise, GI will
			# not be visible for those lights.
			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC

		GIMode.SDFGI:
			$Zdm2NoLightmap.visible = true
			$Zdm2LightmapAll.visible = false
			$Zdm2LightmapIndirect.visible = false

			environment.ambient_light_sky_contribution = 1.0
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = true

			# Bake mode must be Indirect, not Disabled. Otherwise, GI will
			# not be visible for those lights.
			$Sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC


func set_reflection_probe_mode(p_reflection_probe_mode: ReflectionProbeMode) -> void:
	reflection_probe_mode = p_reflection_probe_mode
	reflection_probe_mode_label.text = "Reflection probe: %s " % REFLECTION_PROBE_MODE_TEXTS[reflection_probe_mode]

	match p_reflection_probe_mode:
		ReflectionProbeMode.NONE:
			reflection_probe.visible = false
			reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE
		ReflectionProbeMode.ONCE:
			reflection_probe.visible = true
			reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE
		ReflectionProbeMode.ALWAYS:
			reflection_probe.visible = true
			reflection_probe.update_mode = ReflectionProbe.UPDATE_ALWAYS


func set_ssil_mode(p_ssil_mode: SSILMode) -> void:
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
