class_name Cell

enum Direction {
	N, NE, E, SE, S, SW, W, NW
}

enum CardinalDirection {
	N, E, S, W
}

enum EdgeType {
	Flat, Slope, Cliff
}

const OPPOSITES = {
	Cell.Direction.N:	Cell.Direction.S,
	Cell.Direction.NE:	Cell.Direction.NW,
	Cell.Direction.E:	Cell.Direction.W,
	Cell.Direction.SE:	Cell.Direction.SW,
	Cell.Direction.S:	Cell.Direction.N,
	Cell.Direction.SW:	Cell.Direction.SE,
	Cell.Direction.W:	Cell.Direction.E,
	Cell.Direction.NW:	Cell.Direction.NW
}

const CARDINAL_OPPOSITES = {
	Cell.CardinalDirection.N:	Cell.CardinalDirection.S,
	Cell.CardinalDirection.E:	Cell.CardinalDirection.W,
	Cell.CardinalDirection.S:	Cell.CardinalDirection.N,
	Cell.CardinalDirection.W:	Cell.CardinalDirection.E
}

const EQUIVALENT_DIRECTION = {
	Cell.CardinalDirection.N:	Cell.Direction.N,
	Cell.CardinalDirection.E:	Cell.Direction.E,
	Cell.CardinalDirection.S:	Cell.Direction.S,
	Cell.CardinalDirection.W:	Cell.Direction.W
}

const EQUIVALENT_CARDINAL_DIRECTION = {
	Cell.Direction.N:	Cell.CardinalDirection.N,
	Cell.Direction.E:	Cell.CardinalDirection.E,
	Cell.Direction.S:	Cell.CardinalDirection.S,
	Cell.Direction.W:	Cell.CardinalDirection.W
}

static func requires_connection_mesh(d: CardinalDirection) -> bool:
	return d <= Cell.CardinalDirection.E

static func requires_corner_mesh(d: CardinalDirection) -> bool:
	return d == Cell.CardinalDirection.N

static func opposite_dir(d: Direction) -> Direction:
	return Cell.OPPOSITES[d]

static func opposite_cardinal_dir(d: CardinalDirection) -> CardinalDirection:
	return Cell.CARDINAL_OPPOSITES[d]

static func next_dir(d: Direction) -> Direction:
	return (d + 1) % 8

static func next_cardinal_dir(d: CardinalDirection) -> CardinalDirection:
	return (d + 1) % 4

static func next_dir_from_cardinal(d: CardinalDirection) -> Direction:
	return next_dir(Cell.EQUIVALENT_DIRECTION[d])

static func prev_dir(d: Direction) -> Direction:
	if d == 0:
		return 7
	return (d - 1) % 8

static func prev_cardinal_dir(d: CardinalDirection) -> CardinalDirection:
	if d == 0:
		return 3
	return (d - 1) % 4

static func prev_dir_from_cardinal(d: CardinalDirection) -> Direction:
	return prev_dir(Cell.EQUIVALENT_DIRECTION[d])
