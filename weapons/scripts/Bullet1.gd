extends RigidBody2D

var lifetime: float = 0.0
var damage: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Despawn the bullet if it doesn't hit anything by this point.
	await self.get_tree().create_timer(lifetime).timeout
	self.queue_free()
	#print_debug(damage)


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
