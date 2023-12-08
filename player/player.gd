extends CharacterBody2D
class_name Player

const PlayerWeapon := preload("res://player/Weapon.gd")
const Projectile := preload("res://weapons/projectile/projectile.gd")
const TauronBoss := preload("res://enemies/bosses/tauron/tauron_boss.gd")
const PaulBoss := preload("res://enemies/bosses/paul/paul_boss.gd")
const ShaleSaberBoss := preload("res://enemies/bosses/shale_saber/shale_saber_boss.gd")
const AstralLineusBoss := preload("res://enemies/bosses/astral_lineus/astral_lineus_boss.gd")

const WALKING_SPEED := 70.0
const DASH_MULTIPLIER := 1.65
const DODGE_DURATION := 0.6

# Manages the player's health value.
@export var health_component: HealthComponent

# Manages the player's mana value.
@export var mana_component: ManaComponent

# Manages the player's lives and respawning.
@export var respawn_component: RespawnComponent

# Manages the player's status effects.
@onready var status_effect_component: StatusEffectComponent = self.get_node("StatusEffectComponent")

# Manages the player's checkpoints and respawning.
@onready var checkpoint_component: CheckpointComponent = self.get_node("CheckpointComponent")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _weapon: PlayerWeapon = self.get_node("Weapon")

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@onready var _ground_hitbox: Area2D = self.get_node("GroundHitboxArea")

@onready var _feet_hitbox: Area2D = self.get_node("FeetHitboxArea")

var _current_speed: float = WALKING_SPEED
var _is_timer_on: bool = false
var _is_running: bool = false
var _is_dodging: bool = false

var _is_slipping: bool = false

var _current_sprite_direction := Util.Direction.RIGHT

func _ready() -> void:
	self.health_component.death.connect(_async_on_death)
	self.mana_component.ran_out_of_mana.connect(_async_on_ran_out_of_mana)
	_hitbox.area_entered.connect(_on_area_entered_hitbox)
	self.checkpoint_component.initialize(self.global_position)


func _input(event: InputEvent):
	if event.is_action_pressed("dodge"):
		_try_to_dodge()


func _physics_process(_delta):
	# Disables player movement there is a dialog being shown, etc.
	if not SceneManager.is_world_state_empty():
		_stop_running()
		return

	# Don't enter "slipping mode" if `self.velocity` is zero.
	if _is_slipping and self.velocity != Vector2.ZERO:
		# Continuously move with the previous velocity while slipping.
		var collides_while_slipping := self.move_and_slide()

		# Make the player stop moving if they collide something.
		if collides_while_slipping:
			self.velocity = Vector2.ZERO

		# Check if the player should still be slipping.
		_check_and_set_if_should_be_slipping()

		_stop_running()

		# Returning here disables input detection while slipping.
		return

	var input_direction := _get_input_direction()
	_current_sprite_direction = _get_sprite_direction()

	self.velocity = input_direction * _current_speed * self.status_effect_component.get_computed_speed_multiplier()
	self.move_and_slide()
		
	if input_direction == Vector2.ZERO:
		_stop_running()

	else:
		if _is_timer_on == false:
			$RunCountdown.start()
			_is_timer_on = true

		if _is_running:
			self.set_animation("Run")

		else:
			self.set_animation("Walk")

	_check_and_set_if_should_be_slipping()


func _process(_delta: float) -> void:
	# Be able to use the weapon if there aren't any events (like being in a cutscene) currently happening.
	if SceneManager.is_world_state_empty():
		_weapon.enable_weapon()
	else:
		_weapon.disable_weapon()


func _async_on_death() -> void:
	SceneManager.add_world_state(Util.WorldState.PLAYER_IS_DEAD)

	await SceneManager.async_delay(1.0)

	SceneManager.show_game_over_screen()


