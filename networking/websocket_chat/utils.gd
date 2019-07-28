extends Node

func encode_data(data, mode):
	return data.to_utf8() if mode == WebSocketPeer.WRITE_MODE_TEXT else var2bytes(data)

func decode_data(data, is_string):
	return data.get_string_from_utf8() if is_string else bytes2var(data)

func _log(node, msg):
	print(msg)
	node.add_text(str(msg) + "\n")
