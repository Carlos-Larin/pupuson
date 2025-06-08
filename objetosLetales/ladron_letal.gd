extends CharacterBody2D

@export var velocidad_disparo: float = 150.0
@export var rango_vision: float = 300.0
@export var distancia_muzzle: float = 20.0
@export var respawn_delay: float = 0.0  # Tiempo para reaparecer después de que el jugador respawnea

const Bala = preload("res://objetosLetales/bala.tscn")

var player
var health := 100
var esta_muerto := false
var debug_mode := true
var original_position: Vector2
var original_rotation: float

func _ready():
	# Guardar estado inicial para el respawn
	original_position = global_position
	original_rotation = rotation
	
	# Conectar al jugador
	connect_to_player()
	
	# Configurar animación y timer de disparo
	$AnimatedSprite2D.frame = 0
	$ShootTimer.wait_time = 3.0
	$ShootTimer.start()

	if not $ShootTimer.is_connected("timeout", Callable(self, "_on_ShootTimer_timeout")):
		$ShootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout"))
	
	if debug_mode:
		print("DEBUG: NPC inicializado. Posición: ", global_position)

func connect_to_player():
	player = get_tree().get_root().find_child("player1", true, false)
	if player:
		if player.has_signal("died"):
			if not player.died.is_connected(_on_player_died):
				player.died.connect(_on_player_died)
		if debug_mode:
			print("DEBUG: Conectado al jugador y sus señales")
	else:
		if debug_mode:
			print("DEBUG: Jugador no encontrado al iniciar")

func _process(delta):
	if not player or health <= 0 or esta_muerto:
		return
	
	var distancia = global_position.distance_to(player.global_position)
	
	if distancia <= rango_vision:
		mirar_jugador()
		$AnimatedSprite2D.frame = 1  # Frame de alerta
	else:
		$AnimatedSprite2D.frame = 0  # Frame normal

func mirar_jugador():
	if not player:
		return
		
	var flip = player.global_position.x < global_position.x
	$AnimatedSprite2D.flip_h = flip
	
	var offset_extra := 30.0
	$Muzzle.position.x = -(distancia_muzzle + offset_extra) if flip else (distancia_muzzle + offset_extra)

func _on_ShootTimer_timeout():
	if not player or health <= 0 or esta_muerto:
		if debug_mode:
			print("DEBUG: No se dispara - jugador muerto o NPC muerto")
		return
	
	var distancia = global_position.distance_to(player.global_position)
	if distancia > rango_vision:
		if debug_mode:
			print("DEBUG: Jugador fuera de rango")
		return
	
	disparar()

func disparar():
	if esta_muerto:
		return
		
	var bala_instancia = Bala.instantiate()
	if not bala_instancia:
		print("ERROR: No se pudo instanciar la bala!")
		return
	
	get_tree().current_scene.add_child(bala_instancia)
	bala_instancia.global_position = $Muzzle.global_position
	var direccion = Vector2.RIGHT if not $AnimatedSprite2D.flip_h else Vector2.LEFT
	bala_instancia.set_direccion(direccion)
	
	if debug_mode:
		print("DEBUG: Disparando en dirección: ", direccion)

func take_damage(amount: int):
	if esta_muerto:
		return
	
	health -= amount
	if debug_mode:
		print("DEBUG: NPC recibe daño: ", amount, " - Salud restante: ", health)
	
	if health <= 0:
		die()

func die():
	esta_muerto = true
	health = 0
	$ShootTimer.stop()
	$AnimatedSprite2D.frame = 2  # Frame de muerto
	$CollisionShape2D.set_deferred("disabled", true)
	
	if debug_mode:
		print("DEBUG: NPC ha muerto")

func _on_player_died():
	if debug_mode:
		print("DEBUG: Señal recibida - Jugador murió. Preparando respawn...")
	
	# Programar el respawn después de un delay
	get_tree().create_timer(respawn_delay).timeout.connect(_respawn)

func _respawn():
	if not esta_muerto:
		return
		
	health = 100
	esta_muerto = false
	global_position = original_position
	rotation = original_rotation
	$AnimatedSprite2D.frame = 0
	$CollisionShape2D.set_deferred("disabled", false)
	$ShootTimer.start()
	
	# Reconectar al jugador por si es una nueva instancia
	connect_to_player()
	
	if debug_mode:
		print("DEBUG: NPC respawneado en posición original")
