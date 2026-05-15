extends Label

## Game timer — counts UP from 8:00 PM to 8:40 AM (next day).
## Ends the game when it reaches 8:40 AM.

@export var game_minutes_per_real_second := 1.0

# Start: 10:00 AM = 10 * 60 = 600 minutes
# End: 8:40 AM same day = 8 * 60 + 40 = 520 minutes
const START_MINUTES := 10 * 60        # 10:00 AM
const END_MINUTES := 8 * 60 + 40      # 8:40 AM

var current_time_minutes: float

func _ready() -> void:
	# Always initialize to start time if this is a fresh scene load
	if GameState.current_time_minutes == 600.0:
		GameState.current_time_minutes = float(START_MINUTES)
		
	current_time_minutes = GameState.current_time_minutes
	_update_label()

func _process(delta: float) -> void:
	# Count down
	current_time_minutes -= game_minutes_per_real_second * delta
	GameState.current_time_minutes = current_time_minutes
	_update_label()
	
	if current_time_minutes <= END_MINUTES:
		current_time_minutes = END_MINUTES
		_update_label()
		_game_over()

func _update_label() -> void:
	# Wrap to 24-hour day
	var total_mins = int(current_time_minutes) % (24 * 60)
	var h = total_mins / 60
	var m = total_mins % 60
	
	var am_pm = "AM"
	if h >= 12:
		am_pm = "PM"
	
	var display_h = h
	if display_h > 12:
		display_h -= 12
	if display_h == 0:
		display_h = 12
		
	text = "%02d:%02d %s" % [display_h, m, am_pm]

func _game_over() -> void:
	# Time is up — deal lethal damage through the health system
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("take_damage"):
		player.take_damage(100)
	# Don't call die() or reload directly — let health system handle it
