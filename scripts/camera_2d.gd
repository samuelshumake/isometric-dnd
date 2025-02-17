extends Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_pressed("SCROLL_IN")):
		zoom += Vector2(0.1, 0.1)
	elif (Input.is_action_pressed("SCROLL_OUT")):
		zoom -= Vector2(0.1, 0.1)
