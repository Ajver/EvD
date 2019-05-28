extends Node2D

var Dwarf = load("res://Scenes/Dwarf.tscn")
var Boss = load("res://Scenes/Boss.tscn")

export(float) var dwarf_max_hp : float = 10.0
export(float) var dwarf_damage : float = 1.0
export(float) var boss_max_hp : float = 40.0

onready var base_dwarf_hp = dwarf_max_hp
onready var base_dwarf_damage = dwarf_damage

onready var level_manager = get_parent().get_node("LevelManager")

func _on_FirstDwarfTimer_timeout():
	spawn_dwarf()
	
func spawn_dwarf():
	var dwarf = Dwarf.instance()
	get_parent().call_deferred("add_child", dwarf)
	dwarf.global_position = global_position
	dwarf.damage = dwarf_damage
	dwarf.set_hp(dwarf_max_hp)
	dwarf.connect("died", level_manager, "on_Dwarf_died")
	
func spawn_boss():
	var boss = Boss.instance()
	get_parent().call_deferred("add_child", boss)
	boss.global_position = global_position
	boss.set_max_hp(boss_max_hp)
	boss.connect("died", level_manager, "on_Boss_died")
	boss.connect("boss_kill_timeout", level_manager, "on_Boss_kill_timeout")
	
func on_next_level(level : int):
	dwarf_max_hp += dwarf_max_hp * level * 0.1
	dwarf_damage += level * 0.1
	
	if (level-1) % 10 == 0:
		base_dwarf_hp = dwarf_max_hp
		base_dwarf_damage = dwarf_damage
		
func reset_to_base():
	reset_dwarf_data()
	spawn_dwarf()
		
func reset_dwarf_data():
	dwarf_max_hp = base_dwarf_hp
	dwarf_damage = base_dwarf_damage
	