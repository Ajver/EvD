extends TavernBtn

func update_enabled() -> void:
	set_enabled(should_be_enabled())
	
func should_be_enabled() -> bool:
	var elf = get_node("/root/World").find_node("Elf")
	
	var max_hp: int = ElfStats.get_stat_modified_value("vitality")
	return elf.hp < max_hp and price_gold <= GameData.gold
