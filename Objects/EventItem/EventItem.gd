extends Node2D

const TRACK_HEIGHT = 260
export(int) var gold_reward = 65
export(float) var move_speed = -100
onready var cam_pos = get_node("/root/World").find_node("Camera2D").position

func _ready():
	var value = randi()%800+160
	set_start_position(value,293)

func set_start_position(x, y):
	if "DwarfInBalloon" in self.get_name(): #other position for DwarfInBallon
		position.x = cam_pos.x + x
		position.y = y
	else:
		position.x = cam_pos.x + x
		position.y = TRACK_HEIGHT

func get_reward():
	GameData.gold += gold_reward

func _on_Item_pressed():
	get_reward()
	queue_free()
	
func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if $Sprite.get_rect().has_point(evLocal.position):
			_on_Item_pressed()
