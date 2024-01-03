extends CharacterBody2D

const DEFEATED_SCENE := preload("res://enemies/bosses/paul/defeated/paul_boss_defeated.tscn")

signal perform_attack_1
signal perform_attack_2
signal perform_attack_3

enum AttackState {
	IDLE = 0,
	WALKING = 1,
	MELEE_ATTACK = 2,
	MAGIC_ATTACK = 3,
	DEFEATED = 4,
}

## The scene of the melee enemy to be summoned.
@export var _melee_enemy_scene: PackedScene

## The scene of the ranged enemy to be summoned.
@export var _shooting_enemy_scene: PackedScene

@export_range(0.0, 100.0) var _enemy_spawn_chance_percent: float = 50.0

@export var health_component: HealthComponent

@export var _melee_attack_damage: int = 3

@export var _projectile_attack_damage: int = 1

## In pixels per second.
@export var _follow_speed: float = 3.0 * 16

@onready var _hitbox: Area2D = self.get_node("HitboxArea")

@onready var _melee_attack_hitbox: Area2D = self.get_node("MeleeAttackHitboxArea")

@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

var _current_attack_state := AttackState.IDLE

# The enemy summon position markers need to be added manually under 
# an 'EnemySummonPositions' node.
var _enemy_summon_positions: Array[Node2D] = []

var _is_following_player := false

func _ready() -> void:
	_hitbox.area_entered.connect(_on_area_entered_hitbox)

	self.perform_attack_1.connect(_async_on_perform_attack_1)
	self.perform_attack_2.connect(_async_on_perform_attack_2)
	self.perform_attack_3.connect(_async_on_perform_attack_3)

	self.health_component.death.connect(_on_death)

	# Add the child nodes of 'EnemySummonPositions' to `_enemy_summon_positions`.
	_enemy_summon_positions.append_array(self.get_node("../EnemySummonPositions").get_children())

	# Setup the boss health bar.
	SceneManager.find_boss_health_bar().initialize(
		self.health_component,
		"Paul",
	)

	# Play music.
	SceneManager.play_background_music("res://sounds/music/Orbital Colossus/Orbital Colossus.mp3")

	self.perform_attack_1.emit()


func _process(_delta: float) -> void:
	_play_animation_based_on_state()


func _physics_process(delta: float):
	if _is_following_player:
		var vel_direction := self.global_position.direction_to(SceneManager.find_player().global_position)

		self.velocity = vel_direction * _follow_speed

	else:
		self.velocity = Vector2.ZERO

	var _col := self.move_and_collide(self.velocity * delta)


func _on_area_entered_hitbox(other_hitbox: Area2D) -> void:
	# Logic for taking projectile damage.
	if other_hitbox.is_in_group("projectile_hitbox"):
		var projectile: Projectile = other_hitbox.get_parent()

		if projectile.is_from_player():
			self.health_component.take_damage(projectile.get_damage())

			SceneManager.async_shake_camera(0.9, 0.1) # async call


# A back-and-forth attack with a large club.
func _async_on_perform_attack_1() -> void:
	await SceneManager.async_delay(2.0)

	_is_following_player = true
	_set_attack_state(AttackState.WALKING)

	await SceneManager.async_delay(3.0)

	_is_following_player = false

	_clear_attack_state()
	await SceneManager.async_delay(0.4)

	# Makes the boss do a powerful melee attack.
	_set_attack_state(AttackState.MELEE_ATTACK)

	var melee_attack_hitbox_col: CollisionShape2D = _melee_attack_hitbox.get_node("CollisionShape2D")

	melee_attack_hitbox_col.set_deferred("disabled", false)
	await SceneManager.async_delay(1.0)
	melee_attack_hitbox_col.set_deferred("disabled", true)

	_clear_attack_state()
	await SceneManager.async_delay(1.0)

	self.perform_attack_2.emit()


# A projectile attack.
func _async_on_perform_attack_2() -> void:
	await SceneManager.async_delay(2.0)
	_set_attack_state(AttackState.MAGIC_ATTACK)

	# The maximum angle spread of the projectiles.
	var max_angle_in_deg := 30.0

	# How many "pairs" of projectiles will be fired.
	var projectile_pair_amount := 10

	# Used to keep track the different angle spreads.
	var curr_angle_in_deg := 0.0

	while curr_angle_in_deg <= max_angle_in_deg:
		_fire_projectile(curr_angle_in_deg)

		if curr_angle_in_deg != 0.0:
			_fire_projectile(-curr_angle_in_deg)

		curr_angle_in_deg += max_angle_in_deg / projectile_pair_amount

		await SceneManager.async_delay(0.3)

	_clear_attack_state()

	self.perform_attack_3.emit()


