@tool
class_name PrizesContainer
extends GridContainer
##[Warning @tool script][br]The prize's previewer.
##[br]Stores the prize values and automatically adjusts, in-editor, the prize's previews to the bingo card's size.

##The prize card slot preview scene.
var prize_circle: PackedScene = preload("res://Scenes/Prizes/prize_pattern_circle.tscn")

##The value of a row prize.
@export var row_prize_value: int = 50:
	set(value):
		row_prize_value = value
		row_prize_slot.get_node("Prize Label").text = str(row_prize_value)

##The value of a column prize.
@export var column_prize_value: int = 50:
	set(value):
		column_prize_value = value
		column_prize_slot.get_node("Prize Label").text = str(column_prize_value)

##The value of the corner prize.
@export var corner_prize_value: int = 250:
	set(value):
		corner_prize_value = value
		corner_prize_slot.get_node("Prize Label").text = str(corner_prize_value)

##The value of the bingo prize.
@export var bingo_prize_value: int = 1000:
	set(value):
		bingo_prize_value = value
		bingo_prize_slot.get_node("Prize Label").text = str(bingo_prize_value)

##The bingo card node.
@onready var card: BingoCard = $"../../../../CardContainer/Card"

##The row prize slot container
@onready var row_prize_slot: PanelContainer = $"RowPrizeSlot"
##The column prize slot container
@onready var column_prize_slot: PanelContainer = $"ColumnPrizeSlot"
##The corner prize slot container
@onready var corner_prize_slot: PanelContainer = $"CornerPrizeSlot"
##The bingo prize slot container
@onready var bingo_prize_slot: PanelContainer = $"BingoPrizeSlot"

func _ready() -> void:
	_on_card_size_changed(card.card_size)
	card.card_size_changed.connect(_on_card_size_changed)

##Event handler for the [param card_size_changed] signal, updating the prize container's previews to the new bingo card size.
func _on_card_size_changed(new_size: MyEnums.card_size_enum) -> void:
	print("size changed: %s" % [new_size])
	match new_size:
		MyEnums.card_size_enum.SMALL:
			_update_prize_containers(3, 12)
		MyEnums.card_size_enum.MEDIUM_VERTICAL:
			_update_prize_containers(3, 15)
		MyEnums.card_size_enum.MEDIUM_HORIZONTAL:
			_update_prize_containers(5, 15)
		MyEnums.card_size_enum.LARGE:
			_update_prize_containers(5, 25)
		_:
			push_error("The card size isn't tested: %s" % [new_size])
			return

##Updates the prize previews to the new bingo card size.
func _update_prize_containers(grid_columns: int, total_slots: int) -> void:
	_update_row_prize_slot(grid_columns, total_slots)
	_update_column_prize_slot(grid_columns, total_slots)
	_update_corner_prize_slot(grid_columns, total_slots)
	_update_bingo_prize_slot(grid_columns, total_slots)

##Updates the row prize preview to the new bingo card size.
func _update_row_prize_slot(grid_columns: int, total_slots: int) -> void:
	row_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PrizeLabel").text = str(row_prize_value)
	var prize_grid: GridContainer = row_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PatternGrid")
	
	#Clear the prize grid slots
	for node in prize_grid.get_children():
		node.queue_free()
	
	#Instantiate new circle scenes
	for i in total_slots:
		var new_circle: TextureRect = prize_circle.instantiate()
		prize_grid.add_child(new_circle)
		if(i < grid_columns):
			new_circle.self_modulate = Color(0,0,0,1)
		else:
			new_circle.self_modulate = Color(0,0,0,.5)
	
	#Setup the new prize grid layout
	prize_grid.columns = grid_columns

##Updates the column prize preview to the new bingo card size.
func _update_column_prize_slot(grid_columns: int, total_slots: int) -> void:
	column_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PrizeLabel").text = str(column_prize_value)
	var prize_grid: GridContainer = column_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PatternGrid")
	
	#Clear the prize grid slots
	for node in prize_grid.get_children():
		node.queue_free()
	
	#Instantiate new circle scenes
	for i in total_slots:
		var new_circle: TextureRect = prize_circle.instantiate()
		prize_grid.add_child(new_circle)
		if(i % grid_columns == 0):
			new_circle.self_modulate = Color(0,0,0,1)
		else:
			new_circle.self_modulate = Color(0,0,0,.5)
	
	#Setup the new prize grid layout
	prize_grid.columns = grid_columns

##Updates the corner prize preview to the new bingo card size.
func _update_corner_prize_slot(grid_columns: int, total_slots: int) -> void:
	corner_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PrizeLabel").text = str(corner_prize_value)
	var prize_grid: GridContainer = corner_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PatternGrid")
	
	#Clear the prize grid slots
	for node in prize_grid.get_children():
		node.queue_free()
	
	#Instantiate new circle scenes
	for i in total_slots:
		var new_circle: TextureRect = prize_circle.instantiate()
		prize_grid.add_child(new_circle)
		if((i+1) % grid_columns == 0 or i >= total_slots - grid_columns or i % grid_columns == 0 or i < grid_columns):
			new_circle.self_modulate = Color(0,0,0,1)
		else:
			new_circle.self_modulate = Color(0,0,0,.5)
	
	#Setup the new prize grid layout
	prize_grid.columns = grid_columns

##Updates the bingo prize preview to the new bingo card size.
func _update_bingo_prize_slot(grid_columns: int, total_slots: int) -> void:
	bingo_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PrizeLabel").text = str(bingo_prize_value)
	var prize_grid: GridContainer = bingo_prize_slot.get_node("PrizeSlotContainer/PrizeVContainer/PatternGrid")
	
	#Clear the prize grid slots
	for node in prize_grid.get_children():
		node.queue_free()
	
	#Instantiate new circle scenes
	for i in total_slots:
		var new_circle: TextureRect = prize_circle.instantiate()
		prize_grid.add_child(new_circle)
		new_circle.self_modulate = Color(0,0,0,1)
	
	#Setup the new prize grid layout
	prize_grid.columns = grid_columns
