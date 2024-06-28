class_name PrizeManager
extends Node
##Contains the prizes won so far and helper functions to calculate wether a new prize is won, emitting a signal corresponding to the prize in that case.

##This signal is emitted when a row prize victory is detected
signal row_prize_earned()
##This signal is emitted when a column prize victory is detected
signal column_prize_earned()
##This signal is emitted when the corner prize victory is detected
signal corner_prize_earned()
##This signal is emitted when the bingo prize victory is detected
signal bingo_prize_earned()

##Wether the bingo prize has been won
var is_bingo_prize_earned: bool = false
##Wether the corner prize has been won
var is_corner_prize_earned: bool = false
##This array stores the which row prizes have been won
var are_row_prizes_earned: Array[bool] = []
##This array stores the which column prizes have been won
var are_column_prizes_earned: Array[bool] = []

##Resets the prizes won, reverting them all to false and populating the row and column arrays with new elements according to the bingo card's size.
func reset_prizes_earned(p_columns: int, p_rows: int) -> void:
	is_bingo_prize_earned = false
	is_corner_prize_earned = false
	
	are_column_prizes_earned.clear()
	for i in p_columns:
		are_column_prizes_earned.append(false)
	
	are_row_prizes_earned.clear()
	for i in p_rows:
		are_row_prizes_earned.append(false)

##Tests wether any new prizes were won.
func test_prizes(card_numbers: Array[CardNumber], p_columns: int) -> void:
	var number_dictionary: Dictionary = _map_drawn_numbers_to_dictionary(card_numbers)
	test_bingo(card_numbers)
	test_corner(number_dictionary, p_columns)
	test_row(number_dictionary, p_columns)
	test_column(number_dictionary, p_columns)

##Tests wether the bingo prize was won.
func test_bingo(card_numbers: Array[CardNumber]) -> void:
	for card_number in card_numbers:
		if (card_number.number_drawn == false):
			return
	if (!is_bingo_prize_earned):
		is_bingo_prize_earned = true
		emit_signal("bingo_prize_earned")

##Tests wether the corner prize was won.
func test_corner(number_dictionary: Dictionary, p_columns: int) -> void:
	#We can safely ignore these warnings because the grid sizes are carefully selected from previously set values
	@warning_ignore("integer_division")
	var column_size: int = number_dictionary.size() / p_columns
	
	for i in column_size:
		if (number_dictionary[Vector2(1, i+1)] == false):
			return
		if (number_dictionary[Vector2(p_columns, i+1)] == false):
			return
	
	for i in p_columns:
		if (number_dictionary[Vector2(i+1, 1)] == false):
			return
		if (number_dictionary[Vector2(i+1, column_size)] == false):
			return
	
	if (!is_corner_prize_earned):
		is_corner_prize_earned = true
		emit_signal("corner_prize_earned")

##Tests wether a new row prize was won.
func test_row(number_dictionary: Dictionary, p_columns: int) -> void:
	#We can safely ignore these warnings because the grid sizes are carefully selected from previously set values
	@warning_ignore("integer_division")
	var column_size: int = number_dictionary.size() / p_columns
	
	for i in column_size:
		var row_has_prize: bool = true
		for j in p_columns:
			if (number_dictionary[Vector2(j+1,i+1)] == false):
				row_has_prize = false
		if(row_has_prize):
			if(!are_row_prizes_earned[i]):
				emit_signal("row_prize_earned")
				are_row_prizes_earned[i] = true

##Tests wether a new column prize was won.
func test_column(number_dictionary: Dictionary, p_columns: int) -> void:
	#We can safely ignore these warnings because the grid sizes are carefully selected from previously set values
	@warning_ignore("integer_division")
	var column_size: int = number_dictionary.size() / p_columns
	
	for i in p_columns:
		var column_has_prize: bool = true
		for j in column_size:
			if (number_dictionary[Vector2(i+1,j+1)] == false):
				column_has_prize = false
		if(column_has_prize):
			if(!are_column_prizes_earned[i]):
				emit_signal("column_prize_earned")
				are_column_prizes_earned[i] = true

##Maps the [param CardNumber]s array to a dictionary with the coordinates as keys to easily test prize patterns.
func _map_drawn_numbers_to_dictionary(card_numbers: Array[CardNumber]) -> Dictionary:
	var number_dictionary: Dictionary = {}
	for i in card_numbers.size():
		number_dictionary[card_numbers[i].grid_coordinates] = card_numbers[i].number_drawn
	return number_dictionary
