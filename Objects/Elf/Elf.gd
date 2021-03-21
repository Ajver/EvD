extends Node2D

signal game_over

export(float) var arrow_speed = 700
export(float) var arrow_gravity = 500

var Arrow = load("res://Objects/Elf/Arrow/Arrow.tscn")
var next_arrow_velocity : Vector2

var hp : float setget set_current_hp

var is_walking : bool
var is_shooting : bool
var is_in_tavern : bool

onready var fire_point = find_node("FirePoint")
onready var hp_bar = find_node("HPBar")
onready var hp_label = find_node("HPLabel")
onready var animation_player = find_node("AnimationPlayer")

func _ready():
	ElfStats.create_default_items()
	ElfStats.get_stat("vitality").connect("value_changed", self, "_on_vitality_change")
	add_to_group('IHaveSthToSave')
	reset_to_base()
	animation_player.play("ElfWalkAnimation")
	is_walking = true
	is_shooting = false
	

func _process(delta):
	if Input.is_action_just_pressed("shoot") && !is_walking:
		animation_player.play("ElfShootStandingAnimation")
	elif Input.is_action_just_pressed("shoot") && is_walking:
		animation_player.play("ElfWalkingAndShooting")
	elif BackgroundData.move_speed == 0 && is_walking:
		animation_player.play("ElfIdle")
		is_walking = false
	elif BackgroundData.move_speed > 0 && !is_walking:
		animation_player.play("ElfWalkAnimation")
		is_walking = true
		
	
func spawn_arrow():
	
	if Settings.sounds_on && !is_in_tavern:
		$ShotSound.play()
	
	var dwarf = $DwarfRayCast.get_collider()
	
	if not dwarf:
		return
		
	var proportion = abs(arrow_speed) / (abs(arrow_speed) + abs(dwarf.velocity.x))
	var diff_x = dwarf.global_position.x - global_position.x - 32
	var path_x = proportion * diff_x
	var flying_time = path_x / arrow_speed
	var arrow_velocity = Vector2(arrow_speed, -arrow_gravity * flying_time * 0.5)
	
	var arrow = Arrow.instance()
	get_parent().add_child(arrow);
	arrow.global_position = fire_point.global_position
	arrow.gravity = arrow_gravity
	arrow.velocity = arrow_velocity
	arrow.damage = ElfStats.get_stat_modified_value("bows_knowledge")
	
func arrow_reloaded():
	animation_player.play("ElfWalkAnimation")
	is_walking = true
	
func on_dwarf_hit(dmg) -> bool:
	if dmg > hp:
		hp = 0
	else:
		hp -= dmg
	
	update_hp_label()
	
	if hp <= 0:
		emit_signal("game_over")
		return false
	else:
		hp_bar.value = hp
		return true

func update_hp_label():
	hp_label.text = str(stepify(hp,0.01))

func reset_to_base():
	hp = ElfStats.get_stat_modified_value("vitality")
	hp_bar.max_value = hp
	hp_bar.value = hp
	update_hp_label()
	
func set_current_hp(new_hp):
	hp = new_hp
	hp_bar.value = hp
	update_hp_label()
	
func add_hp(additional_hp):
	set_current_hp(min(hp + additional_hp, hp_bar.max_value))
	
func _on_vitality_change(vitality_stat):
	hp_bar.max_value = vitality_stat.get_modified_value()
	
func save():
	var save_dict = {
		_hp = hp
	}
	return save_dict
