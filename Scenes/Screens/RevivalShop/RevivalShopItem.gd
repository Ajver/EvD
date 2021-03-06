extends HBoxContainer

export (Color, RGB) var color
export (String) var info
export (String) var return_func
export (String) var upgrade_func
export (String) var button_sign
var count_text
export (int) var price


func _ready():
	$Info.set_text(info)
	$Count.set("custom_colors/font_color", color)
	$Price.set_text("Cena: "+ String(price))

func refresh():
	$Button.disabled = get_owner().call(return_func)
	$Button.text = button_sign
	$Count.text = String(count_text)
	
func set_count_string(s):
	count_text = String(s)
	refresh()

func _on_Button_pressed():
	get_owner().call(upgrade_func)
	refresh()
	
	if Settings.sounds_on:
		$ClickSound.play()
