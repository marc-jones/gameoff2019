extends TextureRect

# Score variables
var score_label
var displayed_score_total = 0
var current_score_total = 0
var queued_up_score_to_add = 0
var time_since_score = 0
var combo_threshold = 0.5
var combo = 1
var score_increase_speed = 1000

# Health variables
var health_bar
var displayed_health
var current_health

func _ready():
	score_label = get_node("OverlayColumns/Business/Number")
	health_bar = get_node("OverlayColumns/Business/HealthBar/HealthGauge")

func _enter_tree():
	var game_manager = get_tree().get_root().get_node("SceneManager/GameManager")
	var _discard = game_manager.connect(
		"score_change", self, "score_change_callback")
	_discard = game_manager.get_node("PlayArea/Player").connect(
		"player_health_change", self, "health_change_callback")
	health_change_callback(game_manager.get_node("PlayArea/Player").health)

func health_change_callback(health):
	if displayed_health == null:
		displayed_health = health
	current_health = health

func score_change_callback(score):
	if time_since_score < combo_threshold:
		combo += 1
	else:
		combo = 1
	time_since_score = 0
	queued_up_score_to_add += score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_score += delta
	if combo_threshold <= time_since_score and not queued_up_score_to_add == 0:
		current_score_total += queued_up_score_to_add * combo
		queued_up_score_to_add = 0
	if displayed_score_total < current_score_total:
		var amount_to_add = 0
		if score_increase_speed*delta > 0:
			amount_to_add = int((current_score_total - displayed_score_total) /
				(score_increase_speed*delta))
		displayed_score_total += max(amount_to_add, 1)
	if displayed_score_total > current_score_total:
		displayed_score_total = current_score_total
	score_label.text = str(displayed_score_total)
	# Health
	if not displayed_health == current_health:
		displayed_health += (sign(current_health-displayed_health) * 
			max(1, int(abs(displayed_health-current_health)/10)))
		health_bar.value = displayed_health
