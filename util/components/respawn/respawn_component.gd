extends Resource
class_name RespawnComponent

signal lives_amount_changed
signal respawned

const MAX_LIVES := 4

@export var _lives_amount: int = 4

## This function is called by the UI, which already checks if the 
## player has enough lives to respawn.
func respawn() -> void:
	var player: Player = SceneManager.find_player()

	# Move the player over to the last checkpoint.
	player.global_position = player.checkpoint_component.get_last_checkpoint_pos()

	# Regain all health.
	player.health_component.gain_health(player.health_component.get_max_health())

	SceneManager.remove_world_state(Util.WorldState.PLAYER_IS_DEAD)

	self.use_life()

	self.respawned.emit()

	
func get_lives_amount() -> int:
	return _lives_amount


func can_respawn() -> bool:
	return self.get_lives_amount() > 0


func use_life() -> void:
	# Don't run the code below again if the player already has 0 lives.
	if _lives_amount == 0:
		return

	# Makes sure that the `_lives_amount` is always between 0 and `MAX_LIVES`.
	_lives_amount = clampi(_lives_amount - 1, 0, MAX_LIVES)

	self.lives_amount_changed.emit()


func gain_life() -> void:
	# Makes sure that the `_lives_amount` is always between 0 and `MAX_LIVES`.
	_lives_amount = clampi(_lives_amount + 1, 0, MAX_LIVES)

	self.lives_amount_changed.emit()

