extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))  # Importante para que funcione bien

func _on_body_entered(body):
	if "escalera" in body:
		body.escalera = true

func _on_body_exited(body):
	if "escalera" in body:
		body.escalera = false
		body.Gravity = 10  # Reactiva la gravedad
