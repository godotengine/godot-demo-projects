extends Node2D
# This demo is an example of controling a high number of 2D objects with logic
# and collision without using nodes in the scene. This technique is a lot more
# efficient than using instancing and nodes, but requires more programming and
# is less visual. Bullets are managed together in the `bullets.gd` script.

const BULLET_COUNT = 500
const SPEED_MIN = 20
const SPEED_MAX = 80

const bullet_image := preload("res://bullet.png")

var bullets := []
var shape := RID()


class Bullet:
	var position := Vector2()
	var speed := 1.0
	# The body is stored as a RID, which is an "opaque" way to access resources.
	# With large amounts of objects (thousands or more), it can be significantly
	# faster to use RIDs compared to a high-level approach.
	var body := RID()


func _ready() -> void:
	shape = PhysicsServer2D.circle_shape_create()
	# Set the collision shape's radius for each bullet in pixels.
	PhysicsServer2D.shape_set_data(shape, 8)

	for _i in BULLET_COUNT:
		var bullet := Bullet.new()
		# Give each bullet its own random speed.
		bullet.speed = randf_range(SPEED_MIN, SPEED_MAX)
		bullet.body = PhysicsServer2D.body_create()

		PhysicsServer2D.body_set_space(bullet.body, get_world_2d().get_space())
		PhysicsServer2D.body_add_shape(bullet.body, shape)
		# Don't make bullets check collision with other bullets to improve performance.
		PhysicsServer2D.body_set_collision_mask(bullet.body, 0)

		# Place bullets randomly on the viewport and move bullets outside the
		# play area so that they fade in nicely.
		bullet.position = Vector2(
			randf_range(0, get_viewport_rect().size.x) + get_viewport_rect().size.x,
			randf_range(0, get_viewport_rect().size.y)
		)
		var transform2d := Transform2D()
		transform2d.origin = bullet.position
		PhysicsServer2D.body_set_state(bullet.body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform2d)

		bullets.push_back(bullet)


func _process(_delta: float) -> void:
	# Order the CanvasItem to update every frame.
	queue_redraw()


func _physics_process(delta: float) -> void:
	var transform2d := Transform2D()
	var offset := get_viewport_rect().size.x + 16
	for bullet: Bullet in bullets:
		bullet.position.x -= bullet.speed * delta

		if bullet.position.x < -16:
			# Move the bullet back to the right when it left the screen.
			bullet.position.x = offset

		transform2d.origin = bullet.position
		PhysicsServer2D.body_set_state(bullet.body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform2d)


# Instead of drawing each bullet individually in a script attached to each bullet,
# we are drawing *all* the bullets at once here.
func _draw() -> void:
	var offset := -bullet_image.get_size() * 0.5
	for bullet: Bullet in bullets:
		draw_texture(bullet_image, bullet.position + offset)


# Perform cleanup operations (required to exit without error messages in the console).
func _exit_tree() -> void:
	for bullet: Bullet in bullets:
		PhysicsServer2D.free_rid(bullet.body)

	PhysicsServer2D.free_rid(shape)
	bullets.clear()
