extends CharacterBody2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

@export var health_component: HealthComponent

@onready var _hitbox: Area2D = self.get_node("HitboxArea")
@onready var _queen_sprite: AnimatedSprite2D = self.get_node("QueenCroixNPCSprite")

@onready var _player: Player = SceneManager.find_player()

var _should_take_damage := true

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _process(_delta: float) -> void:
	# Make the Queen's sprite always face the player.
	if _player.global_position.x < self.global_position.x:
		_queen_sprite.flip_h = true
	else:
		_queen_sprite.flip_h = false


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player() and _should_take_damage:
			self.health_component.take_damage(projectile.get_damage())


## Only enables the shield's collision, the particles are handled by the boss fight manager.
func enable_shield() -> void:
	_should_take_damage = false


## Only disables the shield's collision, the particles are handled by the boss fight manager.
func disable_shield() -> void:
	_should_take_damage = true


## Plays `animation_name` for the specified `duration`.
## Once finished, the animation given by `fallback_animation` starts playing.
func async_play_animation(
		animation_name: StringName, 
		duration_in_secs: float, 
		fallback_animation: StringName = &"idle") -> void:
	_queen_sprite.play(animation_name)

	await SceneManager.async_delay(duration_in_secs)

	_queen_sprite.play(fallback_animation)


func set_animation(animation_name: StringName) -> void:
	_queen_sprite.play(animation_name)

