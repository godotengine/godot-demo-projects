extends RefCounted
class_name BspClipper

# from https://github.com/gongpha/gdQmapbsp/blob/master/addons/qmapbsp/util/clipper.gd
# Only necessary if you're using Godot 4.1 or older and don't have access to the
# Geometry3D.compute_convex_mesh_points function.

# from wootguy's bspguy
# 670fca408b7d376b28da97daa323aade2ea649d7 src/editor/Clipper.cpp

const TESTMAX := 5555
const EPS := 0.000001

var vertices : PackedVector3Array
var edges : Array[Vector4i] # [v0, v1, f0, f1]...
var faces : Array[Array] # [edge_ids : PIA32, normal : Vector3]...

var verts_v : PackedByteArray
var edges_v : PackedByteArray
var faces_v : PackedByteArray

var verts_o : PackedInt32Array

func clip_plane(p : Plane) -> bool :
	p.normal *= -1
	p.d *= -1
	var res := clip_vertices(p)
	if res == -1 : return true
	if res == 1 : return false
	clip_edges(p)
	clip_faces(p)
	return false
	
func clip_planes(planes : Array[Plane]) -> void :
	for p in planes :
		if clip_plane(p) : break
	filter_and_clean()
	
func filter_and_clean() -> void :
	var vvv : PackedVector3Array
	for i in faces.size() :
		if !faces_v[i] : continue
		for j in faces[i][0] :
			var edge : Vector4i = edges[j]
			if verts_v[edge.x] : vvv.append(vertices[edge.x])
			if verts_v[edge.y] : vvv.append(vertices[edge.y])
			
	vertices = vvv
	
	verts_v.clear()
	edges_v.clear()
	faces_v.clear()
	verts_o.clear()
		
func clip_vertices(plane : Plane) -> int :
	var pos := 0
	var neg := 0
	for i in vertices.size() :
		if verts_v[i] == 0 : continue
		
		var dist := plane.distance_to(vertices[i])
		
		if dist >= EPS : pos += 1
		elif dist < EPS :
			neg += 1
			verts_v[i] = 0
	if neg == 0 : return 1
	if pos == 0 : return -1
	return 0
	
func clip_edges(plane : Plane) -> void :
	for i in edges.size() :
		var e : Vector4i = edges[i]
		var v0 := e[0]
		var v1 := e[1]
		
		if edges_v[i] :
			var d0 := plane.distance_to(vertices[v0])
			var d1 := plane.distance_to(vertices[v1])
			
			if d0 <= 0 and d1 <= 0 :
				for k in 2 :
					var face : Array = faces[e[2 + k]]
					var f : int = face[0].find(i)
					if f != -1 :
						face[0].remove_at(f)
					if face[0].is_empty() :
						faces_v[e[2 + k]] = 0
				edges_v[i] = 0
				continue
			if d0 >= 0 and d1 >= 0 :
				continue
			var t := d0 / (d0 - d1)
			var v := vertices[v0].lerp(vertices[v1], t)
			vertices.append(v)
			verts_v.append(1)
			verts_o.append(0)
			if d0 > 0 :
				e[1] = vertices.size() - 1
			else :
				e[0] = vertices.size() - 1
			edges[i] = e
				
func clip_faces(plane : Plane) -> void :
	var closef := [PackedInt32Array(), plane.normal * -1]
	var fsize := faces.size()
	for i in fsize :
		if faces_v[i] == 1 :
			var face : Array = faces[i]
			for j in face[0].size() :
				var edge : Vector4i = edges[face[0][j]]
				verts_o[edge[0]] = 0
				verts_o[edge[1]] = 0
			var ref := PackedInt32Array([-1, -1])
			
			if get_open_polyline(face, ref) :
				var nedge := Vector4i(ref[0], ref[1], i, fsize)
				edges.append(nedge)
				edges_v.append(1)
				face[0].append(edges.size() - 1)
				closef[0].append(edges.size() - 1)
	faces.append(closef)
	faces_v.append(1)
			
func get_open_polyline(face : Array, ref : PackedInt32Array) -> bool :
	for i in face[0].size() :
		var edge : Vector4i = edges[face[0][i]]
		verts_o[edge[0]] += 1
		verts_o[edge[1]] += 1
	for i in face[0].size() :
		var edge : Vector4i = edges[face[0][i]]
		var v0 := edge[0]
		var v1 := edge[1]
		if verts_o[v0] == 1 :
			if ref[0] == -1 :
				ref[0] = v0
			elif ref[1] == -1 :
				ref[1] = v0
		if verts_o[v1] == 1 :
			if ref[0] == -1 :
				ref[0] = v1
			elif ref[1] == -1 :
				ref[1] = v1
	return ref[0] != -1 and ref[1] != -1
			
func begin(bound := AABB(
	-Vector3(TESTMAX, TESTMAX, TESTMAX),
	Vector3(TESTMAX, TESTMAX, TESTMAX) * 2.0,
)) -> void :
	vertices = [
		bound.position,
		Vector3(bound.end.x, bound.position.y, bound.position.z),
		Vector3(bound.end.x, bound.end.y, bound.position.z),
		Vector3(bound.position.x, bound.end.y, bound.position.z),
		
		Vector3(bound.position.x, bound.position.y, bound.end.z),
		Vector3(bound.end.x, bound.position.y, bound.end.z),
		bound.end,
		Vector3(bound.position.x, bound.end.y, bound.end.z),
	]
	verts_v.resize(8)
	verts_v.fill(1)
	verts_o.resize(8)
	verts_o.fill(0.0)
	
	edges = [
		Vector4i(0, 1, 0, 5),
		Vector4i(0, 4, 0, 2),
		Vector4i(4, 5, 0, 4),
		Vector4i(5, 1, 0, 3),
		
		Vector4i(3, 2, 1, 5),
		Vector4i(3, 7, 1, 2),
		Vector4i(6, 7, 1, 4),
		Vector4i(2, 6, 1, 3),
		
		Vector4i(0, 3, 2, 5),
		Vector4i(4, 7, 2, 4),
		Vector4i(1, 2, 3, 5),
		Vector4i(5, 6, 3, 4)
	]
	edges_v.resize(12)
	edges_v.fill(1)
	faces = [
		[PackedInt32Array([0, 1,  2,  3]), Vector3( 0, -1,  0)],
		[PackedInt32Array([4, 5,  6,  7]), Vector3( 0,  1,  0)],
		[PackedInt32Array([1, 5,  8,  9]), Vector3(-1,  0,  0)],
		[PackedInt32Array([3, 7, 10, 11]), Vector3( 1,  0,  0)],
		[PackedInt32Array([2, 6,  9, 11]), Vector3( 0,  0,  1)],
		[PackedInt32Array([0, 4,  8, 10]), Vector3( 0,  0, -1)]
	]
	faces_v.resize(6)
	faces_v.fill(1)
