extends Resource

class_name StatModifier

export(String) var stat_name : String
export(float) var sum_modifier : float = 0.0
export(float) var multiply_modifier : float = 1.0

var item_name : String

func _init(p_item_name, p_stat_name):
	item_name = p_item_name
	stat_name = p_stat_name
	
func generate_random() -> void:
	sum_modifier = randf() * 2 - 0.5
	multiply_modifier = 1 + randf() * 0.5
	
func save():
	var save_dict = {
		_stat_name = stat_name,
		_item_name = item_name,
		_sum_modifier = sum_modifier,
		_multiply_modifier = multiply_modifier
	}
	
	return save_dict
	
func load_data(data): 
	item_name = data["_item_name"]
	sum_modifier = data["_sum_modifier"]
	multiply_modifier = data["_multiply_modifier"]

