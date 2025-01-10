extends Node3D

enum GIMode {
	NONE,
	LIGHTMAP_GI_ALL,
	LIGHTMAP_GI_INDIRECT,
	VOXEL_GI,
	SDFGI,
	MAX,  # Maximum value of the enum, used internally.
}

enum ReflectionProbeMode {
	NONE,
	ONCE,
	ALWAYS,
	MAX,
}

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

# Keep this in sync with the ReflectionProbeMode enum (except for MAX).
var reflection_probe_mode_texts: Array[String] = [
	"Disabled - Using environment, VoxelGI or SDFGI reflections (Fast)",
	"Enabled - \"Once\" Update Mode (Average)",
	"Enabled - \"Always\" Update Mode (Slow)",
]

# Keep this in sync with the GIMode enum (except for MAX).
var gi_mode_texts: Array[String] = [
	"Environment Lighting (Fastest)",
	"Baked Lightmap All (Fast)",
	"Baked Lightmap Indirect (Average)",
	"VoxelGI (Slow)",
	"SDFGI (Slow)",
]

var gi_mode := GIMode.NONE
var reflection_probe_mode := ReflectionProbeMode.NONE
var ssil_mode := SSILMode.NONE
var is_compatibility := false

# This is replaced further below if using Compatibility to point to a newly created DirectionalLight3D
# (which does not affect sky rendering).
@onready var sun: DirectionalLight3D = $Sun
@onready var lightmap_gi_all_data: LightmapGIData = $LightmapGIAll.light_data
@onready var environment: Environment = $WorldEnvironment.environment
@onready var gi_mode_label: Label = $GIMode
@onready var reflection_probe_mode_label: Label = $ReflectionProbeMode
@onready var reflection_probe: ReflectionProbe = $Camera/ReflectiveSphere/ReflectionProbe
@onready var ssil_mode_label: Label = $SSILMode

# Several copies of the level mesh are required to cycle between different GI modes.
@onready var zdm2_lightmap_all: Node3D = $Zdm2LightmapAll
@onready var zdm2_lightmap_indirect: Node3D = $Zdm2LightmapIndirect


func _ready() -> void:
	if ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method") == "gl_compatibility":
		is_compatibility = true
		# Remove unsupported VoxelGI/SDFGI references from the label.
		reflection_probe_mode_texts[0] = "Disabled - Using environment reflections (Fast)"
		set_gi_mode(GIMode.NONE)
		# Darken lights's energy to compensate for sRGB blending (without affecting sky rendering).
		# This only applies to lights with shadows enabled.
		$GrateOmniLight.light_energy = 0.25
		$GarageOmniLight.light_energy = 0.5
		sun.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		sun = sun.duplicate()
		sun.light_energy = 0.15
		sun.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(sun)
		$Help.text = """Space: Cycle between GI modes
R: Cycle between reflection probe modes
Escape or F10: Toggle mouse capture"""
	else:
		set_gi_mode(gi_mode)

	set_reflection_probe_mode(reflection_probe_mode)
	set_ssil_mode(ssil_mode)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_gi_mode"):
		if is_compatibility:
			# Only LightmapGI is supported in Compatibility.
			# Note that the actual GI mode is the opposite of what's being set here, due to a bug
			# in the Compatibility rendering method.
			set_gi_mode(wrapi(gi_mode + 1, 0, GIMode.VOXEL_GI))
		else:
			set_gi_mode(wrapi(gi_mode + 1, 0, GIMode.MAX))

	if event.is_action_pressed("cycle_reflection_probe_mode"):
		set_reflection_probe_mode(wrapi(reflection_probe_mode + 1, 0, ReflectionProbeMode.MAX))

	if event.is_action_pressed("cycle_ssil_mode"):
		set_ssil_mode(wrapi(ssil_mode + 1, 0, SSILMode.MAX))


func set_gi_mode(p_gi_mode: GIMode) -> void:
	gi_mode = p_gi_mode
	gi_mode_label.text = "Global illumination: %s " % gi_mode_texts[gi_mode]

	match p_gi_mode:
		GIMode.NONE:
			if is_compatibility:
				# Work around Compatibility bug where lightmaps are still visible if the LightmapGI node is hidden.
				$LightmapGIAll.light_data = null

			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false

			# Halve sky contribution to prevent shaded areas from looking too bright and blue.
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			# There is no difference between Indirect and Disabled when no GI is used.
			# Pick the default value (which is Indirect).
			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DISABLED

		GIMode.LIGHTMAP_GI_ALL:
			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false
			$LightmapGIAll.light_data = lightmap_gi_all_data

			# Halve sky contribution to prevent dynamic objects from looking too bright and blue.
			# (When using lightmaps, this property doesn't affect lightmapped surfaces.)
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = true
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			# Make lights not affect baked surfaces by setting their bake mode to All.

			sun.light_bake_mode = Light3D.BAKE_STATIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_STATIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_STATIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_STATIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC

		GIMode.LIGHTMAP_GI_INDIRECT:
			$LightmapGIAll.light_data = lightmap_gi_all_data
			$Zdm2LightmapAll.visible = false
			$Zdm2LightmapIndirect.visible = true

			# Halve sky contribution to prevent dynamic objects from looking too bright and blue.
			# (When using lightmaps, this property doesn't affect lightmapped surfaces.)
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = true
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			# Mark box as dynamic so it benefits from lightmap probes.
			# Don't do this in other GI modes to avoid the heavy performance impact that
			# happens with VoxelGI for dynamic objects.
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC

		GIMode.VOXEL_GI:
			# Work around bug where VoxelGI is not visible if the LightmapGI node is hidden (with LightmapGIData still present).
			$LightmapGIAll.light_data = null

			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false

			environment.ambient_light_sky_contribution = 1.0
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = true
			environment.sdfgi_enabled = false

			# Bake mode must be Indirect, not Disabled. Otherwise, GI will
			# not be visible for those lights.
			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DISABLED

		GIMode.SDFGI:
			# Work around bug where SDFGI is not visible if the LightmapGI node is hidden (with LightmapGIData still present).
			$LightmapGIAll.light_data = null

			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false

			environment.ambient_light_sky_contribution = 1.0
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = true

			# Bake mode must be Indirect, not Disabled. Otherwise, GI will
			# not be visible for those lights.
			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DISABLED


func set_reflection_probe_mode(p_reflection_probe_mode: ReflectionProbeMode) -> void:
	reflection_probe_mode = p_reflection_probe_mode
	reflection_probe_mode_label.text = "Reflection probe: %s " % reflection_probe_mode_texts[reflection_probe_mode]

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
	if is_compatibility:
		ssil_mode_label.text = "Screen-space lighting effects: Not supported on Compatibility"
		ssil_mode_label.self_modulate.a = 0.6
		return
	else:
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
