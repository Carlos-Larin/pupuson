extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const LADDER_SPEED = 100.0
const INVINCIBILITY_TIME = 0.5

const maxjump = 1
var salto = 0
var suelo = true
var jump_doble = 620

var max_health := 100
var health := max_health
var is_invincible := false

var escalera := false
var Gravity = 10
var start_position := Vector2.ZERO

const Bala = preload("res://objetosLetales/bala.tscn")

const distancia_muzzle := 50.0
const offset_extra := 30.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle

var direction := 0  # La usamos también en disparar()

func _ready() -> void:
	start_position = global_position
	update_health_bar()
	sprite.play("default")

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
	direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
		muzzle.position.x = -abs(muzzle.position.x) if sprite.flip_h else abs(muzzle.position.x)
		if not sprite.is_playing() or sprite.animation != "default":
			sprite.play("default")

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if sprite.animation == "default":
			sprite.stop()
			sprite.frame = 1


	move_and_slide()
	update_health_bar()

	# Disparo
	if Input.is_action_just_pressed("ataque"):
		disparar()

func disparar():
	sprite.play("disparando")
	sprite.frame = 0

	var bala = Bala.instantiate()
	get_tree().current_scene.add_child(bala)
	bala.global_position = muzzle.global_position
	
	# Dirección basada en flip_h (CORRECCIÓN CLAVE)
	var direccion_bala = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	bala.set_direccion(direccion_bala)
	
	# Mover ligeramente la bala para evitar auto-colisión
	bala.global_position += direccion_bala * 10

	await get_tree().create_timer(0.1).timeout
	if direction != 0:
		sprite.play("default")
	else:
		sprite.stop()
		sprite.frame = 1

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

# En el script del jugador, añade esto:
signal died

func die() -> void:
	print("¡Personaje derrotado!")
	died.emit()  # Emitir la señal de muerte
	health = max_health
	global_position = start_position
	update_health_bar()

func update_health_bar() -> void:
	var bar = get_node("HealthBar")
	bar.max_value = max_health
	bar.value = health

	var fill_style = StyleBoxFlat.new()
	if health >= 80:
		fill_style.bg_color = Color(0.0, 1.0, 0.0)
	elif health >= 60:
		fill_style.bg_color = Color(1.0, 1.0, 0.0)
	elif health >= 30:
		fill_style.bg_color = Color(1.0, 0.5, 0.0)
	else:
		fill_style.bg_color = Color(1.0, 0.0, 0.0)

	fill_style.set_content_margin_all(2)
	bar.add_theme_stylebox_override("fill", fill_style)
	bar.custom_minimum_size = Vector2(0, 16)
