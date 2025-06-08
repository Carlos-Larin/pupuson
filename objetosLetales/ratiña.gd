extends CharacterBody2D

@export var speed := 60.0
@export var bounce_force := 200.0
@export var gravity := 980.0  # Gravedad estándar en píxeles/seg²
@export var damage_on_contact := 5
@export var damage_per_second := 2.5
@export var damage_interval := 0.5
@export var respawn_delay := 0.0
@export var max_health := 50.0

var direction := -1
var bodies_in_contact := []
var _timer := 0.0
var health := max_health
var is_dead := false
var original_position: Vector2
var original_direction: int
var player

@onready var animationPlayer = $AnimationPlayer
@onready var edge_raycast = $EdgeRayCast
@onready var floor_raycast = $FloorRayCast  # Nuevo RayCast para detectar suelo

func _ready():
	original_position = global_position
	original_direction = direction
	
	var damage_area = $DamageArea
	if damage_area:
		damage_area.connect("body_entered", _on_body_entered)
		damage_area.connect("body_exited", _on_body_exited)
	
	connect_to_player()

func connect_to_player():
	player = get_tree().get_root().find_child("player1", true, false)
	if player and player.has_signal("died"):
		if not player.died.is_connected(_on_player_died):
			player.died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Resetear velocidad vertical cuando está en el suelo
	
	# Movimiento horizontal
	velocity.x = direction * speed
	animationPlayer.play("walk")
	
	# Voltear sprite
	$Sprite2D.flip_h = direction > 0
	
	# Daño continuo
	_timer += delta
	if _timer >= damage_interval:
		_timer = 0.0
		_apply_damage_to_bodies()
	
	# Detección de pared, borde o falta de suelo
	if is_on_wall() or not edge_raycast.is_colliding() or not floor_raycast.is_colliding():
		animationPlayer.play("idle")
		_turn_around()
	
	move_and_slide()

func take_damage(amount: float):
	if is_dead:
		return
	
	health -= amount
	print("Rata recibió daño: ", amount, " - Salud restante: ", health)
	
	if health <= 0:
		die()

func die():
	is_dead = true
	animationPlayer.play("die")
	$CollisionShape2D.set_deferred("disabled", true)
	
	for body in bodies_in_contact:
		_stop_lava_effect(body)
	bodies_in_contact.clear()

func _on_player_died():
	get_tree().create_timer(respawn_delay).timeout.connect(_respawn)

func _respawn():
	if not is_dead:
		return
	
	health = max_health
	is_dead = false
	global_position = original_position
	direction = original_direction
	velocity = Vector2.ZERO  # Resetear velocidad
	$Sprite2D.flip_h = direction > 0
	edge_raycast.position.x = abs(edge_raycast.position.x) * original_direction
	$CollisionShape2D.set_deferred("disabled", false)
	animationPlayer.play("walk")
	
	connect_to_player()

func _turn_around():
	direction *= -1
	$Sprite2D.flip_h = direction > 0
	edge_raycast.position.x *= -1
	floor_raycast.position.x *= -1  # También voltear el raycast de suelo

func _on_body_entered(body: Node):
	if is_dead or not is_instance_valid(body):
		return

	if body is CharacterBody2D and body.has_method("take_damage") == false:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage_on_contact)
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
