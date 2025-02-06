extends CharacterBody2D

@export var speed: float = 200  # Velocidad configurable desde el editor

func _ready():
	if $Animaciones:
		$Animaciones.play("caminar")

func _process(delta):
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * speed  # No multiplicar por delta aquí
	
	move_and_slide()
