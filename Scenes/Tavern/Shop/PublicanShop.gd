extends BasicShop

onready var potions_container = get_node("/root/World").find_node("Potions")

func _on_VineBtn_bought():
	$VineBtn.set_enabled(false)
	var max_hp = ElfStats.get_stat_modified_value("vitality")
	elf.set_current_hp(max_hp)

func _on_HealthPotionBtn_bought():
	potions_container.get_node("HealthPotion").add_potion()
