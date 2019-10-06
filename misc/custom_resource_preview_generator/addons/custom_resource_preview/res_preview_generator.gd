tool
extends EditorResourcePreviewGenerator

func handles(type):
	# Our custom Resource is of type Resource
	# We will check later if we want to create the custom preview for that resource or not
	return type == "Resource"
	
func can_generate_small_preview():
	# Let's tell Godot that this generator is going to generate the smaller previews too.
	return true
	
func generate_small_preview_automatically():
	# But we are actually letting Godot do that for ourselves
	return true

func generate(from, size):
	# If the resource isn't our MyItem resource return null so other generators can work on it
	if not from is MyItem: return null
	
	# If our MyItem resource doesn't have an icon return null
	if not from.icon: return null
	
	# Here we get the data of the icon. In this example we aren't taking into account the
	# different texture classes there are and we will take the whole image
	# This wouldn't work with an AnimatedTexture or AtlasTexture
	var img:Image = from.icon.get_data()
		
	# If we don't have an image, let's bail out
	if not img: 
		print("Error getting the icon image data.")
		return null
		
	# Let's resize the image to the size Godot's asking us
	var scale = size / img.get_size()
	var factor = min(scale.x, scale.y)
	var final_size = img.get_size() * factor
	print("Generating a thumbnail of size %s from the original %s" % [size, img.get_size()])
	img.resize(final_size.x, final_size.y, Image.INTERPOLATE_LANCZOS)	
	
	# Finally, we create the texture that we will return
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	
	return tex
