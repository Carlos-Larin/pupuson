extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const LADDER_SPEED = 150.0
const INVINCIBILITY_TIME = 0.5

# Variables de salud
var max_health := 100
var health := max_health
var is_invincible := false

# Movimiento por escalera
var on_ladder := false

# Posición de respawn
var start_position := Vector2.ZERO

func _ready() -> void:
	start_position = global_position  # Guarda la posición inicial
	update_health_label()

func _physics_process(delta: float) -> void:
	if on_ladder:
		velocity.y = 0  # Cancelamos la gravedad en la escalera
		if Input.is_action_pressed("ui_up"):
			velocity.y = -LADDER_SPEED
		elif Input.is_action_pressed("ui_down"):
			velocity.y = LADDER_SPEED
		else:
			velocity.y = 0
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Salto
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Movimiento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_health_label()

func take_damage(amount: int) -> void:
	if is_invincible:
		return

	health -= amount
	print("¡Daño recibido! Salud restante: ", health)
	update_health_label()

	# Efecto de invencibilidad temporal
	is_invincible = true
	await get_tree().create_timer(INVINCIBILITY_TIME).timeout
	is_invincible = false

	if health <= 0:
		die()

func die() -> void:
	print("¡Personaje derrotado!")
	# Reinicia salud y posición
	health = max_health
	global_position = start_position
	update_health_label()

func update_health_label() -> void:
	var label = get_node("HealthLabel")
	label.text = "Salud: %d" % health
