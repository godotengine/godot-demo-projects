extends Control

@onready var file_path_edit := $MarginContainer/VBoxContainer/HBoxContainer/FilePath as LineEdit
@onready var file_dialog := $MarginContainer/VBoxContainer/HBoxContainer/FileDialog as FileDialog
@onready var plain_text_viewer := $MarginContainer/VBoxContainer/Result/PlainTextViewer as ScrollContainer
@onready var plain_text_viewer_label := $MarginContainer/VBoxContainer/Result/PlainTextViewer/Label as Label
@onready var texture_viewer := $MarginContainer/VBoxContainer/Result/TextureViewer as TextureRect
@onready var audio_player := $MarginContainer/VBoxContainer/Result/AudioPlayer as Button
@onready var audio_stream_player := $MarginContainer/VBoxContainer/Result/AudioPlayer/AudioStreamPlayer as AudioStreamPlayer
@onready var scene_viewer := $MarginContainer/VBoxContainer/Result/SceneViewer as SubViewportContainer
@onready var scene_viewer_camera := $MarginContainer/VBoxContainer/Result/SceneViewer/SubViewport/Camera3D as Camera3D
@onready var font_viewer := $MarginContainer/VBoxContainer/Result/FontViewer as Label
@onready var zip_viewer := $MarginContainer/VBoxContainer/Result/ZIPViewer as HSplitContainer
@onready var zip_viewer_file_list := $MarginContainer/VBoxContainer/Result/ZIPViewer/FileList as ItemList
@onready var zip_viewer_file_preview := $MarginContainer/VBoxContainer/Result/ZIPViewer/FilePreview as Label
@onready var error_label := $MarginContainer/VBoxContainer/Result/ErrorLabel as Label

@onready var export_button := $MarginContainer/VBoxContainer/Export as Button
@onready var export_file_dialog := $MarginContainer/VBoxContainer/Export/FileDialog as FileDialog

var zip_reader := ZIPReader.new()

# Keeps reference to the root node imported in the 3D scene viewer,
# so that it can be exported later.
var scene_viewer_root_node: Node

func _on_browse_pressed() -> void:
	file_dialog.popup_centered_ratio()


func _on_file_path_text_submitted(new_text: String) -> void:
	open_file(new_text)
	# Put the caret at the end of the submitted text.
	file_path_edit.caret_column = file_path_edit.text.length()


func _on_file_dialog_file_selected(path: String) -> void:
	open_file(path)


func reset_visibility() -> void:
	plain_text_viewer.visible = false
	texture_viewer.visible = false
	audio_player.visible = false

	scene_viewer.visible = false
	var last_child := scene_viewer.get_child(-1)
	if last_child is Node3D:
		scene_viewer.remove_child(last_child)
		last_child.queue_free()

	font_viewer.visible = false

	zip_viewer.visible = false
	zip_viewer_file_list.clear()

	error_label.visible = false
	export_button.disabled = false


func _on_audio_player_pressed() -> void:
	audio_stream_player.play()


func _on_scene_viewer_zoom_value_changed(value: float) -> void:
	# Slider uses negative value so that it can be inverted easily
	# (lower Camera3D orthogonal size is more zoomed *in*).
	scene_viewer_camera.size = abs(value)


func _on_zip_viewer_item_selected(index: int) -> void:
	zip_viewer_file_preview.text = zip_reader.read_file(
			zip_viewer_file_list.get_item_text(index)
	).get_string_from_utf8()


#region File exporting
func _on_export_pressed() -> void:
	export_file_dialog.popup_centered_ratio()


func _on_export_file_dialog_file_selected(path: String) -> void:
	if plain_text_viewer.visible:
		var file_access := FileAccess.open(path, FileAccess.WRITE)
		file_access.store_string(plain_text_viewer_label.text)
		file_access.close()

	elif texture_viewer.visible:
		var image := texture_viewer.texture.get_image()
		if path.ends_with(".png"):
			image.save_png(path)
		if path.ends_with(".jpg") or path.ends_with(".jpeg"):
			const JPG_QUALITY = 0.9
			image.save_jpg(path, JPG_QUALITY)
		if path.ends_with(".webp"):
			# Saving WebP is lossless by default, but can be made lossy using
			# optional parameters in `Image.save_webp()`.
			image.save_webp(path)

	elif audio_player.visible:
		# Ogg Vorbis audio can't be exported at runtime to a standard format
		# (only WAV files can be using `AudioStreamWAV.save_to_wav()`).
		pass

	elif scene_viewer.visible:
		var gltf_document := GLTFDocument.new()
		var gltf_state := GLTFState.new()
		gltf_document.append_from_scene(scene_viewer_root_node, gltf_state)
		# The file extension in the output `path` (`.gltf` or `.glb`) determines
		# whether the output uses text or binary format. Binary format is faster
		# to write and smaller, but harder to debug. The binary format is also
		# more suited to embedding textures.
		gltf_document.write_to_filesystem(gltf_state, path)

	elif font_viewer.visible:
		# Fonts can't be exported at runtime to a standard format
		# (only to a Godot-specific `.res` format using the ResourceSaver class).
		pass

	elif zip_viewer.visible:
		var zip_packer := ZIPPacker.new()
		var error := zip_packer.open(path)
		if error != OK:
			push_error("An error occurred while trying to save a ZIP archive to: %s" % path)
			return

		for file in zip_reader.get_files():
			zip_packer.start_file(file)
			zip_packer.write_file(zip_reader.read_file(file))
			zip_packer.close_file()

		zip_packer.close()
