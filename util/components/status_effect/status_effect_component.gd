extends Node2D
class_name StatusEffectComponent

var _status_effects_flag: int = Util.StatusEffectType.NONE as int

func _ready() -> void:
	pass


func gain_effect(effect: Util.StatusEffect) -> void:
	# Use `effect.duration_in_secs` to remove effects after the duration.

	# TODO: Figure out how to remove status effects after the given duration.
	# The duration needs be different for each effect.
	# If the player or enemy already has this effect, the duration should be 
	# overriden and nothing weird should happen.
	# The solution will probably involve timers.
	pass


func _check_if_has_effect(effect: Util.StatusEffectType) -> bool:
	return _status_effects_flag & effect


func _add_effect(effect: Util.StatusEffectType) -> void:
	_status_effects_flag |= effect


func _remove_effect(effect: Util.StatusEffectType) -> void:
	if _check_if_has_effect(effect):
		_status_effects_flag &= ~effect


func get_computed_speed_multiplier() -> float:
	return 0.0

