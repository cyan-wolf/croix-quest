extends Control

@onready var _heart_box_container: HBoxContainer = self.get_node("HeartBoxContainer")
@onready var _mana_box_container: HBoxContainer = self.get_node("ManaBoxContainer")

var _player_health_component: HealthComponent

func _ready() -> void:
	_player_health_component = (self.get_node("../Player") as Player).health_component
	_player_health_component.health_changed.connect(_on_player_health_changed)


func _on_player_health_changed() -> void:
	_render_player_info()


func _render_player_info() -> void:
	# TODO
	pass

