extends Area2D

## Daño al entrar en contacto con la sierra/lava
@export var damage_on_contact := 20
## Daño por segundo mientras está en contacto
@export var damage_per_second := 15
## Intervalo entre daños (en segundos)
@export var damage_interval := 0.5
## Empuje hacia arriba al hacer contacto
@export var bounce_force := 200.0
## Velocidad de rotación de la sierra (radianes por segundo)
@export var rotation_speed := 5.0

var bodies_in_lava := []
var _timer := 0.0

func _ready():
	if body_entered.connect(_on_body_entered) != OK:
		push_error("Failed to connect body_entered signal")
	if body_exited.connect(_on_body_exited) != OK:
		push_error("Failed to connect body_exited signal")
	
	monitoring = true
	monitorable = true

func _on_body_entered(body: Node):
	if not is_instance_valid(body):
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage_on_contact)

		if body is CharacterBody2D:
			body.velocity.y = -bounce_force

		if not body in bodies_in_lava:
			bodies_in_lava.append(body)
		
	
func _on_body_exited(body: Node):
	if body in bodies_in_lava:
		bodies_in_lava.erase(body)
		_stop_lava_effect(body)

func _process(delta: float):
	_timer += delta
	if _timer >= damage_interval:
		_timer = 0.0
		_apply_damage_to_bodies()


	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.rotation += rotation_speed * delta

func _apply_damage_to_bodies():
	for body in bodies_in_lava:
		if is_instance_valid(body) and body.has_method("take_damage"):
			body.take_damage(damage_per_second * damage_interval)
			_play_lava_effect(body)

func _play_lava_effect(body: Node):
	if body.has_method("set_on_fire"):
		body.set_on_fire(true)

func _stop_lava_effect(body: Node):
	if body.has_method("set_on_fire"):
		body.set_on_fire(false)

func _exit_tree():
	for body in bodies_in_lava:
		_stop_lava_effect(body)
	bodies_in_lava.clear()
