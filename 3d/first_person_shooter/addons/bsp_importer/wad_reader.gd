@tool
extends Node

class_name WADReader

## Raw Data of the File
@export var data : PackedByteArray 

@export var entry_count : int
@export var table_offset : int

@export var directory : Dictionary
@export var resources : Dictionary

class MipTexInfo:
	var texture_string : String
	var texture_size : Vector2i
	var color_amt : int
	var color_palette : PackedColorArray
	var mip_offsets = []
	var mip_images = []

func dump_wad_to_textures(file : String):
	var header_title = read_wad(file)[0]
	if header_title == "WAD3":
		read_directory(file)
		create_resources()

func read_wad(file : String, verbose : bool = false) -> Array:
	data = FileAccess.get_file_as_bytes(file)
	directory = {}
	resources = {}
	# read header
	var header_title : String = data.slice(0, 4).get_string_from_ascii()
	entry_count = data.slice(4, 8).decode_u32(0)
	table_offset = data.slice(8, 12).decode_u32(0)
	
	if verbose:
		prints("Header Magic:", header_title)
		prints("Entry Count:", entry_count)
		prints("Table Offset:", table_offset)
		prints("File Size:", data.size())
	return [header_title, entry_count, table_offset, data.size()]

func has_texture(file : String, texture_name : String):
	read_wad(file, false)
	read_directory(file)
	return resources.has(texture_name)

func read_directory(file_name : String) -> Dictionary:
	directory.clear()
	for entry_index in entry_count:
		var offset : int = table_offset + (entry_index * 32)
		
		var f_off : int = data.slice(offset + 0, offset + 4).decode_u32(0) # Offset to the lump data from the beginning of the WAD file
		var f_siz : int = data.slice(offset + 4, offset + 8).decode_u32(0) # Size of the lump data on disk (can be compressed)
		var f_org : int = data.slice(offset + 8, offset + 12).decode_u32(0) # Original size of the lump data (uncompressed)
		
		var f_typ : int = data.slice(offset + 12, offset + 13).decode_u8(0) # 0x43: Miptex (texture) 0x40: Spray decal 0x42: QPic (simple image) 0x46: Font
		var f_cmp : bool = data.slice(offset + 13, offset + 14).decode_u8(0) == 1 # Compression flag (0 for uncompressed, 1 for compressed)
		
		var f_pad : PackedByteArray = data.slice(offset + 14, offset + 16) # dummy bytes
		var f_nam : String = data.slice(offset + 16, offset + 32).get_string_from_ascii() #  Null-terminated texture name
		
		directory[entry_index] = {
		"offset": f_off, 
		"disk_size": f_siz, 
		"original_size": f_org, 
		"type": f_typ, 
		"compressed": f_cmp, 
		"name": f_nam, 
		"file_name": file_name.get_file().to_lower().replace(".wad", "")
		}
		
		if not resources.has(f_nam.to_lower()):
			resources[f_nam.to_lower()] = directory[entry_index]
	return directory

func create_resources():
	
	var bc = 0
	for entry in directory.values():
		var miptexes = []
		
		match entry.type:
			67: # Miptex Image.
				load_texture(entry, "res://textures/", false)

func load_texture(entry : Dictionary, save_path : String, save_to_file := false) -> ImageTexture:
	var offset = entry.offset
	var mti = MipTexInfo.new()
	var texture_string = data.slice(offset + 0, offset + 16).get_string_from_ascii()
	prints("Loading Miptexture %s for %s" % [texture_string, entry.file_name])
	mti.texture_string = texture_string
	
	
	var width = data.slice(offset + 16, offset + 20).decode_u16(0)
	var height = data.slice(offset + 20, offset + 24).decode_u16(0)
	var texture_size = Vector2i(width, height)
	
	var mipmap_sizes = [
		texture_size,
		texture_size / 2,
		texture_size / 4,
		texture_size / 8
	]
	
	var total_mipmap_size : int = 0
	for size in mipmap_sizes:
		total_mipmap_size += size.x * size.y
	
	var mip_images = []
	var palette_offset = entry.offset + 24 + 4 * 4 + total_mipmap_size
	
	var color_amt : int = data.slice(palette_offset + 0, palette_offset + 2).decode_u16(0) # if this isnt 256, something is deeply wrong.
	var palette : PackedColorArray = []
	
	for index in color_amt:
		var o = palette_offset + 2 + (index * 3)
		var r = (float(data.slice(o + 0, o + 1).decode_u8(0)) / 255.0)
		var g = (float(data.slice(o + 1, o + 2).decode_u8(0)) / 255.0)
		var b = (float(data.slice(o + 2, o + 3).decode_u8(0)) / 255.0)
		palette.append(Color(r, g, b))
	
	var img = Image.create_empty(width, height, false, Image.FORMAT_RGB8)
	
	var mm_o = data.slice(offset + 24, offset + 24 + 4).decode_u32(0)
	for x in width:
		for y in height:
			var o = offset + mm_o + (y * texture_size.x + x)
			img.set_pixel(x, y, palette[data.slice(o, o+1).decode_u8(0)])
	
	if save_to_file: 
		img.save_png(save_path.to_lower())
	return ImageTexture.create_from_image(img)
