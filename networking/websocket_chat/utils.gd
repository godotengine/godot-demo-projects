extends Node

func encode_data(data, mode):
	if mode == WebSocketPeer.WRITE_MODE_TEXT:
		return data.to_utf8()
	return var2bytes(data)


func decode_data(data, is_string):
	if is_string:
		return data.get_string_from_utf8()
	return bytes2var(data)


func _log(node, msg):
	print(msg)
	node.add_text(str(msg) + "\n")
