extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var randRotation = randf_range(-20, 20);
	var randSpeed = Vector3(randf_range(-7.0, 7.0),randf_range(-7.0, 7.0), 0);
	apply_torque_impulse(Vector3(0, 0, randRotation))
	apply_impulse(randSpeed)

