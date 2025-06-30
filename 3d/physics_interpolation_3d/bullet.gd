extends RigidBody3D

# How many ticks the bullet should last for.
const _max_life = 100

# Scale the bullet in over a tick so it doesn't appear out of nowhere.
const _appearance_life = 1

# The current lifetime tick of the bullet.
var _life = 0

var _enabled = false

func _ready() -> void:
	$CollisionShape3D.disabled = true

func _physics_process(_delta: float) -> void:
	# Start with physics collision disabled until the first tick.
	if !_enabled:
		$CollisionShape3D.disabled = false
		_enabled = true

	# Bullet gets older.
	_life += 1
	
	# How many ticks do we have left?
	var life_left = _max_life - _life
	
	# Scaling so the bullet goes from zero to full size during first appearance.
	var appearance_fract = min(float (_life) / float (_appearance_life), 1.0)
	
	# Scale the size of the bullet so it fades towards end of life.
	var fract = float (life_left) / float (_max_life)
	
	# Apply the appearance scaling.
	fract *= appearance_fract
	
	# Ensure scale is never zero, just in case the engine doesn't like zero scale.
	fract = max(fract, 0.0001)
	
	$Scaler.scale = Vector3(fract, fract, fract)
	
	# If we've reached the end queue for freeing,
	# the engine will clear up the bullet.
	if _life >= _max_life:
		queue_free()
