extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Animaciones.play("caminar")
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direccion = Input.get_vector("ui_left","ui_rigth","ui_up","ui_down")
	
	velocity = direccion * 200 * delta
	move_and_slide()
