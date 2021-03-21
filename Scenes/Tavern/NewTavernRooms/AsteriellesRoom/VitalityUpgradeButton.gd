extends TavernBtn

const STAT_NAME : String = 'vitality'
export(float) var add_to_stat = 0.0
export(float) var vitality_modifier = 1.037

var count : int = 1;

func _on_BuyBtn_pressed():
	count+=1
	var stat = ElfStats.get_stat(STAT_NAME)
	var default : float = stat.base_value
	var v: float = float(vitality_modifier) * float(default) * float(count)
	stat.set_base_value(ceil(v))
	
	._on_BuyBtn_pressed()

func save() -> Dictionary:
	var save_dict = {
		_price_gold = price_gold,
		_vitality_upgrade_count = count
	}
	return save_dict

func load_data(data):
	set_price_gold(data["_price_gold"])
	count = data["_vitality_upgrade_count"]


