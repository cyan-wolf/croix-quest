extends Node2D

const WallDiscSwitch := preload("wall_disc_switch.gd")

@onready var _sprite: AnimatedSprite2D = self.get_node("AnimatedSprite2D")

# The "wall disc switches" associated with this door must be added manually 
# as child nodes.
var _linked_switches: Array[WallDiscSwitch] = []

var _switches_needed_to_open: int = 0 # default value

func _ready() -> void:
	for n in self.get_node("WallDiscSwitches").get_children():
		print_debug(n)

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

	for switch in _linked_switches:
		# Changes their sprite to show that they are "fully activated".
		switch.complete_activation()

	# TODO: Activate a teleporter here so that the door actually does something.

