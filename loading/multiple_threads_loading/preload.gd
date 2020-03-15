extends Node


var queue


func _ready():
	# Initialize.
	queue = preload("res://resource_queue.gd").new()
	# Call after you instance the class to start the thread.
	queue.start()


func _process(_delta):
	# Returns true if a resource is done loading and ready to be retrieved.
	if queue.is_ready("res://main.tscn"):
		set_process(false)
		# Returns the fully loaded resource.
		var next_scene = queue.get_resource("res://main.tscn").instance()
		get_node("/root").add_child(next_scene)
		get_node("/root").remove_child(self)
		queue_free()
	else:
		# Get the progress of a resource.
		var progress = round(queue.get_progress("res://main.tscn") * 100)
		get_node("ProgressBar").set_value(progress)


func _on_Button_button_up():
	get_node("Button").hide()
	set_process(true)
	# Queue a resource.
	queue.queue_resource("res://main.tscn", true)
