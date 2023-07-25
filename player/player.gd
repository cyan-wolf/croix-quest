extends CharacterBody2D
class_name Player

const MeleeEnemy := preload("res://enemies/melee_enemy/melee_enemy.gd")
const PlayerWeapon := preload("res://player/Weapon.gd")

const WALKING_SPEED := 70.0
const DASH_MULTIPLIER := 1.65

# Manages the player's health value.
@export var health_component: HealthComponent

# Manages the player's mana value.
@export var mana_component: ManaComponent

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _weapon_sprite: Sprite2D = $Weapon/Sprite2D
@onready var _weapon: PlayerWeapon = self.get_node("Weapon")

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

var _current_speed: float = WALKING_SPEED
var _is_timer_on: bool = false
var _is_running: bool = false
var _is_dead: bool = false
# Determines whether the player can move, shoot, or use spells.
var _can_act: bool = true

var _current_sprite_direction := Util.Direction.RIGHT

func _ready() -> void:
	self.health_component.death.connect(_on_death)
	_hitbox.area_entered.connect(_on_area_entered_hitbox)


func _physics_process(_delta):
	# Temporary way to show that the player is dead.
	if _is_dead:
		return

	# Disables player movement.
	if not _can_act:
		return

	var input_direction := _get_input_direction()
	_current_sprite_direction = _get_sprite_direction()

	self.velocity = input_direction * _current_speed
	self.move_and_slide()

	if input_direction == Vector2.ZERO or input_direction == Vector2(0, 0):
		self.set_animation("Idle")
		_current_speed = WALKING_SPEED
		_is_timer_on = false
		_is_running = false
		$RunCountdown.stop()

	else:
		if _is_timer_on == false:
			$RunCountdown.start()
			_is_timer_on = true

		if _is_running:
			self.set_animation("Run")

		else:
			self.set_animation("Walk")


func _process(_delta: float) -> void:
	# DEBUG: The player takes damage if the 'Number Pad 1' key is pressed.
	if Input.is_action_just_pressed("debug_1"):
		self.health_component.take_damage(1)

	# DEBUG: The player uses up mana if the 'Number Pad 2' key is pressed.
	if Input.is_action_just_pressed("debug_2"):
		self.mana_component.use_mana(1)

	# DEBUG: The player dies if the 'Number Pad 3' key is pressed.
	if Input.is_action_just_pressed("debug_3"):
		self.health_component.take_damage(self.health_component.get_health())

	# DEBUG: The player goes to the 'Test Dungeon' map if the 'Number Pad 4' key is pressed.
	if Input.is_action_just_pressed("debug_4"):
		SceneManager.load_scene_file("res://maps/dungeons/test_dungeon/test_dungeon.tscn")

	# DEBUG: The player goes to the 'Cobalt Dungeon' map if the 'Number Pad 5' key is pressed.
	if Input.is_action_just_pressed("debug_5"):
		SceneManager.load_scene_file("res://maps/dungeons/cobalt_dungeon/cobalt_dungeon.tscn")


func _on_death() -> void:
	_is_dead = true


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	if other_hitbox.is_in_group("placeholder_enemy"):
		self.health_component.take_damage(1)

	elif other_hitbox.is_in_group("enemy_melee_attack_hitbox"):
		var enemy: MeleeEnemy = other_hitbox.get_parent()
		self.health_component.take_damage(enemy.get_damage())


# Makes it so that the player can act (move, shoot, use spells, etc).
func enable_actions() -> void:
	_can_act = true
	_weapon.enable_weapon()


# Makes it so that the player cannot act.
func disable_actions() -> void:
	_can_act = false
	_weapon.disable_weapon()


func set_animation(animation: String):
	#var direction = "Side" if sprite_direction in ["Left", "Right"] else sprite_direction    
	_sprite.play(animation) #Add {+ direction} to animation if up and down _sprite animations are implemented. Remember to edit the animation names too if it happens
	_sprite.flip_h = (_current_sprite_direction == Util.Direction.LEFT)
	#_weapon_sprite.flip_h = (sprite_direction == "Left") #ANTHONY REMEMBER TO FIX THIS GOD DAMN # ('_'): what is going on here


func _get_input_direction() -> Vector2:
	var x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")) 
	var y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	# Without normalized, diagonal movement is faster than horizontal or vertical.
	var input_direction := Vector2(x, y).normalized()
	return input_direction


func _get_sprite_direction() -> Util.Direction:
	match _get_input_direction():
		Vector2.LEFT:
			return Util.Direction.LEFT
		Vector2.RIGHT:
			return Util.Direction.RIGHT
		_:
			return _current_sprite_direction


func _on_timer_timeout():
	_current_speed *= DASH_MULTIPLIER
	_is_running = true
	$InitialDashParticles.emitting = true
	$InitialDashSFX.play()