#endregion


func show_error(message: String) -> void:
	reset_visibility()
	error_label.text = "ERROR: %s" % message
	error_label.visible = true


func open_file(path: String) -> void:
	print_rich("Opening: [u]%s[/u]" % path)
	file_path_edit.text = path
	var path_lower := path.to_lower()

	# Images.
	if (
			path_lower.ends_with(".jpg")
			or path_lower.ends_with(".jpeg")
			or path_lower.ends_with(".png")
			or path_lower.ends_with(".webp")
			or path_lower.ends_with(".svg")
			or path_lower.ends_with(".tga")
			or path_lower.ends_with(".bmp")
	):
		# This method handles everything, from format detection based on
		# file extension to reading the file from disk. If you need error handling
		# or more control (such as changing the scale SVG is loaded at),
		# use the `load_*_from_buffer()` (where `*` is a file extension)
		# and `load_svg_from_string()` methods from the Image class.
		var image := Image.load_from_file(path)
		reset_visibility()
		export_file_dialog.filters = ["*.png ; PNG Image", "*.jpg, *.jpeg ; JPEG Image", "*.webp ; WebP Image"]
		texture_viewer.visible = true
		texture_viewer.texture = ImageTexture.create_from_image(image)

	# Audio.
	# Run-time MP3 and WAV loading aren't supported by the engine yet.
	elif path_lower.ends_with(".ogg"):
		# `AudioStreamOggVorbis.load_from_buffer()` can alternatively be used
		# if you have Ogg Vorbis data in a PackedByteArray instead of a file.
		audio_stream_player.stream = AudioStreamOggVorbis.load_from_file(path)
		reset_visibility()
		export_button.disabled = true
		audio_player.visible = true

	# 3D scenes.
	elif path_lower.ends_with(".gltf") or path_lower.ends_with(".glb"):
		# GLTFState is used by GLTFDocument to store the loaded scene's state.
		# GLTFDocument is the class that handles actually loading glTF data into a Godot node tree,
		# which means it supports glTF features such as lights and cameras.
		var gltf_document := GLTFDocument.new()
		var gltf_state := GLTFState.new()
		var error := gltf_document.append_from_file(path, gltf_state)
		if error == OK:
			scene_viewer_root_node = gltf_document.generate_scene(gltf_state)
			reset_visibility()
			scene_viewer.add_child(scene_viewer_root_node)
			export_file_dialog.filters = ["*.gltf ; glTF Text Scene", "*.glb ; glTF Binary Scene"]
			scene_viewer.visible = true
		else:
			show_error('Couldn\'t load "%s" as a glTF scene (error code: %s).' % [path.get_file(), error_string(error)])

	# Fonts.
	elif (
			path_lower.ends_with(".ttf")
			or path_lower.ends_with(".otf")
			or path_lower.ends_with(".woff")
			or path_lower.ends_with(".woff2")
			or path_lower.ends_with(".pfb")
			or path_lower.ends_with(".pfm")
			or path_lower.ends_with(".fnt")
			or path_lower.ends_with(".font")
	):
		var font_file := FontFile.new()
		if path_lower.ends_with(".fnt") or path_lower.ends_with(".font"):
			font_file.load_bitmap_font(path)
		else:
			font_file.load_dynamic_font(path)

		if not font_file.data.is_empty():
			font_viewer.add_theme_font_override("font", font_file)
			reset_visibility()
			font_viewer.visible = true
			export_button.disabled = true
		else:
			show_error('Couldn\'t load "%s" as a font.' % path.get_file())

	# ZIP archives.
	elif path_lower.ends_with(".zip"):
		# This supports any ZIP file, including files generated by Godot's "Export PCK/ZIP" functionality
		# (although these will contain imported Godot resources rather than the original project files).
		#
		# Use `ProjectSettings.load_resource_pack()` to load PCK or ZIP files exported by Godot as
		# additional data packs. That approach is preferred for DLCs, as it makes interacting with
		# additional data packs seamless (virtual filesystem).
		zip_reader.open(path)
		var files := zip_reader.get_files()
		files.sort()
		export_file_dialog.filters = ["*.zip ; ZIP Archive"]
		reset_visibility()
		for file in files:
			zip_viewer_file_list.add_item(file, null)
			# Make folders disabled in the list.
			zip_viewer_file_list.set_item_disabled(-1, file.ends_with("/"))

		zip_viewer.visible = true

	# Fallback.
	else:
		# Open as plain text and display contents if possible.
		var file_contents := FileAccess.get_file_as_string(path)
		if file_contents.is_empty():
			show_error("File is empty or is a binary file.")
		else:
			plain_text_viewer_label.text = file_contents
			reset_visibility()
			plain_text_viewer.visible = true
