extends Area2D

## Configuración de bala
@export var damage_on_hit := 10
@export var velocidad_bala: float = 300.0
@export var knockback_force: float = 150.0
@export var tiempo_vida: float = 5.0  # Tiempo antes de autodestruirse (ajustable en editor)
@export var tiempo_destruccion: float = 0.1  # Tiempo antes de desaparecer tras impacto

var direccion: Vector2 = Vector2.RIGHT
var hit_something: bool = false

func _ready() -> void:
	rotation = direccion.angle()
	
	if body_entered.connect(_on_body_entered) != OK:
		push_error("Error conectando señal body_entered")
	
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("default")
	else:
		print("¡Advertencia! No se encontró AnimatedSprite2D en la bala")
	
	$LifeTimer.wait_time = tiempo_vida
	$LifeTimer.start()
	
	print("Bala creada en posición: ", global_position)

func _physics_process(delta: float) -> void:
	if not hit_something:
		position += direccion * velocidad_bala * delta

func set_direccion(dir: Vector2) -> void:
	direccion = dir.normalized()
	rotation = direccion.angle()

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
	
	# Programar destrucción después de tiempo_destruccion
	$DestructionTimer.wait_time = tiempo_destruccion
	$DestructionTimer.start()

func _play_impact_effects():
	# Detener movimiento y ocultar bala
	if $AnimatedSprite2D:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.hide()
	
	# Aquí puedes añadir efectos de impacto (partículas, sonido, etc.)
	print("Impacto detectado, destruyendo bala en ", tiempo_destruccion, " segundos")

func _on_life_timer_timeout():
	if not hit_something:
		print("Bala autodestruida por tiempo de vida")
		queue_free()

func _on_destruction_timer_timeout():
	print("Destruyendo bala tras impacto")
	queue_free()
