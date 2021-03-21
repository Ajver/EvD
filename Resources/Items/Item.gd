extends Resource

class_name Item

export(String) var name

# Should be ItemType
export(Resource) var quality

# Should be array of StatModifiers
export(Array, Resource) var stat_modifiers

export(float) var price

var QUALITY : Array

var setuped : bool = false

func setup():
	if setuped: 
		return
		
	setuped = true
	
	randomize()
	
	fill_quality_array()

func reset() -> void:
	setup()
	quality = QUALITY[0]
	stat_modifiers.clear()
	price = 1
	
func fill_quality_array() -> void:
	QUALITY = [
		load("res://Resources/Items/ItemQuality/TypeRegular.tres"),
		load("res://Resources/Items/ItemQuality/TypeUpgraded.tres"),
		load("res://Resources/Items/ItemQuality/TypeMagical.tres"),
		load("res://Resources/Items/ItemQuality/TypeEpic.tres"),
		load("res://Resources/Items/ItemQuality/TypeLegendary.tres")
	]
	
func generate_random() -> void:
	if QUALITY.empty():
		fill_quality_array()
		
	quality = get_random_element(QUALITY).duplicate()
	stat_modifiers.clear()
	
	price = rand_range(1, 3) 
	
	var possible_stat_names := get_possible_stat_names_array()
	
	var no_modifiers = randi()%3 + 1
	for i in range(no_modifiers):
		var modifier = StatModifier.new(name, pop_random_element(possible_stat_names))
		modifier.generate_random()
		stat_modifiers.push_back(modifier)
	
func get_random_element(from:Array):
	return from[randi() % from.size()]
	
func pop_random_element(from:Array):
	var element = get_random_element(from)
	from.erase(element)
	return element
	
func get_possible_stat_names_array() -> Array:
	var arr := []

	for s in ElfStats.get_stats():
		arr.push_back(s.name)
	
	return arr
	
func save():
	var save_dict = {
		_modifiers = {}
	}
	
	var i : int = 0
	for c in stat_modifiers:
		save_dict["_modifiers"][str("modifier", i)] = c.save()
		i += 1
	
	return save_dict
	
func load_data(data):
	var modifiers = data["_modifiers"]
	
	if not modifiers:
		return
		
	for key in modifiers:
		var modifier_data = modifiers[key]
		var modifier = StatModifier.new(name, modifier_data["_stat_name"])
		modifier.load_data(modifier_data)
		stat_modifiers.push_back(modifier)
