extends Control

@onready var _heart_box_container: HBoxContainer = self.get_node("HeartBoxContainer")
@onready var _mana_box_container: HBoxContainer = self.get_node("ManaBoxContainer")
@onready var _respawn_charm_box_container: HBoxContainer = self.get_node("RespawnCharmBoxContainer")

var _player_health_component: HealthComponent
var _player_mana_component: ManaComponent
var _player_respawn_component: RespawnComponent

var _ui_hearts: Array[TextureRect] = []
var _ui_mana_crystals: Array[TextureRect] = []
var _ui_respawn_charms: Array[TextureRect] = []

func _ready() -> void:
	# Make the HUD visible at the start since it's hidden in the editor for convenience.
	self.show()

	var player: Player = SceneManager.find_player()

	# Get the player's health component so that the HUD can react to any changes.
	_player_health_component = player.health_component
	_player_health_component.health_changed.connect(_on_player_health_changed)

	# Get the player's mana component so that the HUD can react to any changes.
	_player_mana_component = player.mana_component
	_player_mana_component.mana_amount_changed.connect(_on_player_mana_amount_changed)

	# Get the player's respawn component so that the HUD can react to any changes.
	_player_respawn_component = player.respawn_component
	_player_respawn_component.lives_amount_changed.connect(_on_player_lives_amount_changed)

	# Get references to the heart textures in the health bar 
	# to be able to update them. 
	for heart in _heart_box_container.get_children():
		_ui_hearts.push_back(heart as TextureRect)

	# Get references to the mana crystal textures in the 
	# mana bar to be able to update them. 
	for mana_crystal in _mana_box_container.get_children():
		_ui_mana_crystals.push_front(mana_crystal as TextureRect)

	# Get references to the respawn charm textures in the 
	# respawn bar to be able to update them. 
	for respawn_charm in _respawn_charm_box_container.get_children():
		_ui_respawn_charms.push_front(respawn_charm as TextureRect)

	_render_player_hearts()
	_render_player_mana_crystals()
	_render_player_respawn_charms()


func _on_player_health_changed() -> void:
	_render_player_hearts()


func _on_player_mana_amount_changed() -> void:
	_render_player_mana_crystals()


func _on_player_lives_amount_changed() -> void:
	_render_player_respawn_charms()


func _render_player_hearts() -> void:
	# Offsets for the heart atlas texture.
	const FULL_HEART_REGION_IDX := 0
	const HALF_HEART_REGION_IDX := 16
	const EMPTY_HEART_REGION_IDX := 32

	# The heart amount is calculated this way since each heart 
	# represents 2 health points.
	# (Integer division is intentional here).
	var hearts_left := _player_health_component.get_health() / 2

	# The HUD should display a "half heart" if the health is an odd number.
	var has_extra_half_heart := (_player_health_component.get_health() % 2 == 1)

	for ui_heart in _ui_hearts:
		var ui_heart_atlas := ui_heart.texture as AtlasTexture

		# There are still hearts to be filled.
		if hearts_left != 0:
			ui_heart_atlas.region.position.x = FULL_HEART_REGION_IDX
			hearts_left -= 1
			continue

		# A "half heart" should be filled.
		elif has_extra_half_heart:
			ui_heart_atlas.region.position.x = HALF_HEART_REGION_IDX
			has_extra_half_heart = false
			continue

		# The rest of the hearts should be empty.
		else:
			ui_heart_atlas.region.position.x = EMPTY_HEART_REGION_IDX
			continue


func _render_player_mana_crystals() -> void:
	# Offsets for the mana crystal atlas texture.
	const FULL_CHARM_REGION_IDX := 0
	const EMPTY_CRYSTAL_REGION_IDX := 16

	# Each mana crystal in the UI corresponds with one mana.
	var respawn_charms_left := _player_mana_component.get_mana_amount()

	for ui_respawn_charm in _ui_mana_crystals:
		var ui_respawn_charm_atlas := ui_respawn_charm.texture as AtlasTexture

		# There are still mana crystals to be filled.
		if respawn_charms_left != 0:
			ui_respawn_charm_atlas.region.position.x = FULL_CHARM_REGION_IDX
			respawn_charms_left -= 1
			continue

		# The rest of the mana crystals should be empty.
		else:
			ui_respawn_charm_atlas.region.position.x = EMPTY_CRYSTAL_REGION_IDX
			continue


func _render_player_respawn_charms() -> void:
	# Offsets for the respawn charm atlas texture.
	const FULL_CHARM_REGION_IDX := 0
	const EMPTY_CHARM_REGION_IDX := 16

	# Each respawn charm in the UI corresponds with one life.
	var respawn_charms_left := _player_respawn_component.get_lives_amount()

	for ui_respawn_charm in _ui_respawn_charms:
		var ui_respawn_charm_atlas := ui_respawn_charm.texture as AtlasTexture

		# There are still respawn charms to be filled.
		if respawn_charms_left != 0:
			ui_respawn_charm_atlas.region.position.x = FULL_CHARM_REGION_IDX
			respawn_charms_left -= 1
			continue

		# The rest of the respawn charms should be empty.
		else:
			ui_respawn_charm_atlas.region.position.x = EMPTY_CHARM_REGION_IDX
			continue
