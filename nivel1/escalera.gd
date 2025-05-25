extends Area2D

func _on_ESCALERA_body_entered(body):
	if body.name == "player1":
		# Cambia estas coordenadas por la posición superior deseada
		var posicion_superior = Vector2(1280, 500)
		body.global_position = posicion_superi or
