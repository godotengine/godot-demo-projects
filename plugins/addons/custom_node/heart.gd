@tool
extends Node2D

const HEART_TEXTURE := preload("res://addons/custom_node/heart.png")


func _draw() -> void:
	draw_texture(HEART_TEXTURE, -HEART_TEXTURE.get_size() / 2)


func _get_item_rect() -> Rect2:
	return Rect2(-HEART_TEXTURE.get_size() / 2, HEART_TEXTURE.get_size())
