extends Spatial

enum GIMode {
	NONE,
	BAKED_LIGHTMAP_ALL,
	BAKED_LIGHTMAP_INDIRECT,
	GI_PROBE,
	MAX,  # Maximum value of the enum, used internally.
}

# Keep this in sync with the GIMode enum (except for MAX).
const GI_MODE_TEXTS = [
	"Environment Lighting (Fastest)",
	"Baked Lightmap All (Fast)",
	"Baked Lightmap Indirect (Average)",
	"GIProbe (Slow)",
]

var gi_mode = GIMode.NONE
var use_reflection_probe = false

onready var gi_mode_label = $GIMode
onready var reflection_probe_mode_label = $ReflectionProbeMode
onready var reflection_probe = $Camera/ReflectiveSphere/ReflectionProbe


func _ready():
	set_gi_mode(GIMode.NONE)
	set_use_reflection_probe(false)


func _input(event):
	if event.is_action_pressed("cycle_gi_mode"):
		set_gi_mode(wrapi(gi_mode + 1, 0, GIMode.MAX))

	if event.is_action_pressed("toggle_reflection_probe"):
		set_use_reflection_probe(not use_reflection_probe)


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


func set_use_reflection_probe(p_visible):
	use_reflection_probe = p_visible

	if p_visible:
		reflection_probe_mode_label.text = "Current reflection probe mode: Enabled - Using reflection probe (Average)"
	else:
		reflection_probe_mode_label.text = "Current reflection probe mode: Disabled - Using environment or GIProbe reflections (Fast)"

	reflection_probe.visible = p_visible
