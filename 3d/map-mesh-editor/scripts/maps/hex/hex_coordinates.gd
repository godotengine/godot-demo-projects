class_name HexCoordinates extends MapCoordinates

func _init(xx: int, zz: int):
	self.x = xx
	self.z = zz
	self.y = -xx - zz;

static func from_offset_coords(xx: int, zz: int) -> MapCoordinates:
	var step: int = zz / 2
	return HexCoordinates.new(xx - step, zz)

static func from_position(pos: Vector3) -> MapCoordinates:
	# TODO this needs a lot of fixing, right now it barely works
	
	var xx: float = pos.x / (HexMetrics.INNER_RADIUS * 2.0)
	var yy: float = -xx;
	
	var offset: float = pos.z / (HexMetrics.OUTER_RADIUS * 3.0)
	xx -= offset
	yy -= offset
	
	var ix: int = floori(xx) if xx > 0 else roundi(xx)
	var iy: int = floori(yy) if yy > 0 else roundi(yy)
	var zz: float = -xx -yy
	var iz: int = floori(zz) if zz > 0 else roundi(zz)
	
	if (ix +iy + iz) != 0:
		var dx: float = absf(xx - ix)
		var dy: float = absf(yy - iy)
		var dz: float = absf(-xx -yy - iz)
		
		if dx > dy and dx > dz:
			ix = -iy - iz
		elif dz > dy:
			iz = -ix - iy
	
	return HexCoordinates.new(ix, iz)
