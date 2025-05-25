extends Area2D

## Daño al entrar en contacto con la lava
@export var damage_on_contact := 20
## Daño por segundo mientras está en la lava
@export var damage_per_second := 15
## Intervalo entre daños (en segundos)
@export var damage_interval := 0.5
## Empuje hacia arriba al entrar en la lava
@export var bounce_force := 200.0

var bodies_in_lava := []
var _timer := 0.0

func _ready():
	# Conexión de señales con verificación
	if body_entered.connect(_on_body_entered) != OK:
		push_error("Failed to connect body_entered signal")
	if body_exited.connect(_on_body_exited) != OK:
		push_error("Failed to connect body_exited signal")
	
	# Configuración inicial
	monitoring = true
	monitorable = true

func _on_body_entered(body: Node):
	if not is_instance_valid(body):
		return
	
	if body.has_method("take_damage"):
		# Aplicar daño inicial
		body.take_damage(damage_on_contact)
		
		# Aplicar pequeño empuje hacia arriba
		if body is CharacterBody2D:
			body.velocity.y = -bounce_force
		
		# Registrar cuerpo en la lava
		if not body in bodies_in_lava:
			bodies_in_lava.append(body)
			
		# Efecto visual/sonoro
		_play_lava_effect(body)

func _on_body_exited(body: Node):
	if body in bodies_in_lava:
		bodies_in_lava.erase(body)
		_stop_lava_effect(body)

func _process(delta: float):
	_timer += delta
	if _timer >= damage_interval:
		_timer = 0.0
		_apply_damage_to_bodies()

func _apply_damage_to_bodies():
	for body in bodies_in_lava:
		if is_instance_valid(body) and body.has_method("take_damage"):
			# Calcula daño proporcional al intervalo
			body.take_damage(damage_per_second * damage_interval)
			_play_lava_effect(body)

func _play_lava_effect(body: Node):
	# Efectos cuando el cuerpo está en la lava
	if body.has_method("set_on_fire"):
		body.set_on_fire(true)
	

func _stop_lava_effect(body: Node):
	# Detener efectos cuando sale de la lava
	if body.has_method("set_on_fire"):
		body.set_on_fire(false)

func _exit_tree():
	# Limpieza al salir
	for body in bodies_in_lava:
		_stop_lava_effect(body)
	bodies_in_lava.clear()


func _on_sprite_2d_texture_changed() -> void:
	pass # Replace with function body.
