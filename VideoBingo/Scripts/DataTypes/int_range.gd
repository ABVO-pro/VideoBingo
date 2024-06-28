@tool
class_name IntRange
extends Resource

@export var min_value: int = 1:
	set(value):
		if(value > max_value):
			push_warning("The minimum value of this range must be lower than the maximum value.")
		else:
			min_value = value

@export var max_value: int = 60:
	set(value):
		if(value < min_value):
			push_warning("The maximum value of this range must be higher than the minimum value.")
		else:
			max_value = value

func _init(p_min_value: int = 1, p_max_value: int = 60) -> void:
	min_value = p_min_value
	max_value = p_max_value
