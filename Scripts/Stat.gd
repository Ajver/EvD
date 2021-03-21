extends Resource


class_name Stat

export(float) var base_value = 0 setget set_base_value, get_base_value
export(float) var modified_value = 0 setget set_modified_value, get_modified_value

signal value_changed(this)

var name : String
var modifiers : Array = []

# Used to represent max value on progress bar, just visual
var max_value : float = 100
var visible_name : String = "STAT"

func _init(p_name: String, p_visible_name: String = "STAT", p_base_value: float = 0, p_max_value: float = 100):
	name = p_name
	p_visible_name = p_visible_name
	max_value = p_max_value
	set_base_value(p_base_value)

func set_base_value(p_base_value: float = 0) -> void:
	base_value = p_base_value
	calculate_modified_value()
func get_base_value() -> float:
	return base_value
	
func set_modified_value(p_modified_value: float) -> void:
	modified_value = p_modified_value
	emit_signal("value_changed", self)
func get_modified_value() -> float:
	return modified_value

func calculate_modified_value() -> void:
	modified_value = base_value
	
	var multiply_modifier : float = 1.0
	for modifier in modifiers:
		modified_value += modifier.sum_modifier
		multiply_modifier *= modifier.multiply_modifier
	modified_value *= multiply_modifier
	
	emit_signal("value_changed", self)
	
func add_modifier(modifier: Resource) -> void:
	modifiers.push_back(modifier)
	calculate_modified_value()
	
func remove_modifier(modifier: Resource) -> void:
	modifiers.erase(modifier)
	calculate_modified_value()
	
func remove_modifier_by_item_name(item_name: String) -> void:
	for modifier in modifiers:
		if modifier.item_name == item_name:
			remove_modifier(modifier)
			return
		
func reset() -> void:
	modifiers.clear()
	calculate_modified_value()
		
func is_modified_by_item(item_name: String) -> bool:
	for modifier in modifiers:
		if modifier.item_name == item_name:
			return true
	return false

func is_named(p_name: String) -> bool:
	return name == p_name

func calculate_modified_value_with_modifier(new_modifier:Resource) -> float:
	var temp_modified_value : float = base_value+new_modifier.summation_modifier
	var multiply_modifier : float = new_modifier.multiply_modifier
	for modifier in modifiers:
		temp_modified_value += modifier.summation_modifier
		multiply_modifier *= modifier.multiply_modifier
	temp_modified_value *= multiply_modifier
	return temp_modified_value

func calculate_modified_value_replaced_item(item:Resource) -> float:
	var temp_modified_value : float = base_value
	var multiply_modifier : float = 1.0
	for modifier in item.stat_modifiers:
		if modifier.stat_name == name:
			temp_modified_value += modifier.summation_modifier
			multiply_modifier *= modifier.multiply_modifier
	for modifier in modifiers:
		temp_modified_value += modifier.summation_modifier
		multiply_modifier *= modifier.multiply_modifier
	temp_modified_value *= multiply_modifier
	return temp_modified_value
