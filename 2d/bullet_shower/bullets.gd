extends Node2D
# This demo is an example of controling a high number of 2D objects with logic
# and collision without using nodes in the scene. This technique is a lot more
# efficient than using instancing and nodes, but requires more programming and
# is less visual. Bullets are managed together in the `bullets.gd` script.

const BULLET_COUNT = 500
const SPEED_MIN = 20
const SPEED_MAX = 80

const bullet_image = preload("res://bullet.png")

var bullets = []
var shape


class Bullet:
	var position = Vector2()
	var speed = 1.0
	# The body is stored as a RID, which is an "opaque" way to access resources.
	# With large amounts of objects (thousands or more), it can be significantly
	# faster to use RIDs compared to a high-level approach.
	var body = RID()


func _ready():
	randomize()

	shape = Physics2DServer.circle_shape_create()
	# Set the collision shape's radius for each bullet in pixels.
	Physics2DServer.shape_set_data(shape, 8)

	for _i in BULLET_COUNT:
		var bullet = Bullet.new()
		# Give each bullet its own speed.
		bullet.speed = rand_range(SPEED_MIN, SPEED_MAX)
		bullet.body = Physics2DServer.body_create()

		Physics2DServer.body_set_space(bullet.body, get_world_2d().get_space())
		Physics2DServer.body_add_shape(bullet.body, shape)

		# Place bullets randomly on the viewport and move bullets outside the
		# play area so that they fade in nicely.
		bullet.position = Vector2(
			rand_range(0, get_viewport_rect().size.x) + get_viewport_rect().size.x,
			rand_range(0, get_viewport_rect().size.y)
		)
		var transform2d = Transform2D()
		transform2d.origin = bullet.position
		Physics2DServer.body_set_state(bullet.body, Physics2DServer.BODY_STATE_TRANSFORM, transform2d)

		bullets.push_back(bullet)


func _process(_delta):
	# Order the CanvasItem to update every frame.
	update()


func _physics_process(delta):
	var transform2d = Transform2D()
	var offset = get_viewport_rect().size.x + 16
	for bullet in bullets:
		bullet.position.x -= bullet.speed * delta

		if bullet.position.x < -16:
			# The bullet has left the screen; move it back to the right.
			bullet.position.x = offset

		transform2d.origin = bullet.position

		Physics2DServer.body_set_state(bullet.body, Physics2DServer.BODY_STATE_TRANSFORM, transform2d)


# Instead of drawing each bullet individually in a script attached to each bullet,
# we are drawing *all* the bullets at once here.
func _draw():
	var offset = -bullet_image.get_size() * 0.5
	for bullet in bullets:
		draw_texture(bullet_image, bullet.position + offset)


# Perform cleanup operations (required to exit without error messages in the console).
func _exit_tree():
	for bullet in bullets:
		Physics2DServer.free_rid(bullet.body)

	Physics2DServer.free_rid(shape)
	bullets.clear()
