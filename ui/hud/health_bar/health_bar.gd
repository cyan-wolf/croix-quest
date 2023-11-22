extends ProgressBar

@export var _color: Color = Color("ff0000")

var _health_component: HealthComponent


func _ready() -> void:
	var sb := StyleBoxFlat.new()
	self.add_theme_stylebox_override("fill", sb)
	sb.bg_color = _color


func initialize(health_component: HealthComponent) -> void:
	_health_component = health_component
	_health_component.health_changed.connect(_on_health_changed)


func _on_health_changed() -> void:
	var ratio_to_full_health: float = \
	(_health_component.get_health() as float) / _health_component.get_max_health()

	self.value = ratio_to_full_health

