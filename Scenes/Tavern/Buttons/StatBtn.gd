extends TavernBtn

export(String) var stat_name
export(float) var add_to_stat = 0.0
export(float) var multiply_stat = 1.0

func _on_BuyBtn_pressed():
	var v = ElfStats.get_stat_base_value(stat_name)
	v = v*multiply_stat + add_to_stat
	ElfStats.get_stat(stat_name).set_base_value(stepify(v,0.01))
	
	._on_BuyBtn_pressed()
