extends StaticBody3D
@export var reset_position = Vector3(0.0, 0.132, -0.675)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		queue_free()
		print("deleted ball")
	if body.is_in_group("Cue Ball"):
		body.global_transform.origin = reset_position
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		print("respawned ball")
