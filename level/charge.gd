extends Control

@onready var charge_bar = $ChargeBar

var current_power = 0.0

func update_charge(power: float, max_power: float):
	if not current_power >= max_power:
		current_power = power

	charge_bar.max_value = max_power
	charge_bar.value = power
