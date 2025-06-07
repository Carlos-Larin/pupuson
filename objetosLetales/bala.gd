extends Area2D

## Configuración de bala
@export var damage_on_hit := 25
@export var velocidad_bala: float = 300.0
@export var knockback_force: float = 150.0
@export var tiempo_vida: float = 5.0  # 5 segundos de vida total
@export var tiempo_destruccion_post_impacto: float = 0.1  # Tiempo tras impacto antes de desaparecer
@export var sonido_disparo: AudioStream = preload("res://objetosLetales/disparoSound.mp3")

# Nodos de la escena
@onready var audio_player: AudioStreamPlayer2D = $DisparoAudio
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direccion: Vector2 = Vector2.RIGHT
var hit_something: bool = false
var life_timer: Timer

func _ready() -> void:
	# Reproducir sonido de disparo
	audio_player.stream = sonido_disparo
	audio_player.play()
	
	# Configuración inicial
	rotation = direccion.angle()
	
	# Conexión de señales
	if body_entered.connect(_on_body_entered) != OK:
		push_error("Error conectando señal body_entered")
	
	# Animación
	if animated_sprite:
		animated_sprite.play("default")
	else:
		print("¡Advertencia! No se encontró AnimatedSprite2D en la bala")
	
	# Configurar timer de vida (5 segundos)
	life_timer = Timer.new()
	add_child(life_timer)
	life_timer.wait_time = tiempo_vida
	life_timer.one_shot = true
	life_timer.timeout.connect(_on_life_timer_timeout)
	life_timer.start()
	
	print("Bala creada. Tiempo de vida: ", tiempo_vida, "s")

func _physics_process(delta: float) -> void:
	if not hit_something:
		position += direccion * velocidad_bala * delta

func set_direccion(dir: Vector2) -> void:
	direccion = dir.normalized()
	rotation = direccion.angle()  # Actualizar rotación visual

func _on_body_entered(body: Node):
	if not is_instance_valid(body) or hit_something:
		return
	
	hit_something = true
	
	# Aplicar daño y knockback
	if body.has_method("take_damage"):
		body.take_damage(damage_on_hit)
		if body is CharacterBody2D:
			var kb_direction = (body.global_position - global_position).normalized()
			body.velocity = kb_direction * knockback_force
	
	# Efectos de impacto
	_play_impact_effects()
	
	# Destruir después de tiempo_destruccion_post_impacto
	await get_tree().create_timer(tiempo_destruccion_post_impacto).timeout
	queue_free()

func _play_impact_effects():
	if animated_sprite:
		animated_sprite.stop()
		animated_sprite.hide()
	print("Impacto detectado")

func _on_life_timer_timeout():
	if not hit_something:
		print("Bala autodestruida después de ", tiempo_vida, " segundos")
		queue_free()
