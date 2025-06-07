extends Area2D

var velocidad_bala = 20

func _ready() -> void:
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += velocidad_bala * delta
	$AnimatedSprite2D.play("default")
