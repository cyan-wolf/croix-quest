extends AnimatableBody2D

@onready var _interaction_component: InteractionComponent = self.get_node("InteractionComponent")

# When this obstacle has collision, a dialog pops up telling the 
# player the futility of their actions.
@export var _cant_move_dialog: DialogResource

# When this obstacle has no collision, a dialog pops up telling the 
# player that the shadow can be walked past now.
@export var _walkable_dialog: DialogResource

## These are the light crystals that are nearest to the obstacles.
@export var _light_crystals_needed_to_activate: Array[LightCrystal] = []

var _currently_activated_light_crystals: int = 0

# Flag marking when the obstacle has collision.
var _has_collision := true

func _ready() -> void:
	_interaction_component.interact.connect(_on_player_interact)

	for light_crystal in _light_crystals_needed_to_activate:
		# Connect signals.
		light_crystal.activated.connect(_on_light_crystal_activated)
		light_crystal.deactivated.connect(_on_light_crystal_deactivated)
		

func _on_player_interact() -> void:
	if _has_collision:
		DialogManager.start_dialog(_cant_move_dialog)

	else:
		DialogManager.start_dialog(_walkable_dialog)


func _on_light_crystal_activated() -> void:
	_currently_activated_light_crystals += 1
	_check_if_should_disappear()


func _on_light_crystal_deactivated() -> void:
	_currently_activated_light_crystals -= 1
	_check_if_should_disappear()


func _check_if_should_disappear() -> void:
	if _currently_activated_light_crystals == len(_light_crystals_needed_to_activate):
		_disappear()

	else:
		_reappear()


func _reappear() -> void:
	# Don't do anything if the obstacle already has collision.
	if _has_collision:
		return

	_has_collision = true

	# TODO: Add a sound and particle effect.
	self.modulate = Color("ffffffff")

	# Re-enable collision.
	self.get_node("CollisionShape2D").set_deferred("disabled", false)


func _disappear() -> void:
	_has_collision = false

	# TODO: Add a sound and particle effect.
	self.modulate = Color("ffffff44")

	# Disable collision.
	self.get_node("CollisionShape2D").set_deferred("disabled", true)

