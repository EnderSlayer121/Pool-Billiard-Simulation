extends RigidBody3D

@export var speed = 0.3
@export var deceleration = 5.0
@export var rotation_speed = 0.2
var input_dir := Vector3.ZERO

@export var max_power = 0.3
@export var power_charge_speed = 0.2
@export var shoot_speed = 5.0
var current_power = 0.0
var is_charging := false
var is_shooting := false
var shot_distance
var shot_direction = Vector3.ZERO
var shot_start_pos = Vector3.ZERO
var original_position = Vector3.ZERO
var target_y_rotation := 0.0


@export var ui: Control


func _ready() -> void:
	original_position = global_transform.origin
	axis_lock_linear_y = true
	axis_lock_angular_x = true
	axis_lock_angular_z = true


# MAIN PHYSICS LOOP
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	cue_movement(state)
	cue_shooting(state, state.step)



func cue_movement(state: PhysicsDirectBodyState3D) -> void:
	input_dir.x = Input.get_axis("move_right", "move_left")
	input_dir.z = Input.get_axis("move_down", "move_up")

	var fwd := state.transform.basis * input_dir
	var lv := state.linear_velocity

	# Always keep cue on fixed height
	var t := state.transform
	t.origin.y = original_position.y
	state.transform = t

	if input_dir != Vector3.ZERO:
		lv.x = fwd.x * speed
		lv.z = fwd.z * speed
	else:
		lv.x = move_toward(lv.x, 0.0, deceleration * state.step)
		lv.z = move_toward(lv.z, 0.0, deceleration * state.step)
		

	state.linear_velocity = lv

	# Update original position ONLY when fully stopped
	if input_dir == Vector3.ZERO and lv.length() < 0.05 and not is_shooting and not is_charging:
		original_position = t.origin

	# Rotation
	var rot_input := Input.get_axis("rotate_right", "rotate_left")

	if rot_input:
	# Player turning → update the stored rotation value
		target_y_rotation += rot_input * rotation_speed * state.step
	elif rot_input == 0:
	# No input → freeze rotation to last known safe angle
		var basis := state.transform.basis
		basis = Basis.from_euler(Vector3(0, target_y_rotation, 0))
		state.transform.basis = basis


# -------------------------
#       SHOOTING
# -------------------------
func cue_shooting(state: PhysicsDirectBodyState3D, delta: float) -> void:
	# Begin charging
	if Input.is_action_just_pressed("shoot"):
		is_charging = true
		current_power = 0.0

	# Charge
	if is_charging and Input.is_action_pressed("shoot"):
		current_power += power_charge_speed * delta
		current_power = clamp(current_power, 0.0, max_power)
		ui.update_charge(current_power, max_power)

	# Release → begin shot
	if is_charging and Input.is_action_just_released("shoot"):
		is_charging = false
		is_shooting = true
		shot_distance = current_power
		shot_direction = -state.transform.basis.z.normalized()
		shot_start_pos = state.transform.origin
		ui.update_charge(0.0, max_power)

	# Shooting animation
	if is_shooting:
		var t := state.transform
		t.origin += shot_direction * shoot_speed * delta
		state.transform = t

		var traveled: float = t.origin.distance_to(shot_start_pos)
		if traveled >= shot_distance:
			is_shooting = false
			t.origin = original_position
			state.transform = t
