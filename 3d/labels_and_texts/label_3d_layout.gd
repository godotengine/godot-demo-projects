# Layout is simulated by adjusting Label3Ds' `offset` properties.
# This can be done in the inspector, or via code with the help of `Font.get_string_size()`.
# For proper billboard behavior, Label3D's `offset` property
# must be adjusted instead of adjusting the `position` property.
extends Node3D

var health := 0: set = set_health
var counter := 0.0

# The margin to apply between the name and health percentage (in pixels).
const HEALTH_MARGIN = 25

# The health bar width (in number of characters).
# Higher can be more precise, at the cost of lower performance
# (since more characters may need to be rendered at once).
const BAR_WIDTH = 100

func _ready() -> void:
	$LineEdit.text = $Name.text


func _process(delta: float) -> void:
	# Animate the health percentage.
	counter += delta
	health = roundi(50 + sin(counter * 0.5) * 50)


func _on_line_edit_text_changed(new_text: String) -> void:
	$Name.text = new_text

	# Adjust name's font size to fit within the allowed width.
	$Name.font_size = 32
	while $Name.font.get_string_size($Name.text, $Name.horizontal_alignment, -1, $Name.font_size).x > $Name.width:
		$Name.font_size -= 1


func set_health(p_health: int) -> void:
	health = p_health

	$Health.text = "%d%%" % round(health)
	if health <= 30:
		# Low health alert.
		$Health.modulate = Color(1, 0.2, 0.1)
		$Health.outline_modulate = Color(0.2, 0.1, 0.0)
		$HealthBarForeground.modulate = Color(1, 0.2, 0.1)
		$HealthBarForeground.outline_modulate = Color(0.2, 0.1, 0.0)
		$HealthBarBackground.outline_modulate = Color(0.2, 0.1, 0.0)
		$HealthBarBackground.modulate = Color(0.2, 0.1, 0.0)
	else:
		$Health.modulate = Color(0.8, 1, 0.4)
		$Health.outline_modulate = Color(0.15, 0.2, 0.15)
		$HealthBarForeground.modulate = Color(0.8, 1, 0.4)
		$HealthBarForeground.outline_modulate = Color(0.15, 0.2, 0.15)
		$HealthBarBackground.outline_modulate = Color(0.15, 0.2, 0.15)
		$HealthBarBackground.modulate = Color(0.15, 0.2, 0.15)

	# Construct an health bar with `|` symbols brought very close to each other using
	# a custom FontVariation on the HealthBarForeground and HealthBarBackground nodes.
	var bar_text := ""
	var bar_text_bg := ""
	for i in roundi((health / 100.0) * BAR_WIDTH):
		bar_text += "|"
	for i in BAR_WIDTH:
		bar_text_bg += "|"

	$HealthBarForeground.text = str(bar_text)
	$HealthBarBackground.text = str(bar_text_bg)
