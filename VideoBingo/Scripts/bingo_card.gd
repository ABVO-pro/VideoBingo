@tool
class_name BingoCard
extends PanelContainer
##[Warning: @tool script][br]Contains the bingo card's size, grid and functions to reset and resize it. Also contains a helper function used to determine if a drawn number is in the card.

##Emitted when the number drawn is present in the card.
signal card_number_drawn(card_number: CardNumber)
##Emitted when the card size is altered.
signal card_size_changed(new_size: MyEnums.card_size_enum)

##The card slot scene, used to populate the card grid.
var card_slot_scene: PackedScene = preload("res://Scenes/Card/card_slot.tscn")
##An array of [param CardNumber]s, storing the card number's grid coordinates, number and wether they've already been drawn.
var card_numbers: Array[CardNumber]

##The card grid's size.
@export var card_size: MyEnums.card_size_enum:
	set(value):
		card_size = value
		if (is_instance_valid(card_grid)):
			_update_card()
			emit_signal("card_size_changed", value)

##The card's grid container.
@onready var card_grid: GridContainer = get_node("GridMarginContainer/CardGrid")

func _ready() -> void:
	_update_card()

##Helper function used the return the total number of slots in the card according to the card size enum.
func get_card_size() -> int:
	match card_size:
		MyEnums.card_size_enum.SMALL:
			return 12
		MyEnums.card_size_enum.MEDIUM_VERTICAL, MyEnums.card_size_enum.MEDIUM_HORIZONTAL:
			return 15
		MyEnums.card_size_enum.LARGE:
			return 25
		_:
			#Hack to halt execution since GDScript doesn't have exceptions
			@warning_ignore("assert_always_false")
			assert(1 == 2, "The card size isn't tested: %s" % [card_size])
			return 0

##Update the card's grid size according to the [param card_size].
func _update_card() -> void:
	match card_size:
		MyEnums.card_size_enum.SMALL:
			_resize_card(3, 12)
		MyEnums.card_size_enum.MEDIUM_VERTICAL:
			_resize_card(3, 15)
		MyEnums.card_size_enum.MEDIUM_HORIZONTAL:
			_resize_card(5, 15)
		MyEnums.card_size_enum.LARGE:
			_resize_card(5, 25)
		_:
			push_error("The card size isn't tested: %s" % [card_size])
			return

##Resizes the card's grid.
func _resize_card(columns: int, total_slots: int) -> void:
	#Clear the card slots
	for node in card_grid.get_children():
		node.queue_free()
	
	#Instantiate new card slots
	for i in total_slots:
		var new_slot: PanelContainer = card_slot_scene.instantiate()
		card_grid.add_child(new_slot)
	
	#Setup the new card layout
	card_grid.columns = columns

##Populate the [param card_numbers] array with the numbers in the card.
func _instantiate_card_numbers_dictionary(columns: int, drawn_numbers: Array[int]) -> void:
	var column: int = 1
	var row: int = 1
	
	for i in drawn_numbers:
		var number_coord: Vector2 = Vector2(column, row)
		card_numbers.append(CardNumber.new(i, number_coord, false))
		
		column += 1
		if (column > columns):
			column = 1
			row += 1
		
	for card_number: CardNumber in card_numbers:
		print("coord: %s | number: %s | number drawn: %s" % [card_number.grid_coordinates, card_number.number, card_number.number_drawn])

##Clears the card and generates a new set of numbers.
func generate_card_numbers(ball_numbers: Array[int]) -> void:
	card_numbers.clear()
	var sliced_array: Array[int] = ball_numbers.slice(0,get_card_size())
	sliced_array.sort()
	print("Sliced and shuffled the number array! size: %s numbers: %s" % [sliced_array.size() ,sliced_array])
	_instantiate_card_numbers_dictionary(card_grid.columns, sliced_array)
	
	for i in card_grid.get_children().size():
		card_grid.get_child(i).get_node("CardLabel").text = str(sliced_array[i])
		card_grid.get_child(i).get_node("TextureRect").self_modulate = Color.WHITE

##Checks if the number drawn from the pool is present in the card.
##[br]If so, change that number's slot colour, text and emit the [param card_number_drawn] signal.
func check_if_drawn_number_is_in_card(drawn_number: int) -> bool:
	for i in card_numbers.size():
		if(card_numbers[i].number == drawn_number):
			var card_slot: PanelContainer = card_grid.get_child(i)
			card_slot.get_node("TextureRect").self_modulate = Color.DARK_ORANGE
			card_slot.get_node("CardLabel").text = "X"
			
			card_numbers[i].number_drawn = true
			
			emit_signal("card_number_drawn", card_numbers[i])
			return true
	return false
