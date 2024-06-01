extends Node

# Below are a number of helper functions that show how you can use the raw sensor data to determine the orientation
# of your phone/device. The cheapest phones only have an accelerometer only the most expensive phones have all three.
# Note that none of this logic filters data. Filters introduce lag but also provide stability. There are plenty
# of examples on the internet on how to implement these. I wanted to keep this straight forward.

# We draw a few arrow objects to visualize the vectors and two cubes to show two implementation for orientating
# these cubes to our phones orientation.
# This is a 3D example however reading the phones orientation is also invaluable for 2D

## Returns a rotation matrix based on a direction vector. As our arrows are cylindrical, we don't
## care about the rotation around this axis.
func get_basis_for_arrow(p_vector: Vector3) -> Basis:
	var rotate := Basis()

	# As our arrow points up, Y = our direction vector.
	rotate.y = p_vector.normalized()

	# Get an arbitrary vector we can use to calculate our other two vectors.
	var v := Vector3(1.0, 0.0, 0.0)
	if abs(v.dot(rotate.y)) > 0.9:
		v = Vector3(0.0, 1.0, 0.0)

	# Use our vector to get a vector perpendicular to our two vectors.
	rotate.x = rotate.y.cross(v).normalized()

	# And the cross product again gives us our final vector perpendicular to our previous two vectors.
	rotate.z = rotate.x.cross(rotate.y).normalized()

	return rotate


## Combines the magnetometer reading with the gravity vector to get a vector that points due north.
func calc_north(p_grav: Vector3, p_mag: Vector3) -> Vector3:
	# Always use normalized vectors!
	p_grav = p_grav.normalized()

	# Calculate east (or is it west) by getting our cross product.
	# The cross product of two normalized vectors returns a vector that
	# is perpendicular to our two vectors.
	var east := p_grav.cross(p_mag.normalized()).normalized()

	# Cross again to get our horizon-aligned north.
	return east.cross(p_grav).normalized()


## Returns an orientation matrix using the magnetometer and gravity vector as inputs.
func orientate_by_mag_and_grav(p_mag: Vector3, p_grav: Vector3) -> Basis:
	var rotate := Basis()

	# As always, normalize!
	p_mag = p_mag.normalized()

	# Gravity points down, so - gravity points up!
	rotate.y = -p_grav.normalized()

	# Cross products with our magnetic north gives an aligned east (or west, I always forget).
	rotate.x = rotate.y.cross(p_mag)

	# And cross product again and we get our aligned north completing our matrix.
	rotate.z = rotate.x.cross(rotate.y)

	return rotate


## Takes our gyro input and updates an orientation matrix accordingly.
## The gyro is special as this vector does not contain a direction but rather a
## rotational velocity. This is why we multiply our values with delta.
func rotate_by_gyro(p_gyro: Vector3, p_basis: Basis, p_delta: float) -> Basis:
	var rotate := Basis()

	rotate = rotate.rotated(p_basis.x, -p_gyro.x * p_delta)
	rotate = rotate.rotated(p_basis.y, -p_gyro.y * p_delta)
	rotate = rotate.rotated(p_basis.z, -p_gyro.z * p_delta)

	return rotate * p_basis


## Returns the basis corrected for drift by our gravity vector.
func drift_correction(p_basis: Basis, p_grav: Vector3) -> Basis:
	# As always, make sure our vector is normalized but also invert as our gravity points down.
	var real_up := -p_grav.normalized()

	# Start by calculating the dot product. This gives us the cosine angle between our two vectors.
	var dot := p_basis.y.dot(real_up)

	# If our dot is 1.0, we're good.
	if dot < 1.0:
		# The cross between our two vectors gives us a vector perpendicular to our two vectors.
		var axis := p_basis.y.cross(real_up).normalized()
		var correction := Basis(axis, acos(dot))
		p_basis = correction * p_basis

	return p_basis


func _process(delta: float) -> void:
	# Get our data from the engine's sensor readings.
	var acc := Input.get_accelerometer()
	var grav := Input.get_gravity()
	var mag := Input.get_magnetometer()
	var gyro := Input.get_gyroscope()

	# Show our base values.
	var format := "%.05f"

	%AccX.text = format % acc.x
	%AccY.text = format % acc.y
	%AccZ.text = format % acc.z

	%GravX.text = format % grav.x
	%GravY.text = format % grav.y
	%GravZ.text = format % grav.z

	%MagX.text = format % mag.x
	%MagY.text = format % mag.y
	%MagZ.text = format % mag.z

	%GyroX.text = format % gyro.x
	%GyroY.text = format % gyro.y
	%GyroZ.text = format % gyro.z

	# Check if we have all needed data.
	if grav.length() < 0.1:
		if acc.length() < 0.1:
			# We don't have either...
			grav = Vector3(0.0, -1.0, 0.0)
		else:
			# The gravity vector is calculated by the OS by combining the other sensor inputs.
			# If we don't have a gravity vector, from now on, use the accelerometer...
			grav = acc

	if mag.length() < 0.1:
		mag = Vector3(1.0, 0.0, 0.0)

	# Update our arrow showing gravity.
	$Arrows/AccelerometerArrow.transform.basis = get_basis_for_arrow(grav)

	# Update our arrow showing our magnetometer.
	# Note that in absence of other strong magnetic forces this will point to magnetic north,
	# which is not horizontal thanks to the earth being round.
	$Arrows/MagnetoArrow.transform.basis = get_basis_for_arrow(mag)

	# Calculate our north vector and show that.
	var north := calc_north(grav, mag)
	$Arrows/NorthArrow.transform.basis = get_basis_for_arrow(north)

	# Combine our magnetometer and gravity vector to position our box. This will be fairly accurate
	# but our magnetometer can be easily influenced by magnets. Cheaper phones often don't have gyros
	# so it is a good backup.
	var mag_and_grav: MeshInstance3D = $Boxes/MagAndGrav
	mag_and_grav.transform.basis = orientate_by_mag_and_grav(mag, grav).orthonormalized()

	# Using our gyro and do a drift correction using our gravity vector gives the best result.
	var gyro_and_grav: MeshInstance3D = $Boxes/GyroAndGrav
	var new_basis := rotate_by_gyro(gyro, gyro_and_grav.transform.basis, delta).orthonormalized()
	gyro_and_grav.transform.basis = drift_correction(new_basis, grav)
