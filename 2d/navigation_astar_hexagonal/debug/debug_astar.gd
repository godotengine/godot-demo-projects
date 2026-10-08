extends Node2D

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR: Color = Color.WHITE
const OFFSET_POSITIONS = Vector2(10, 30)
const OFFSET_WEIGHT = Vector2(10, -10)

@export var map: Map

var _debug_connections = false
var _debug_position = false
var _debug_weights = false
var _debug_costs = false
var _debug_path = true

@onready var _font: Font = ThemeDB.fallback_font


func _process(_delta):
	queue_redraw()


func draw_arrow(src, dst, color, width, aa = true):
	var angle = 0.6
	var size_head = 20
	var head: Vector2 = (dst - src).normalized() * size_head
	draw_line(src, dst - head / 2, color, width, aa)
	draw_polygon(
			[dst, dst - head.rotated(angle), dst - head.rotated(-angle)], [color, color, color]
		)


func _draw():
	if _debug_connections:
		_draw_connections()
	if _debug_position:
		_draw_positions()
	if _debug_weights:
		_draw_weights()
	if _debug_costs:
		_draw_costs()
	if _debug_path:
		_draw_path()


func _draw_path():
	if not map._point_path:
		return
	var point_start: Vector2i = map._point_path[0]
	var point_end: Vector2i = map._point_path[len(map._point_path) - 1]

	var last_point = point_start
	for index in range(1, len(map._point_path)):
		var current_point = map._point_path[index]
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point


func _draw_weights():
	for id in map.astar_node.get_point_ids():
		var position_weight = map.astar_node.get_point_position(id)
		var cost = map.astar_node.get_point_weight_scale(id)
		draw_string(
				_font,
				position_weight + OFFSET_WEIGHT,
				str(cost),
				HORIZONTAL_ALIGNMENT_FILL,
				-1,
				16,
				Color.RED
			)


func _draw_positions():
	for id in map.astar_node.get_point_ids():
		var position_label = map.astar_node.get_point_position(id)
		var position_map = map.local_to_map(map.to_local(map.astar_node.get_point_position(id)))
		draw_string(
				_font,
				position_label + OFFSET_POSITIONS,
				str(position_map),
				HORIZONTAL_ALIGNMENT_FILL,
				-1,
				16,
				Color.RED
			)


func _draw_connections():
	for id in map.astar_node.get_point_ids():
		for id_con in map.astar_node.get_point_connections(id):
			var position_start = map.astar_node.get_point_position(id)
			var position_end = map.astar_node.get_point_position(id_con)
			var direction = position_end - position_start
			draw_arrow(
					position_start,
					position_end - direction / 4.0,
					Color(0.0, 1.0, 1.0, 1.0),
					BASE_LINE_WIDTH * 2,
					true
				)


func _draw_costs():
	for id in map.astar_node.get_point_ids():
		for id_con in map.astar_node.get_point_connections(id):
			var position_cost_start = map.astar_node.get_point_position(id)
			var position_cost_end = map.astar_node.get_point_position(id_con)
			var cost = map.astar_node._compute_cost(id, id_con)
			draw_string(
					_font,
					(position_cost_start + position_cost_end) / 2.0,
					str("%.2f" % cost),
					HORIZONTAL_ALIGNMENT_CENTER,
					-1,
					16,
					Color.PINK
				)


func _on_d_path_toggled(toggled_on):
	_debug_path = toggled_on


func _on_d_costs_toggled(toggled_on):
	_debug_costs = toggled_on


func _on_d_positions_toggled(toggled_on):
	_debug_position = toggled_on


func _on_d_connections_toggled(toggled_on):
	_debug_connections = toggled_on


func _on_d_weights_toggled(toggled_on):
	_debug_weights = toggled_on
