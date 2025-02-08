extends SpotLight3D

@export var min_flicker_time: float = 0.1  # Temps min entre clignotements
@export var max_flicker_time: float = 1.5  # Temps max entre clignotements
@export var min_intensity: float = 0.2     # Intensité minimale
@export var max_intensity: float = 1.0     # Intensité maximale

var flicker_timer: float = 0.0
var target_intensity: float = 1.0

func _ready():
	randomize()
	_schedule_next_flicker()

func _process(delta):
	flicker_timer -= delta
	if flicker_timer <= 0:
		_flicker()
		_schedule_next_flicker()

func _flicker():
	if randf() < 0.3:  # 30% de chance que la lumière s'éteigne totalement
		target_intensity = 0.0
	else:
		target_intensity = randf_range(min_intensity, max_intensity)
	
	light_energy = target_intensity

func _schedule_next_flicker():
	flicker_timer = randf_range(min_flicker_time, max_flicker_time)
