extends AudioStreamPlayer


const DOUBLE_VOLUME_DB = 6 # Do not change. Represents doubling of sound pressure.

export(int) var base_volume_db = -14


func _ready():
	# To avoid AudioStreamPlayer2D sounds playing on top of each other and
	# being very loud, let's decrease the volume for splitscreen mode, but
	# increase the music volume to keep the music at the same volume.
	if get_parent().get_owner().name == "Splitscreen":
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), base_volume_db - DOUBLE_VOLUME_DB)
		volume_db = DOUBLE_VOLUME_DB
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), base_volume_db)
		volume_db = 0
