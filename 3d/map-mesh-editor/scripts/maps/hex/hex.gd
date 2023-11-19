class_name Hex

enum Direction {
	NE, E, SE, SW, W, NW
}

enum EdgeType {
	Flat, Slope, Cliff
}

const OPPOSITES = {
	Direction.NE: Direction.NW,
	Direction.E: Direction.W,
	Direction.SE: Direction.SW,
	Direction.SW: Direction.SE,
	Direction.W: Direction.E,
	Direction.NW: Direction.NW
}

static func opposite_dir(d: Direction) -> Direction:
	return Hex.OPPOSITES[d]

static func next_dir(d: Direction) -> Direction:
	return (d + 1) % 6

static func prev_dir(d: Direction) -> Direction:
	return (d - 1) % 6
