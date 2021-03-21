extends Area2D

class_name Dwarf

signal died
signal pre_attack

export(float) var move_speed_mod = 1

const POSITION_KEY : String = "POSITION"
const ANIMATION_KEY : String = "ANIMATION"

enum DwarfType {
	DEFAULT,
	KAMIKAZE,
	SHIELD,
	MAGE,
	PICKAXE,
	SHOOTER,
	POOR
}

var walking_spritesheets = preload("res://Objects/Dwarves/Dwarf/Sprites/walking_spriteframes.tres")
var DWARVES_WALKING_PRESETS = {
	DwarfType.DEFAULT: 	{ POSITION_KEY: Vector2(0, -23), ANIMATION_KEY: "default"},
	DwarfType.KAMIKAZE: { POSITION_KEY: Vector2(0, -25), ANIMATION_KEY: "kamikaze"},
	DwarfType.SHIELD: 	{ POSITION_KEY: Vector2(0, -23), ANIMATION_KEY: "shield"},
	DwarfType.MAGE: 	{ POSITION_KEY: Vector2(0, -25), ANIMATION_KEY: "mage"},
	DwarfType.PICKAXE: 	{ POSITION_KEY: Vector2(0, -31), ANIMATION_KEY: "pickaxe"},
	DwarfType.SHOOTER: 	{ POSITION_KEY: Vector2(0, -31), ANIMATION_KEY: "shooter"},
	DwarfType.POOR: 	{ POSITION_KEY: Vector2(0, -24), ANIMATION_KEY: "poor"}
}
var dwarf_walking_preset

var attacking_spritesheets = preload("res://Objects/Dwarves/Dwarf/Sprites/attack_spriteframes.tres")
var DWARVES_ATTACKING_PRESETS = {
	DwarfType.DEFAULT: 	{ POSITION_KEY: Vector2(4, -36), 	ANIMATION_KEY: "default"},
	DwarfType.KAMIKAZE: { POSITION_KEY: Vector2(-7, -30), 	ANIMATION_KEY: "kamikaze"},
	DwarfType.SHIELD: 	{ POSITION_KEY: Vector2(-9, -35), 	ANIMATION_KEY: "shield"},
	DwarfType.MAGE: 	{ POSITION_KEY: Vector2(-5, -29), 	ANIMATION_KEY: "mage"},
	DwarfType.PICKAXE: 	{ POSITION_KEY: Vector2(4, -32),	ANIMATION_KEY: "pickaxe"},
	DwarfType.SHOOTER: 	{ POSITION_KEY: Vector2(-7, -39), 	ANIMATION_KEY: "shooter"},
	DwarfType.POOR: 	{ POSITION_KEY: Vector2(-17, -27), 	ANIMATION_KEY: "poor"}
}
var dwarf_attacking_preset

var velocity : Vector2
var hp : float
var damage : float

onready var hp_bar
onready var hp_label

onready var next_attack_timer : Timer = $NextAttackTimer
onready var die_sound : AudioStreamPlayer = $DieSound
onready var attack_sound : AudioStreamPlayer = $AttackSound
onready var animated_sprite : AnimatedSprite = $AnimatedSprite

func _ready():
	choose_random_dwarf_type()
	add_to_group("IDwarf")
	go_forward()
	
func choose_random_dwarf_type():
	var type = randi() % DWARVES_WALKING_PRESETS.size()
	dwarf_walking_preset = DWARVES_WALKING_PRESETS[type]
	dwarf_attacking_preset = DWARVES_ATTACKING_PRESETS[type]
	animated_sprite.position = dwarf_walking_preset[POSITION_KEY]
	
func set_data(new_hp, new_damage) -> void:
	set_hp(new_hp)
	damage = new_damage
	
func set_hp(new_hp):
	hp = new_hp
	hp_bar = find_node("HPBar")
	hp_label = find_node("HPLabel")
	
	hp_bar.max_value = hp
	hp_bar.value = hp
	hp_label.text = str(stepify(hp,0.01))

func _physics_process(delta):
	position += velocity * delta
	if $ElfRayCast.is_colliding():
		pre_attack()

func pre_attack():
	next_attack_timer.start()
	_prepare_attack_animation()
	_play_attack_sound()
	velocity = Vector2.ZERO
	set_physics_process(false)
	BackgroundData.move_speed = 0
	emit_signal("pre_attack")
	
func _prepare_attack_animation():
	animated_sprite.frames = attacking_spritesheets
	animated_sprite.stop()
	animated_sprite.position = dwarf_attacking_preset[POSITION_KEY]
	_play_attack_animation()

func on_arrow_hit(arrow):
	if randf() < ElfStats.get_stat_modified_value("critical_shot"):
		arrow.damage *= 2
	
	hp -= arrow.damage
	arrow.queue_free()
	
	if hp <= 0:
		death()
	else:
		hp_bar.value = hp
		
	hp_label.text = str(stepify(hp,0.01))
	
func go_forward():
	velocity = Vector2(-move_speed_mod * BackgroundData.move_speed, 0)
	animated_sprite.play(dwarf_walking_preset[ANIMATION_KEY])
	
func _on_NextAttackTimer_timeout():
	attack()
	_play_attack_sound()
	_play_attack_animation()

func attack():
	var elf = $ElfRayCast.get_collider()
	if not elf.on_dwarf_hit(damage):
		queue_free()

func _on_Dwarf_area_entered(area):
	# Because of collision masks this area is Arrow
	on_arrow_hit(area)

func _play_attack_sound() -> void:
	if Settings.sounds_on:
		attack_sound.play()

func _play_attack_animation() -> void:
	animated_sprite.frame = 0
	animated_sprite.play(dwarf_attacking_preset[ANIMATION_KEY])

func death():
	if Settings.sounds_on:
		die_sound.play()
		attack_sound.stop()
	
	next_attack_timer.stop()
	
	# Disable arrow collision
	collision_layer = 0
	collision_mask = 0
	
	# Stop moving
	set_physics_process(false)
	animated_sprite.stop()
	
	# Placeholder (animation in future)
	hide()
	
	emit_signal("died")
	
	yield(die_sound, "finished")
	
	queue_free()
