extends Node2D
class_name StatusEffectComponent

var _current_effects_map: Dictionary = {}

func _ready() -> void:
	pass


func gain_effect(effect: Util.StatusEffect) -> void:
	if _current_effects_map.has(effect.type):
		var old_effect_timer: Timer = _current_effects_map[effect.type]

		if effect.duration_in_secs >= old_effect_timer.time_left:
			_remove_effect(effect.type)
			_add_effect_with_timer(effect)

		else:
			# Do nothing since the new effect lasts less than the current one.
			pass

	else:
		_add_effect_with_timer(effect)


func _add_effect_with_timer(effect: Util.StatusEffect) -> void:
	var effect_timer := Timer.new()

	self.add_child(effect_timer)

	effect_timer.one_shot = true
	effect_timer.start(effect.duration_in_secs)

	_current_effects_map[effect.type] = effect_timer

	effect_timer.timeout.connect(func(): _remove_effect(effect.type))


func _remove_effect(effect_type: Util.StatusEffectType) -> void:
	if _current_effects_map.has(effect_type):
		var effect_timer: Timer = _current_effects_map[effect_type]

		_current_effects_map.erase(effect_type)

		effect_timer.queue_free()


func get_computed_speed_multiplier() -> float:
	if _current_effects_map.has(Util.StatusEffectType.SPEED):
		return 1.5	# 1.5x speed boost

	else:
		return 1.0	# regular speed


func get_computed_defense_multiplier() -> int:
	const PROBABILITY_TO_CANCEL_DAMAGE := 0.50	# 50% chance

	if _current_effects_map.has(Util.StatusEffectType.DEFENSE):
		# This expression is true depending on `PROBABILITY_TO_CANCEL_DAMAGE`.
		# Example: If the probability is 0.45, then this is true 45% of the time.
		var should_cancel_damage := Util.return_true_given_probability(PROBABILITY_TO_CANCEL_DAMAGE)

		if should_cancel_damage:
			return 0	# complete damage reduction
		else:
			return 1	# regular damage

	else:
		return 1		# regular damage




