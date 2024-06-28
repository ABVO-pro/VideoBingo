class_name BallColours

static var colours: Dictionary = { 
	"0": Color.DARK_RED,
	"1": Color.DARK_BLUE,
	"2": Color.WEB_GREEN,
	"3": Color.YELLOW,
	"4": Color.DARK_MAGENTA,
	"5": Color.CYAN,
	"6": Color.ANTIQUE_WHITE,
	"7": Color.DEEP_PINK,
	"8": Color.SADDLE_BROWN,
	"9": Color.BLACK
}

static func get_ball_colour(ball_number: int) -> Color:
	if (ball_number < 10):
		return colours["0"]
	else:
		return colours[str(ball_number)[0]]
