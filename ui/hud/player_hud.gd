extends Control

@onready var _heart_box_container: HBoxContainer = self.get_node("HeartBoxContainer")
@onready var _mana_box_container: HBoxContainer = self.get_node("ManaBoxContainer")

var _player_health_component: HealthComponent
var _player_mana_component: ManaComponent

var _ui_hearts: Array[TextureRect] = []
var _ui_mana_crystals: Array[TextureRect] = []

func _ready() -> void:
	_player_health_component = (self.get_node("../Player") as Player).health_component
	_player_health_component.health_changed.connect(_on_player_health_changed)

	_player_mana_component = (self.get_node("../Player") as Player).mana_component
	_player_mana_component.mana_amount_changed.connect(_on_player_mana_amount_changed)

	for heart in _heart_box_container.get_children():
		_ui_hearts.push_back(heart as TextureRect)

	for mana_crystal in _mana_box_container.get_children():
		_ui_mana_crystals.push_front(mana_crystal as TextureRect)

	_render_player_hearts()
	_render_player_mana_crystals()


func _on_player_health_changed() -> void:
	_render_player_hearts()


func _on_player_mana_amount_changed() -> void:
	_render_player_mana_crystals()


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
	const FULL_CRYSTAL_REGION_IDX := 0
	const EMPTY_CRYSTAL_REGION_IDX := 16

	# Each mana crystal in the UI corresponds with one mana.
	var mana_crystals_left := _player_mana_component.get_mana_amount()

	for ui_mana_crystal in _ui_mana_crystals:
		var ui_mana_crystal_atlas := ui_mana_crystal.texture as AtlasTexture

		# There are still mana crystals to be filled.
		if mana_crystals_left != 0:
			ui_mana_crystal_atlas.region.position.x = FULL_CRYSTAL_REGION_IDX
			mana_crystals_left -= 1
			continue

		# The rest of the mana crystals should be empty.
		else:
			ui_mana_crystal_atlas.region.position.x = EMPTY_CRYSTAL_REGION_IDX
			continue

