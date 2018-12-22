tool
extends ResourceFormatLoader
class_name AlpacaLoader


const Alpaca = preload("alpaca.gd")
const EXTENSION = "alpaca"


func get_recognized_extensions():
	return PoolStringArray([EXTENSION])


func get_resource_type(path):
	var ext = path.get_extension().to_lower()
	if ext == EXTENSION:
		return "Resource"
	return ""


func handles_type(typename):
	return typename == "Resource"


func load(path, original_path):
	print("Loading alpaca at ", path)
	var f = File.new()
	f.open(path, File.READ)
	var data = f.get_as_text()
	f.close()
	var res = Alpaca.new()
	res.data = data
	return res


# The following can be implemented in case the resource also references others,
# so the editor will be able to update them in case of a move or rename

#func get_dependencies(path, add_types):
#	return PoolStringArray()


#func rename_dependencies(path, renames):
#	return OK

