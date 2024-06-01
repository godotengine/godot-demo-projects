extends Control

var thread: Thread

func _on_load_pressed() -> void:
	if is_instance_valid(thread) and thread.is_started():
		# If a thread is already running, let it finish before we start another.
		thread.wait_to_finish()
	thread = Thread.new()
	print_rich("[b]Starting thread.")
	# Our method needs an argument, so we pass it using bind().
	thread.start(_bg_load.bind("res://mona.png"))


func _bg_load(path: String) -> Texture2D:
	print("Calling thread function.")
	var tex := load(path)
	# call_deferred() tells the main thread to call a method during idle time.
	# Our method operates on nodes currently in the tree, so it isn't safe to
	# call directly from another thread.
	_bg_load_done.call_deferred()
	return tex


func _bg_load_done() -> void:
	# Wait for the thread to complete, and get the returned value.
	var tex: Texture2D = thread.wait_to_finish()
	print_rich("[b][i]Thread finished.\n")
	$TextureRect.texture = tex
	# We're done with the thread now, so we can free it.
	# Threads are reference counted, so this is how we free them.
	thread = null


func _exit_tree() -> void:
	# You should always wait for a thread to finish before letting it get freed!
	# It might not clean up correctly if you don't.
	if is_instance_valid(thread) and thread.is_started():
		thread.wait_to_finish()
		thread = null
