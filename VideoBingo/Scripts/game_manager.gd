class_name GameManager
extends Node
##Governs most of the game logic.
##[br]Contains the play button's event handler, handling the game's starting, reseting and pausing logic.

##The number of balls drawn so far.
var balls_drawn: int = 0
##The player's score.
var score: int = 0
##If true a game is in progress, pausing the game does mean a game isn't in progress.
var game_is_running: bool = false
##The pool of numbers to draw balls from.
var generated_numbers: Array[int] = []
##The bingo ball scene.
var bingo_ball_scene: PackedScene = preload("res://Scenes/bingo_ball.tscn")

##The number of balls in the pool to draw from.
@export_range(30, 90, 10) var number_of_balls: int = 30
##The number range that the balls in the pool can be in.
@export var my_range: IntRange = IntRange.new()

##SFX played when a ball is drawn with a number present in the bingo card.
@onready var correct_ball_sfx: AudioStreamPlayer = $"../CorrectBallSFX"
##SFX played when a ball is drawn with a number NOT present in the bingo card.
@onready var wrong_ball_sfx: AudioStreamPlayer = $"../WrongBallSFX"

##The reward previewer grid.
@onready var prize_grid: PrizesContainer = $"../VideoBingo/ScreenContainer/HBoxContainer/PrizesContainer/PanelContainer2/PanelContainer/PrizeGrid"
##The score label, displaying the player's current score.
@onready var score_label: Label = $"../VideoBingo/ScoreTexture/ScoreContainer/ScoreLabel"
##The prize manager object, used to test wether any rewards were won when a ball is drawn with a number present in the bingo card.
@onready var prize_manager: PrizeManager = $"../PrizeManager"
##The bingo card.
@onready var bingo_card: BingoCard = $"../VideoBingo/ScreenContainer/HBoxContainer/CardContainer/Card"
##The play button, serving as a way to start, pause and restart the game after a full pool of balls has been drawn from.
@onready var play_button: TextureButton = $"../VideoBingo/PlayButton"
##The bingo ball's animation path.
@onready var ball_drawer_path_2D: Path2D = $"../VideoBingo/ScreenContainer/BallDrawer/BingoBallPath2D"

func _ready() -> void:
	#We can safely ignore these warnings because the grid sizes are carefully selected from previously set values
	@warning_ignore("integer_division")
	prize_manager.reset_prizes_earned(bingo_card.card_grid.columns, bingo_card.get_card_size()/bingo_card.card_grid.columns)
	
	play_button.pressed.connect(_on_play_button_pressed)
	prize_manager.row_prize_earned.connect(_on_row_prize_earned)
	prize_manager.column_prize_earned.connect(_on_column_prize_earned)
	prize_manager.bingo_prize_earned.connect(_on_bingo_prize_earned)
	prize_manager.corner_prize_earned.connect(_on_corner_prize_earned)

##The play button's event handler, starting a new game is one isn't already running (see: [member game_is_running]), resetting the game state and generating new balls to draw from.
##[br]If a game is in progress, clicking the button will pause the game's execution, clicking it again will resume it.
func _on_play_button_pressed() -> void:
	if (!game_is_running):
		balls_drawn = 0
		score = 0
		score_label.text = "Score: 0"
		for i in ball_drawer_path_2D.get_children():
			i.queue_free()
			
		generated_numbers = RandomManager.generate_x_random_numbers_in_range(my_range.min_value, my_range.max_value, number_of_balls)
		var card_numbers: Array[int] = RandomManager.generate_x_random_numbers_in_range(my_range.min_value, my_range.max_value, number_of_balls)
		print("Started a new game! Generated a pool of %s numbers to draw from: %s" % [generated_numbers.size() ,generated_numbers])
		
		#We can safely ignore these warnings because the grid sizes are carefully selected from previously set values
		@warning_ignore("integer_division")
		prize_manager.reset_prizes_earned(bingo_card.card_grid.columns, bingo_card.card_grid.get_children().size()/bingo_card.card_grid.columns)
		bingo_card.generate_card_numbers(card_numbers)
		_start_bingo_ball_draw()
		
		game_is_running = true
	else:
		get_tree().paused = !get_tree().paused

##Starts the bingo ball draw, running untill every ball has been drawn and reached the end of it's path.
func _start_bingo_ball_draw() -> void:
	for i in generated_numbers.size():
		var is_last_ball: bool = false
		if (generated_numbers.size() - 1 == i):
			is_last_ball = true
		await _draw_bingo_ball(generated_numbers[i], is_last_ball)

##Draws the next bingo ball from the pool, instantiating the [member bingo_ball_scene] scene, and adding it to the [member ball_drawer_path_2D] node, setting it's values and awaiting untill the ball's [param path_end_reached] signal is raised, repeating the process (untill all balls are drawn).
func _draw_bingo_ball(ball_number: int, p_is_last_ball: bool) -> void:
	var bingo_ball: BingoBall = bingo_ball_scene.instantiate()
	bingo_ball.path_end_reached.connect(_on_ball_path_end_reached)
	ball_drawer_path_2D.add_child(bingo_ball)
	
	bingo_ball.number = ball_number
	bingo_ball.is_last_ball = p_is_last_ball
	bingo_ball.label.text = str(ball_number)
	bingo_ball.outer_texture.self_modulate = BallColours.get_ball_colour(ball_number)
	
	await bingo_ball.path_end_reached

##Event handler for the [param ball_path_end_reached] signal for the bingo balls, testing wether the ball's number is in the bingo card and acting accordingly.
##[br]When the last ball reaches the end, stop the game.
func _on_ball_path_end_reached(ball_number: int) -> void:
	print("%s drawn!" % [ball_number])
	if (bingo_card.check_if_drawn_number_is_in_card(ball_number)):
		prize_manager.test_prizes(bingo_card.card_numbers, bingo_card.card_grid.columns)
		correct_ball_sfx.play()
	else:
		wrong_ball_sfx.play()
	balls_drawn += 1
	
	if(balls_drawn == number_of_balls):
		game_is_running = false

##Event handler for when a row prize is earned.
func _on_row_prize_earned() -> void:
	score += prize_grid.row_prize_value
	score_label.text = "Score: %s" % [score]

##Event handler for when a column prize is earned.
func _on_column_prize_earned() -> void:
	score += prize_grid.column_prize_value
	score_label.text = "Score: %s" % [score]

##Event handler for when the bingo prize is earned.
func _on_bingo_prize_earned() -> void:
	score += prize_grid.bingo_prize_value
	score_label.text = "Score: %s" % [score]

##Event handler for when the corner prize is earned.
func _on_corner_prize_earned() -> void:
	score += prize_grid.corner_prize_value
	score_label.text = "Score: %s" % [score]
