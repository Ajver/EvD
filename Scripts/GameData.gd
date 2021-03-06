extends Node

signal gold_changed
signal get_first_silver_moon

var gold : float = 0.0 setget set_gold
var silver_moon : int = 0 setget set_silver_moon
var last_revival_level : int = 0
var probability_to_get_silver_moon_in_percent: int = 15

var golds_on_second : float = 0.0
var additional_gold_multipler : float = 1.0
var last_golds : Array = [0.0,0.0]
var tradesman_item_price_multipler : float = 1.1

var offline_time : int
var offline_gold_reward : float

var time_to_kill_boss: int = 30
var next_wait_time = 1.0
var next_timer : float

const FIRST_REVIVAL_LEVEL : int = 50
const REVIVAL_SILVER_MOON_REWARD : int = 1
const BASE_INCOME = 5
const GOLD_GROWTH_RATE: float = 1.012

var world
var level_manager
var ui

func setup() -> void:
	add_to_group('IHaveSthToSave')
	
	world = get_node("/root/World")
	level_manager = world.get_node("LevelManager")
	ui = world.find_node("UIContainer")
	
	level_manager.connect("dwarf_died", self, "on_Dwarf_died")
	level_manager.connect("boss_died", self, "on_Boss_died")
	
func set_gold(value):
	gold = value
	ui.set_gold_label(value)
	emit_signal("gold_changed")

func set_silver_moon(value):
	silver_moon = value
	ui.set_silver_moon_label(value)

func _process(delta):
	next_timer -= delta
	if next_timer > 0:
		return
	
	check_gold_on_second()
	restart_time_to_save()

var i : int = 0
func check_gold_on_second():
	if i == 0:
		last_golds[0] = gold
	if i == 9:
		last_golds[1] = gold
	
	if i > 9:
		i = -1
		if gold > 0:
			if last_golds[1] - last_golds[0] > 0:
				golds_on_second = stepify(float((last_golds[1] - last_golds[0])/60.0), 0.01)
	i += 1

func restart_time_to_save():
	next_timer = next_wait_time

func on_Dwarf_died():
	var value = get_gold_to_add()
	add_gold(value)
	
func on_Boss_died():
	var value = get_gold_to_add() * 3
	add_gold(value)
	add_silver_moon()
	
func get_gold_to_add():
	var lvl = level_manager.current_level
	var ratio = GOLD_GROWTH_RATE
	var base = BASE_INCOME

	return base*pow(ratio,lvl-1)

func add_gold(additional_gold):
	set_gold(gold + additional_gold * additional_gold_multipler )
	
func add_silver_moon():
	var lvl = level_manager.current_level
	var reward = lvl / 100 + 1
	if lvl < GameData.FIRST_REVIVAL_LEVEL:
		return
	
	if lvl == GameData.FIRST_REVIVAL_LEVEL+1:
		emit_signal("get_first_silver_moon")
		set_silver_moon(silver_moon + 1)
		return
	
	if rand_range(1,100) > probability_to_get_silver_moon_in_percent:
		return
	
	set_silver_moon(silver_moon + reward)
	
func on_game_over():
	set_gold(gold * 0.4)

func save():
	var time = OS.get_unix_time()
	var save_dict = {
		__time = time,
		_golds_on_second = golds_on_second,
		_gold = gold,
		_silver_moon = silver_moon,
		_additional_gold_multipler = additional_gold_multipler,
		_time_to_kill_boss = time_to_kill_boss,
		_probability_to_get_silver_moon_in_percent = probability_to_get_silver_moon_in_percent,
		_tradesman_item_price_multipler = tradesman_item_price_multipler
	}
	return save_dict

func reset():
	gold = 0.0
	silver_moon = 0
	last_revival_level = 0
	probability_to_get_silver_moon_in_percent = 15
	golds_on_second = 0.0
	additional_gold_multipler = 1.0
	last_golds = [0.0,0.0]
	tradesman_item_price_multipler = 1.0
	time_to_kill_boss = 30
	next_wait_time = 1.0
	
	next_timer = 0.0
	offline_time = 0
	offline_gold_reward = 0.0
