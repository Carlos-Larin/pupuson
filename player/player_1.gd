extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const LADDER_SPEED = 100.0
const INVINCIBILITY_TIME = 0.5

# Doble salto
const maxjump = 1
var salto = 0
var suelo = true
var jump_doble = 320

# Salud
var max_health := 100
var health := max_health
var is_invincible := false

# Escalera
var escalera := false
var Gravity = 10

# Posición de respawn
var start_position := Vector2.ZERO

func _ready() -> void:
	start_position = global_position
	update_health_bar()

func _physics_process(delta: float) -> void:
	if escalera:
		velocity.y = 0
		if Input.is_action_pressed("ui_up"):
			Gravity = 0
			velocity.y = -LADDER_SPEED
		elif Input.is_action_pressed("ui_down"):
			Gravity = 0
			velocity.y = LADDER_SPEED
		else:
			velocity.y = 0
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Salto y doble salto
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			salto = 1
		elif salto < maxjump:
			velocity.y = JUMP_VELOCITY
			salto += 1

	if is_on_floor():
		salto = 0

	# Movimiento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_health_bar()

	# --------- ANIMACIÓN CON AnimationPlayer ----------
	var sprite = $Sprite2D  # Cambiá si tu Sprite tiene otro nombre
	var animator = $AnimationPlayer

	if direction != 0:
		sprite.scale.x = 1 if direction > 0 else -1

		if not animator.is_playing():
			animator.play("walkingPeople")
	else:
		if animator.is_playing():
			animator.stop()

func take_damage(amount: int) -> void:
	if is_invincible:
		return

	health -= amount
	health = max(health, 0)
	print("¡Daño recibido! Salud restante: ", health)
	update_health_bar()

	is_invincible = true
	await get_tree().create_timer(INVINCIBILITY_TIME).timeout
	is_invincible = false

	if health <= 0:
		die()

func die() -> void:
	print("¡Personaje derrotado!")
	health = max_health
	global_position = start_position
	update_health_bar()

func update_health_bar() -> void:
	var bar = get_node("HealthBar")
	bar.max_value = max_health
	bar.value = health

	var fill_style = StyleBoxFlat.new()
	if health >= 80:
		fill_style.bg_color = Color(0.0, 1.0, 0.0)  # verde
	elif health >= 60:
		fill_style.bg_color = Color(1.0, 1.0, 0.0)  # amarillo
	elif health >= 30:
		fill_style.bg_color = Color(1.0, 0.5, 0.0)  # naranja
	else:
		fill_style.bg_color = Color(1.0, 0.0, 0.0)  # rojo

	fill_style.set_content_margin_all(2)
	bar.add_theme_stylebox_override("fill", fill_style)
	bar.custom_minimum_size = Vector2(0, 16)
