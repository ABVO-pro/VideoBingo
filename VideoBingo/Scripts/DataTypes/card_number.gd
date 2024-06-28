class_name CardNumber

var number: int
var grid_coordinates: Vector2
var number_drawn: bool

func _init(p_number: int, p_grid_coordinates: Vector2, p_number_drawn: bool) -> void:
	number = p_number
	grid_coordinates = p_grid_coordinates
	number_drawn = p_number_drawn
