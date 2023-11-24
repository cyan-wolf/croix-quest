extends Control
class_name BossHealthBar

@onready var _health_bar: HealthBar = self.get_node("HealthBar")
@onready var _boss_name_label: Label = self.get_node("BossNameLabel")


## Initializes the boss health bar. This node stores a reference to 
## the health component in order to update the health and show it.
func initialize(health_component: HealthComponent, boss_name: String) -> void:
	_health_bar.initialize(health_component)
	_boss_name_label.text = boss_name

	# The boss bar is usually hidden, so it should be made visible now.
	self.show()


