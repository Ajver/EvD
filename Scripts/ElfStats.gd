extends Node

var damage_multiplier: float = 1.0 setget set_damage_multiplier
var health_multiplier: float = 1.0 setget set_health_multiplier

var _stats = [
	Stat.new("bows_knowledge", "Znajomość Łuków", 1, 10),
	Stat.new("vitality", "Witalność", 13, 250),
	Stat.new("critical_shot", "Uderzenie Krytyczne", 0.1, 1)
]

var _items = {}

func _ready():
	add_to_group("IHaveSthToSave")

func set_damage_multiplier(value):
	damage_multiplier = value
	add_revival_modifier("bows_knowledge", value)

func set_health_multiplier(value):
	health_multiplier = value
	add_revival_modifier("vitality", value)

func add_revival_modifier(stat_name, value):
	var stat = get_stat(stat_name)
	var modifier = StatModifier.new("revival_" + stat_name, stat_name)

	modifier.multiply_modifier = value
	
	stat.remove_modifier_by_item_name(modifier.item_name)
	stat.add_modifier(modifier)

static func create_default_items() -> void:
	ElfStats._items = {
		"Bow": load("res://Resources/Items/Bow.tres"),
		"Helmet": load("res://Resources/Items/Helmet.tres"),
		"LeftRing": load("res://Resources/Items/LeftRing.tres"),
		"RightRing": load("res://Resources/Items/RightRing.tres"),
		"Armor": load("res://Resources/Items/Armor.tres"),
		"Gloves": load("res://Resources/Items/Gloves.tres"),
		"Boots": load("res://Resources/Items/Boots.tres")
	}

	for key in ElfStats._items:
		ElfStats._items[key] = ElfStats._items[key].duplicate()
		ElfStats._items[key].reset()

static func restore_to_default() -> void:
	for key in ElfStats._items:
		ElfStats._items[key].reset()

	for s in ElfStats._stats:
		s.reset()
		
	if ElfStats.damage_multiplier != 1.0:
		ElfStats.add_revival_modifier("bows_knowledge", ElfStats.damage_multiplier)
		
	if ElfStats.health_multiplier != 1.0:
		ElfStats.add_revival_modifier("vitality", ElfStats.health_multiplier)
		
static func get_stats() -> Array:
	return ElfStats._stats
		
static func get_stat(stat_name:String) -> Stat:
	for s in ElfStats._stats:
		if s.is_named(stat_name):
			return s
	
	printerr("nonexist stat with name: \"" + stat_name + "\"")
	return null
	
static func get_stat_modified_value(stat_name:String) -> float:
	var stat = get_stat(stat_name)
	
	if stat:
		return stat.get_modified_value()
	
	return 0.0
	
static func get_stat_base_value(stat_name:String) -> float:
	var stat = get_stat(stat_name)
	
	if stat:
		return stat.get_base_value()
	
	return 0.0

static func add_item(item) -> void:
	ElfStats._items[item.name] = item
	
	for s in ElfStats._stats:
		_remove_old_item_modifier(s, item)
		
		_add_new_item_modifier(s, item)
				
static func _remove_old_item_modifier(stat: Resource, item: Resource) -> void:
	for i in range(0, stat.modifiers.size(), 1):
		if stat.modifiers[i].item_name == item.name:
			stat.remove_modifier(stat.modifiers[i])
			return
			
static func _add_new_item_modifier(stat: Resource, item: Resource) -> void:
	for modifier in item.stat_modifiers:
		if stat.is_named(modifier.stat_name):
			stat.add_changer(modifier)
	
static func save():
	var save_dict = {
		_elf_stats = {
			_stats = {},
			_items = {},
			_damage_multiplier = ElfStats.damage_multiplier,
			_health_multiplier = ElfStats.health_multiplier
		}
	}
	
	for s in ElfStats._stats:
		save_dict["_elf_stats"]["_stats"][s.name] = {
			_base_value = s.get_base_value(),
			_modified_value = s.get_modified_value()
		}
		
	for key in ElfStats._items:
		save_dict["_elf_stats"]["_items"][key] = ElfStats._items[key].save()
	
	return save_dict

static func load_data(data):
	var stats = data["_stats"]
	var items = data["_items"]
	
	for key in stats:
		var new_stat = stats[key]
		var stat = get_stat(key)
		
		stat.set_base_value(new_stat["_base_value"])
		stat.set_modified_value(new_stat["_modified_value"])
		
	for key in items:
		ElfStats._items[key].load_data(items[key])
		
	ElfStats.set_damage_multiplier(data["_damage_multiplier"])
	ElfStats.set_health_multiplier(data["_health_multiplier"])
