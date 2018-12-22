tool
extends ResourceFormatSaver
class_name AlpacaSaver

const Alpaca = preload("alpaca.gd")
const EXTENSION = "alpaca"


func get_recognized_extensions(res):
	if res != null and res is Alpaca:
		return PoolStringArray([EXTENSION])
	return PoolStringArray()


func recognize(res):
	return res is Alpaca


func save(path, resource, flags):
	print("Saving alpaca at ", path)
	var f = File.new()
	f.open(path, File.WRITE)
	f.store_string(resource.data)
	f.close()

