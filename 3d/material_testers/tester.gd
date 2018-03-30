extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const INTERP_SPEED = 2
var tester_index = 0
const ROT_SPEED = 0.15
var rot_x = 0
var rot_y = 0
var zoom = 0
const ZOOM_SPEED = 0.1
const ZOOM_MAX = 2.5

var hdrs=[
	{ path="res://schelde.hdr", name="Riverside"},
	{ path="res://lobby.hdr", name="Lobby"},
	{ path="res://park.hdr", name="Park"},
	{ path="res://night.hdr", name="Night"},
	{ path="res://experiment.hdr", name="Experiment"},
]

func _ready():
	for h in hdrs:	
		get_node("ui/bg").add_item(h.name)

func _unhandled_input(ev):

	if ev is InputEventMouseButton and ev.button_index == BUTTON_WHEEL_UP:
		if zoom < ZOOM_MAX:
			zoom += ZOOM_SPEED
			get_node("camera/base/rotation/camera").translation.z = -zoom

	if ev is InputEventMouseButton and ev.button_index == BUTTON_WHEEL_DOWN:
		if zoom > 0:
			zoom -= ZOOM_SPEED
			get_node("camera/base/rotation/camera").translation.z = -zoom
	
	if ev is InputEventMouseMotion and ev.button_mask & BUTTON_MASK_LEFT:
		rot_y += ev.relative.x * ROT_SPEED	
		rot_x += ev.relative.y * ROT_SPEED
		rot_y = clamp(rot_y, -180, 180)
		rot_x = clamp(rot_x, 0, 150)
		var t = Transform()
		t = t.rotated(Vector3(0, 0, 1), rot_x * PI / 180.0)
		t = t.rotated(Vector3(0, 1, 0), -rot_y * PI / 180.0)
		get_node("camera/base").transform.basis = t.basis
		
	
func _process(delta):
	var xform = get_node("testers").get_child(tester_index).get_node("MeshInstance").global_transform
	var p = xform.origin
	var r = Quat(xform.basis)
	var from_xform = get_node("camera").transform
	var from_p = from_xform.origin
	var from_r = Quat(from_xform.basis)
	
	p = from_p.linear_interpolate(p, INTERP_SPEED * delta)
	r = from_r.slerp(r, INTERP_SPEED * delta)
	
	var m = Transform(r)
	m.origin = p
	
	get_node("camera").transform = m
	get_node("ui/label").text = get_node("testers").get_child(tester_index).get_name()
			
	
func _on_prev_pressed():
	if tester_index > 0:
		tester_index -= 1


func _on_next_pressed():
	if tester_index < get_node("testers").get_child_count() -1:
		tester_index += 1


func _on_bg_item_selected( ID ):
	get_node("environment").environment.background_sky.panorama = load(hdrs[ID].path)
