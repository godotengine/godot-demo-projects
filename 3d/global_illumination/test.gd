extends Spatial


enum GIMode {
	NONE,
	BAKED_LIGHTMAP_ALL,
	BAKED_LIGHTMAP_INDIRECT,
	GI_PROBE,
	MAX,  # Maximum value of the enum, used internally.
}

enum ReflectionProbeMode {
	NONE,
	ONCE,
	ALWAYS,
	MAX,
}

# Keep this in sync with the GIMode enum (except for MAX).
const GI_MODE_TEXTS = [
	"Environment Lighting (Fastest)",
	"Baked Lightmap All (Fast)",
	"Baked Lightmap Indirect (Average)",
	"GIProbe (Slow)",
]

# Keep this in sync with the ReflectionProbeMode enum (except for MAX).
const REFLECTION_PROBE_MODE_TEXTS = [
	"Disabled - Using environment, VoxelGI or SDFGI reflections (Fastest)",
	"Enabled - \"Once\" Update Mode (Average)",
	"Enabled - \"Always\" Update Mode (Slow)",
]

var gi_mode = GIMode.NONE
var reflection_probe_mode = ReflectionProbeMode.NONE
var use_ssao = false

onready var environment = preload("res://default_env.tres")
onready var gi_mode_label = $GIMode
onready var reflection_probe_mode_label = $ReflectionProbeMode
onready var ssao_label = $SSAO
onready var reflection_probe = $Camera/ReflectiveSphere/ReflectionProbe


func _ready():
	set_gi_mode(GIMode.NONE)
	set_reflection_probe_mode(ReflectionProbeMode.NONE)
	set_use_ssao(use_ssao)


func _input(event):
	if event.is_action_pressed("cycle_gi_mode"):
		set_gi_mode(wrapi(gi_mode + 1, 0, GIMode.MAX))

	if event.is_action_pressed("cycle_reflection_probe_mode"):
		set_reflection_probe_mode(wrapi(reflection_probe_mode + 1, 0, ReflectionProbeMode.MAX))

	if event.is_action_pressed("toggle_ssao"):
		set_use_ssao(not use_ssao)


func set_gi_mode(p_gi_mode):
	gi_mode = p_gi_mode
	gi_mode_label.text = "Current GI mode: %s " % GI_MODE_TEXTS[gi_mode]

	match p_gi_mode:
		GIMode.NONE:
			$ZdmBakeIndirect.visible = false
			$ZdmBakeAll.visible = false
			$ZdmNoBake.visible = true
			$BakedLightmapIndirect.visible = false
			$BakedLightmapAll.visible = false
			$GIProbe.visible = false

			# There is no difference between Indirect and Disabled when no GI is used.
			# Pick the default value (which is Indirect).
			$Sun.light_bake_mode = Light.BAKE_INDIRECT
			$GrateOmniLight.light_bake_mode = Light.BAKE_INDIRECT
			$GarageOmniLight.light_bake_mode = Light.BAKE_INDIRECT
			$CornerSpotLight.light_bake_mode = Light.BAKE_INDIRECT

		GIMode.BAKED_LIGHTMAP_ALL:
			$ZdmBakeIndirect.visible = false
			$ZdmBakeAll.visible = true
			$ZdmNoBake.visible = false
			$BakedLightmapIndirect.visible = false
			$BakedLightmapAll.visible = true
			$GIProbe.visible = false

			# Make lights not affect baked surfaces by setting their bake mode to All.
			$Sun.light_bake_mode = Light.BAKE_ALL
			$GrateOmniLight.light_bake_mode = Light.BAKE_ALL
			$GarageOmniLight.light_bake_mode = Light.BAKE_ALL
			$CornerSpotLight.light_bake_mode = Light.BAKE_ALL

		GIMode.BAKED_LIGHTMAP_INDIRECT:
			$ZdmBakeIndirect.visible = true
			$ZdmBakeAll.visible = false
			$ZdmNoBake.visible = false
			$BakedLightmapIndirect.visible = true
			$BakedLightmapAll.visible = false
			$GIProbe.visible = false

			$Sun.light_bake_mode = Light.BAKE_INDIRECT
			$GrateOmniLight.light_bake_mode = Light.BAKE_INDIRECT
			$GarageOmniLight.light_bake_mode = Light.BAKE_INDIRECT
			$CornerSpotLight.light_bake_mode = Light.BAKE_INDIRECT

		GIMode.GI_PROBE:
			$ZdmBakeIndirect.visible = false
			$ZdmBakeAll.visible = false
			$ZdmNoBake.visible = true
			$BakedLightmapIndirect.visible = false
			$BakedLightmapAll.visible = false
			$GIProbe.visible = true

			# Bake mode must be Indirect, not Disabled. Otherwise, GI will
			# not be visible for those lights.
			# Moving/blinking lights should generally have their bake mode set to Disabled
			# to avoid visible GI pop-ins. This is because GIProbe
			# can take a while to update.
			$Sun.light_bake_mode = Light.BAKE_INDIRECT
			$GrateOmniLight.light_bake_mode = Light.BAKE_INDIRECT
			$GarageOmniLight.light_bake_mode = Light.BAKE_INDIRECT
			$CornerSpotLight.light_bake_mode = Light.BAKE_INDIRECT


func set_reflection_probe_mode(p_reflection_probe_mode):
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


func set_use_ssao(p_use_ssao):
	use_ssao = p_use_ssao
	ssao_label.text = "Screen-space ambient occlusion: %s" % "Enabled (Slow)" if use_ssao else "Disabled (Fastest)"

	environment.ssao_enabled = use_ssao
