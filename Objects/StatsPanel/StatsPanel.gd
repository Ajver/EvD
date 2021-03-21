extends Control

onready var panel = $Panel/MarginContainer/VBoxContainer

var Stat = load("res://Objects/StatsPanel/Stat.tscn")

func _ready():
	call_deferred("create_stat_panel")

func create_stat_panel():
	for s in ElfStats.get_stats():
		var row = Stat.instance()
		s.connect("value_changed", self, "update_stat_value")
		row.name = s.name
		row.find_node("Name").text = s.visible_name
		row.find_node("Value").value = stepify(s.get_modified_value(), 0.01) / s.max_value
		panel.add_child(row)

func update_stat_value(stat):
	panel.get_node(stat.name + "/Container/Value").value = stepify(stat.get_modified_value(), 0.01) / stat.max_value
