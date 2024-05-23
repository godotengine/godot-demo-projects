# This is an autoload (singleton) which will save
# the key maps in a simple way through a dictionary.
extends Node

const keymaps_path := "user://keymaps.dat"
var keymaps: Dictionary


func _ready() -> void:
	# First we create the keymap dictionary on startup with all
	# the keymap actions we have.
	for action in InputMap.get_actions():
		if not InputMap.action_get_events(action).is_empty():
			keymaps[action] = InputMap.action_get_events(action)[0]

	load_keymap()


func load_keymap() -> void:
	if not FileAccess.file_exists(keymaps_path):
		# There is no save file yet, so let's create one.
		save_keymap()
		return

	var file := FileAccess.open(keymaps_path, FileAccess.READ)
	var temp_keymap: Dictionary = file.get_var(true)
	file.close()
	# We don't just replace the keymaps dictionary, because if you
	# updated your game and removed/added keymaps, the data of this
	# save file may have invalid actions. So we check one by one to
	# make sure that the keymap dictionary really has all current actions.
	for action: StringName in keymaps.keys():
		if temp_keymap.has(action):
			keymaps[action] = temp_keymap[action]
			# Whilst setting the keymap dictionary, we also set the
			# correct InputMap event.
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, keymaps[action])


func save_keymap() -> void:
	# For saving the keymap, we just save the entire dictionary as a var.
	var file := FileAccess.open(keymaps_path, FileAccess.WRITE)
	file.store_var(keymaps, true)
	file.close()