func _async_on_ran_out_of_mana() -> void:
	await SceneManager.async_delay(1.0)

	# Player receives a full heart of damage in exchange for refilling the mana.
	self.health_component.take_damage(2)

	# Refill the mana to the max.
	self.mana_component.gain_mana(self.mana_component.MAX_MANA)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	var defense_multiplier := self.status_effect_component.get_computed_defense_multiplier()

	# Make the player not recieve damage if they are dodging.
	if _is_dodging:
		defense_multiplier = 0

	if other_hitbox.is_in_group("placeholder_enemy"):
		self.health_component.take_damage(1)

	elif other_hitbox.is_in_group("enemy_melee_attack_hitbox"):
		var enemy_melee_component: EnemyMeleeComponent = other_hitbox.get_parent()
		
		var damage := enemy_melee_component.get_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()
		
		if not projectile.is_from_player():
			var damage := projectile.get_damage() * defense_multiplier
			self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("tauron_boss_stomp_attack_hitbox"):
		var boss: TauronBoss = other_hitbox.get_parent()

		var damage := boss.get_stomp_attack_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("tauron_boss_charge_attack_hitbox"):
		var boss: TauronBoss = other_hitbox.get_parent()

		var damage := boss.get_charge_attack_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("paul_boss_melee_attack_hitbox"):
		var boss: PaulBoss = other_hitbox.get_parent()

		var damage := boss.get_melee_attack_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("shale_saber_boss_melee_attack_hitbox"):
		var boss: ShaleSaberBoss = other_hitbox.get_parent().get_parent()

		var damage := boss.get_melee_attack_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("astral_lineus_head_hitbox"):
		var boss: AstralLineusBoss = other_hitbox.get_parent().get_parent().get_parent()

		var damage := boss.get_head_segment_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("astral_lineus_body_hitbox"):
		var boss: AstralLineusBoss = other_hitbox.get_parent().get_parent().get_parent()

		var damage := boss.get_body_segment_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("astral_lineus_tail_hitbox"):
		var boss: AstralLineusBoss = other_hitbox.get_parent().get_parent().get_parent()

		var damage := boss.get_tail_segment_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("astral_lineus_attack_3_laser_hitbox"):
		var boss: AstralLineusBoss = other_hitbox.get_parent().get_parent()

		var damage := boss.get_attack_3_laser_damage() * defense_multiplier
		self.health_component.take_damage(damage)

	elif other_hitbox.is_in_group("checkpoint_hitbox"):
		self.checkpoint_component.try_to_use(other_hitbox.get_parent())


func set_animation(animation: String):
	#var direction = "Side" if sprite_direction in ["Left", "Right"] else sprite_direction    
	_sprite.play(animation) #Add {+ direction} to animation if up and down _sprite animations are implemented. Remember to edit the animation names too if it happens
	_sprite.flip_h = (_current_sprite_direction == Util.Direction.LEFT)
	#_weapon_sprite.flip_h = (sprite_direction == "Left") #ANTHONY REMEMBER TO FIX THIS GOD DAMN # ('_'): what is going on here


## Allows the player to use this weapon.
func add_weapon_type(weapon_type: Util.WeaponType) -> void:
	_weapon.add_weapon_type(weapon_type)


## Gives the player a status effect.
func add_status_effect(effect: Util.StatusEffect) -> void:
	self.status_effect_component.gain_effect(effect)


## Makes the player stop charging the dash.
func _stop_running() -> void:
	self.set_animation("Idle")
	_current_speed = WALKING_SPEED
	_is_timer_on = false
	_is_running = false
	$RunCountdown.stop()


func _try_to_dodge() -> void:
	# The dodge attempt fails if the player is already dodging or the 
	# player doesn't have enough mana.
	if _is_dodging or not self.mana_component.has_enough_mana(1):
		return

	_is_dodging = true

	self.mana_component.use_mana(1)

	# Make the player partially transparent.
	self.modulate.a = 0.5

	# Reuse dash SFX.
	$InitialDashParticles.emitting = true
	$InitialDashSFX.play()

	var async_callback := func():
		await SceneManager.async_delay(DODGE_DURATION)

		# Make the player opaque.
		self.modulate.a = 1.0

		_is_dodging = false

	async_callback.call() # async call


func _check_and_set_if_should_be_slipping() -> void:
	_is_slipping = false

	# If any of the hitboxes overlapping with the feet's hitbox 
	# is a 'Slippery Floor Tile', then the player should be slipping.
	for hitbox in _feet_hitbox.get_overlapping_areas():
		if hitbox.is_in_group("slippery_floor_tile_hitbox"):
			_is_slipping = true
			break


func _get_input_direction() -> Vector2:
	var input_direction := Input.get_vector( "move_left", "move_right", "move_up", "move_down")
	return input_direction


func _get_sprite_direction() -> Util.Direction:
	var input_x_component := _get_input_direction().x

	if input_x_component < 0.0:
		return Util.Direction.LEFT
	
	elif input_x_component > 0.0:
		return Util.Direction.RIGHT
	
	else:
		return _current_sprite_direction


func _on_timer_timeout():
	_current_speed *= DASH_MULTIPLIER
	_is_running = true
	$InitialDashParticles.emitting = true
	$InitialDashSFX.play()

