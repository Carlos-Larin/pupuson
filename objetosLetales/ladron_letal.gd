extends CharacterBody2D

@export var velocidad_disparo: float = 150.0
@export var rango_vision: float = 300.0
@export var distancia_muzzle: float = 20.0

const Bala = preload("res://objetosLetales/bala.tscn")

var player
var health := 100
var debug_mode := true

func _ready():
	player = get_tree().get_root().find_child("player1", true, false)
	
	if debug_mode:
		if not player:
			print("DEBUG: Jugador no encontrado")
		else:
			print("DEBUG: Jugador encontrado en posición: ", player.global_position)
	
	$AnimatedSprite2D.frame = 0
	
	# CORRECCIÓN: Asegurar que el nombre del Timer es consistente
	$ShootTimer.wait_time = 3.0
	$ShootTimer.start()
	
	# CONEXIÓN DE SEÑAL EN CÓDIGO (por si no está conectada en el editor)
	if not $ShootTimer.is_connected("timeout", Callable(self, "_on_ShootTimer_timeout")):
		$ShootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout"))
	
	if debug_mode:
		print("DEBUG: NPC inicializado. Posición: ", global_position)
		print("DEBUG: Timer de disparo configurado a ", $ShootTimer.wait_time, " segundos")
		print("DEBUG: Timer conectado: ", $ShootTimer.is_connected("timeout", Callable(self, "_on_ShootTimer_timeout")))

func _process(delta):
	if not player or health <= 0:
		return
	
	var distancia = global_position.distance_to(player.global_position)
	
	if debug_mode:
		print("DEBUG: Distancia al jugador: ", distancia)
	
	if distancia <= rango_vision:
		if debug_mode:
			print("DEBUG: Jugador en rango de visión")
		mirar_jugador()
		$AnimatedSprite2D.frame = 1
	else:
		$AnimatedSprite2D.frame = 0

func mirar_jugador():
	var flip = player.global_position.x < global_position.x
	$AnimatedSprite2D.flip_h = flip
	if debug_mode:
		print("DEBUG: Mirando hacia ", "izquierda" if flip else "derecha")

func _on_ShootTimer_timeout():
	if not player or health <= 0:
		if debug_mode:
			print("DEBUG: No se dispara - Jugador no existe o salud <= 0")
		return
	
	var distancia = global_position.distance_to(player.global_position)
	if distancia > rango_vision:
		if debug_mode:
			print("DEBUG: No se dispara - Jugador fuera de rango")
		return
	
	if debug_mode:
		print("DEBUG: Disparando...")
	disparar()

func disparar():
	if debug_mode:
		print("DEBUG: Iniciando función disparar()")
	
	# Verificar si la escena de la bala existe
	if not Bala:
		print("ERROR: No se pudo cargar la escena de la bala!")
		return
	
	if debug_mode:
		print("DEBUG: Escena de bala cargada correctamente")
	
	# Instanciar la bala
	var bala_instancia = Bala.instantiate()
	
	if not bala_instancia:
		print("ERROR: No se pudo instanciar la bala!")
		return
	
	if debug_mode:
		print("DEBUG: Bala instanciada correctamente")
	
	# Añadir al escenario
	var escena_actual = get_tree().current_scene
	if not escena_actual:
		print("ERROR: No se pudo obtener la escena actual!")
		return
	
	escena_actual.add_child(bala_instancia)
	
	if debug_mode:
		print("DEBUG: Bala añadida al árbol de escena")
	
	# Configurar posición
	var muzzle = $Muzzle
	if not muzzle:
		print("ERROR: No se encontró el nodo Muzzle!")
		return
	
	bala_instancia.global_position = muzzle.global_position
	
	if debug_mode:
		print("DEBUG: Bala posicionada en: ", muzzle.global_position)
		print("DEBUG: Posición del NPC: ", global_position)
		print("DEBUG: Posición del jugador: ", player.global_position)
	
	# Configurar dirección
	var direccion = Vector2.RIGHT if not $AnimatedSprite2D.flip_h else Vector2.LEFT
	bala_instancia.set_direccion(direccion)
	
	if debug_mode:
		print("DEBUG: Dirección de disparo: ", direccion)
		print("DEBUG: Disparo completado con éxito")
