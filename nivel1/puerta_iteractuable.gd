extends Area2D

@export var destino: String = "res://nivel1/NIVEL1CALABOZO/nivel_1calabozo.tscn"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "player" or body.name == "player1":
		get_tree().change_scene_to_file(destino)
