extends RigidBody3D

@export var stop_threshold = 0.02

func _physics_process(_delta):
	if linear_velocity.length() < stop_threshold:
		linear_velocity = Vector3.ZERO
	if angular_velocity.length() < stop_threshold:
		angular_velocity = Vector3.ZERO