# An attack that summons enemies.
func _async_on_perform_attack_3() -> void:
	await SceneManager.async_delay(2.0)
	_set_attack_state(AttackState.MAGIC_ATTACK)
	
	for i in range(len(_enemy_summon_positions)):
		# The number of summoned enemies in the scene.
		var summoned_enemy_amount := len(self.get_node("../SummonedEnemies").get_children())

		# Stop spawning enemies if there are too many.
		if summoned_enemy_amount == len(_enemy_summon_positions):
			break

		var pos_marker: Node2D = _enemy_summon_positions[i]

		var enemy_to_summon: Node2D

		randomize()
		var _should_summon_melee_enemy := Util.return_true_given_probability(_enemy_spawn_chance_percent / 100.0)
		var _should_summon_shooting_enemy := Util.return_true_given_probability(_enemy_spawn_chance_percent / 100.0)

		# A chance to summon melee enemies for even indices.
		if (i % 2 == 0) and _should_summon_melee_enemy:
			enemy_to_summon = _melee_enemy_scene.instantiate()

		# A chance to summon shooting enemies for odd indices.
		elif (i % 2 == 1) and _should_summon_shooting_enemy:
			enemy_to_summon = _shooting_enemy_scene.instantiate()

		# Continue to the next iteration if an enemy wasn't summoned.
		else:
			continue

		# Move the enemy to the position marker.
		enemy_to_summon.global_position = pos_marker.global_position

		# Add the enemy to the a node called 'SummonedEnemies' in the current scene.
		self.get_tree().current_scene.get_node("SummonedEnemies").add_child(enemy_to_summon)

		# Small delay to avoid processing everything at once.
		await SceneManager.async_delay(0.1)

	# Clear the attack state (used for animations) after leaving the summoning loop.
	await SceneManager.async_delay(0.5)
	_clear_attack_state()

	self.perform_attack_1.emit()


func _on_death() -> void:
	self.hide()

	# Defeat all the summoned enemies.
	for enemy in self.get_node("../SummonedEnemies").get_children():
		var enemy_health_component: HealthComponent = enemy.get_node("EnemyComponent").health_component
		enemy_health_component.take_damage(enemy_health_component.get_max_health())

	# Replace the boss with its defeated version, in order to 
	# show the defeat animation.
	var defeated_version := DEFEATED_SCENE.instantiate()
	defeated_version.global_position = self.global_position
	self.get_tree().current_scene.add_child(defeated_version)

	self.queue_free()


func _fire_projectile(offset_angle_in_degrees: float) -> void:
	# The projectile is fired from the boss' club (top-right corner of its sprite).
	var summon_pos := self.global_position + Vector2.UP * 18 + Vector2.RIGHT * 26

	var direction := summon_pos.direction_to(SceneManager.find_player().global_position)
	direction = direction.rotated(deg_to_rad(offset_angle_in_degrees))

	var speed := 120.0

	Projectile.start_building() \
		.with_global_pos(summon_pos) \
		.with_impulse(direction * speed) \
		.from_source(Projectile.Source.PAUL_BOSS) \
		.with_damage(_projectile_attack_damage) \
		.with_trail_gradient(Projectile.TrailConsts.PAUL_BOSS) \
		.add_to_scene()


func _play_animation_based_on_state() -> void:
	var anim_name := ""

	match _current_attack_state:
		AttackState.IDLE:
			anim_name = "idle"

		AttackState.WALKING:
			anim_name = "walk"

		AttackState.MELEE_ATTACK:
			anim_name = "melee_attack"

		AttackState.MAGIC_ATTACK:
			anim_name = "magic_attack"

		AttackState.DEFEATED:
			anim_name = "defeat"

	_sprite.play(anim_name)


func _set_attack_state(new_state: AttackState) -> void:
	_current_attack_state = new_state


## Sets `_current_attack_state` to `AttackState.IDLE`.
func _clear_attack_state() -> void:
	_current_attack_state = AttackState.IDLE


func get_melee_attack_damage() -> int:
	return _melee_attack_damage
