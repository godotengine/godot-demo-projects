extends Node

const NOISE_SCALE: float = 12
const HASH_GRID_SIZE: int = 256
const HASH_GRID_SCALE: float = 0.25

var hash_grid: Array[float] = []
var _n1: Noise
var _n2: Noise
var _n3: Noise
var _rng: RandomNumberGenerator

func _ready():
	var noise_seed = randi()
	self._n1 = _get_noise(noise_seed)
	self._n2 = _get_noise(noise_seed + 1)
	self._n3 = _get_noise(noise_seed + 2)
	
	self._rng = RandomNumberGenerator.new()
	self._rng.seed = noise_seed
	
	self.hash_grid.resize(self.HASH_GRID_SIZE * self.HASH_GRID_SIZE)
	for i in range(self.hash_grid.size()):
		self.hash_grid[i] = self._rng.randf()

func sample(v: Vector3) -> Vector3:
	var v2: Vector3 = v * self.NOISE_SCALE
	var x: float = clampf(inverse_lerp(-1.0, 1.0, self._n1.get_noise_3dv(v2)), 0.0, 1.0)
	var y: float = clampf(inverse_lerp(-1.0, 1.0, self._n2.get_noise_3dv(v2)), 0.0, 1.0)
	var z: float = clampf(inverse_lerp(-1.0, 1.0, self._n3.get_noise_3dv(v2)), 0.0, 1.0)
	return Vector3(x, y, z)

func sample_hash_grid(v: Vector3) -> float:
	var x: int = clamp(int(v.x * self.HASH_GRID_SCALE) % self.HASH_GRID_SIZE, 0, self.HASH_GRID_SIZE)
	var z: int = clamp(int(v.z * self.HASH_GRID_SCALE) % self.HASH_GRID_SIZE, 0, self.HASH_GRID_SIZE)
	var index: int = v.x + v.z * self.HASH_GRID_SIZE
	return self.hash_grid[index]

func _get_noise(seed: int) -> Noise:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = seed
	noise.frequency = 0.04
	noise.fractal_octaves = 4
	noise.fractal_lacunarity = 1
	noise.fractal_gain = 0.5
	return noise
