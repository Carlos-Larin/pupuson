extends CharacterBody2D

@export var speed := 60.0
@export var bounce_force := 200.0

@export var damage_on_contact := 5
@export var damage_per_second := 2.5
@export var damage_interval := 0.5

var direction := -1
var bodies_in_contact := []
var _timer := 0.0

func _ready():
	var damage_area = $DamageArea
	if damage_area:
		damage_area.connect("body_entered", _on_body_entered)
		damage_area.connect("body_exited", _on_body_exited)

func _physics_process(delta: float) -> void:
	# Movimiento simple hacia izquierda/derecha
	velocity.x = direction * speed
	move_and_slide()

	# Daño continuo
	_timer += delta
	if _timer >= damage_interval:
		_timer = 0.0
		_apply_damage_to_bodies()

	# Cambio de dirección al chocar (opcional)
	if is_on_wall():
		_turn_around()

func _turn_around():
	direction *= -1
	$Sprite2D.flip_h = direction > 0

func _on_body_entered(body: Node):
	if not is_instance_valid(body):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage_on_contact)

		# Empuje vertical
		if body is CharacterBody2D:
			body.velocity.y = -bounce_force

		if not body in bodies_in_contact:
			bodies_in_contact.append(body)

		_play_lava_effect(body)

func _on_body_exited(body: Node):
	if body in bodies_in_contact:
		bodies_in_contact.erase(body)
		_stop_lava_effect(body)

func _apply_damage_to_bodies():
	for body in bodies_in_contact:
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
	for body in bodies_in_contact:
		_stop_lava_effect(body)
	bodies_in_contact.clear()
