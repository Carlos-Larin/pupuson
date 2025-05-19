extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Variables de salud
var max_health := 100
var health := max_health
var is_invincible := false
var invincibility_time := 0.5

# Posición inicial
var start_position := Vector2.ZERO

func _ready() -> void:
	start_position = position  # Guardamos la posición inicial
	update_health_label()

func _physics_process(delta: float) -> void:
	# Gravedad
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

	# Actualiza la salud en pantalla cada frame
	update_health_label()

func take_damage(amount: int) -> void:
	if is_invincible:
		return
		
	health -= amount
	print("¡Daño recibido! Salud restante: ", health)
	
	# Invencibilidad temporal
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false
	
	if health <= 0:
		die()

func die() -> void:
	print("¡Personaje derrotado!")
	# Restauramos la salud y la posición
	health = max_health
	position = start_position
	velocity = Vector2.ZERO

func update_health_label() -> void:
	var label = $HealthLabel
	label.text = "Salud: %d" % health
