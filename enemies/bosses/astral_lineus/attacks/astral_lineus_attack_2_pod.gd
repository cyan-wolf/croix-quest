extends Node2D

const Projectile := preload("res://weapons/projectile/projectile.gd")

func async_explode_into_projectiles(projectile_amount: int, damage: int, speed: float) -> void:
	# TODO: Show a particle effect here.
	self.hide()

	for _i in range(projectile_amount):
		randomize()

		var rand_angle := randf_range(0.0, TAU)
		# An arbitary unit vector rotated by a random angle.
		var direction := Vector2.RIGHT.rotated(rand_angle)
		
		Projectile.start_building() \
			.with_global_pos(self.global_position) \
			.with_impulse(direction * speed) \
			.from_source(Projectile.Source.ASTRAL_LINEUS_BOSS) \
			.with_damage(damage) \
			.add_to_scene()

		await SceneManager.async_delay(0.1)

	self.queue_free()

