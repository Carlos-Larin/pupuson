extends Area2D

@onready var texto_label = $"HablarOficial"  # Asegúrate de que esta ruta sea correcta
var jugador_dentro = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "player" or body.name == "player1":
		jugador_dentro = true

func _on_body_exited(body):
	if body.name == "player" or body.name == "player1":
		jugador_dentro = false
		texto_label.visible = false

func _process(_delta):
	if jugador_dentro and Input.is_action_just_pressed("interactuar"):
		texto_label.visible = true
