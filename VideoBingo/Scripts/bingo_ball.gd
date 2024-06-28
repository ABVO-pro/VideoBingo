class_name BingoBall
extends PathFollow2D
##Stores the ball's draw animation duration and delay untill the next ball is drawn. The animation is played out automatically in the [param _ready] function with the use of tweens

##This signal is emitted when the ball reaches the end of it's path
signal path_end_reached(number: int)

##The duration (in seconds) it takes for the ball to be drawn from the right side all the way to the left side.
@export var path_duration_in_seconds: float = 3
##The delay (in seconds) it takes as soon as the ball reaches the end of it's path before the next ball is drawn.
@export var delay_between_draws: float = 2

##A timer used to move the ball away so it can despawn off screen
@onready var despawn_timer: Timer = $DespawnTimer

##Is true when it's the last ball drawn from the pool
var is_last_ball: bool = false
##Is true when the ball is moving to be despawned. Used by the _process function.
var is_moving: bool = false
##The number on the ball.
var number: int
##The label containing the ball's number.
var label: Label
##The outer (coloured) texture of the ball.
var outer_texture: TextureRect

func _ready() -> void:
	label = $"Outertexture/Centertexture/BallNumberLabel"
	outer_texture = $"Outertexture"
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "progress_ratio", 1, path_duration_in_seconds)
	await tween.finished
	await get_tree().create_timer(delay_between_draws).timeout
	emit_signal("path_end_reached", number)
	
	#The time it takes for this ball to start moving to despawn (The time it takes for the next ball to come into contact with this one to replace it).
	if (!is_last_ball):
		despawn_timer.wait_time = path_duration_in_seconds * .89
		despawn_timer.start()
		despawn_timer.timeout.connect(func() -> void: is_moving = true)

func _process(delta: float) -> void:
	if (is_moving):
		position.x -= (900 / path_duration_in_seconds) * delta
		if(position.x < -100):
			queue_free()
