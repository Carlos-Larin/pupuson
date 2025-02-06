extends Area2D

var jugador_cerca = false

func _on_body_entered(body):
	if body.is_in_group("player"):  # Verifica si el jugador entró en el área
		jugador_cerca = true
		print("Presiona 'E' para entrar a la casa")

func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_cerca = false

func _process(delta):
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		get_tree().change_scene_to_file("res://escenas/nueva_habitacion.tscn")  # Cambia de mapa
