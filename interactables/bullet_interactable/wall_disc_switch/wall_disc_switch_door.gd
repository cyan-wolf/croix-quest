extends Node2D

const WallDiscSwitch := preload("wall_disc_switch.gd")
const Teleporter := preload("res://util/teleporter/teleporter.gd")

@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

# This node must be added manually.
@onready var _teleporter: Teleporter = self.get_node("Teleporter")

# The "wall disc switches" associated with this door must be added manually 
# as child nodes under a node called "WallDiscSwitches".
var _linked_switches: Array[WallDiscSwitch] = []

var _switches_needed_to_open: int = 0 # default value

func _ready() -> void:
	# Deactivates the teleporter just in case since they are active by default.
	_teleporter.deactivate()

	for n in self.get_node("WallDiscSwitches").get_children():
		var switch: WallDiscSwitch = n

		_linked_switches.append(switch)
		_switches_needed_to_open += 1

		switch.hit.connect(_on_switch_activation)


func _on_switch_activation() -> void:
	_switches_needed_to_open -= 1

	if _switches_needed_to_open == 0:
		_open()


func _open() -> void:
	_sprite.play("open")
	_teleporter.activate()

	for switch in _linked_switches:
		# Changes their sprite to show that they are "fully activated".
		switch.complete_activation()

