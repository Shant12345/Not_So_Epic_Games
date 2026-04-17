extends Label

## Game timer — counts UP from 8:00 PM to 8:40 AM (next day).
## Ends the game when it reaches 8:40 AM.

@export var game_minutes_per_real_second := 1.0

# Start: 8:00 PM = 20 * 60 = 1200 minutes
# End: 8:40 AM next day = 24*60 + 8*60 + 40 = 1440 + 520 = 1960 minutes
const START_MINUTES := 20 * 60        # 8:00 PM
const END_MINUTES := 24 * 60 + 8 * 60 + 40  # 8:40 AM next day

var current_time_minutes: float

func _ready() -> void:
	current_time_minutes = START_MINUTES
	_update_label()

func _process(delta: float) -> void:
	# Count up
	current_time_minutes += game_minutes_per_real_second * delta
	_update_label()
	
	if current_time_minutes >= END_MINUTES:
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
	# Trigger death screen when time is up
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("die"):
		player.die()
	else:
		get_tree().reload_current_scene()

