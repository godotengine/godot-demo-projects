@tool
extends MultiMeshInstance3D
# Places thousands of copies of the fish created by the AnimatedFish node.
# To use: change instance count in the inspector then press the exported refresh button.
# A high instance count can bloat the scene size, setting the count during runtime may be better.
# See the AnimatedFish node for more documentation.

# Changing the multimesh instance count using the inspector will create new buffer data(transforms)
# filled with random data, causing the models to visually glitch out. Refresh will re-assign good transforms.
@export_tool_button("Refresh")
var refresh_action: Callable = setup_multimesh


func _ready() -> void:
	# Due to using a @tool script, changing instance count here increases scene file size.
	# May also throw harmless errors about instance count.
	if multimesh.instance_count == 0:
		multimesh.instance_count = 2000
	setup_multimesh()


func setup_multimesh() -> void:
	# Give each fish instance a good transform with a random location.
	for i in range(multimesh.instance_count):
		var xform := Transform3D()
		# Change this to change the area the fish fill.
		xform = xform.translated(Vector3(randf() * 200, randf() * 200, randf() * 200))
		multimesh.set_instance_transform(i, xform)

		# Optional for extra parameters per fish. The rgb components are used for color.
		# The fourth "a" component is used for animation speed.
		# The Particle Fish shader also sets this custom data similarly.
		multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))
