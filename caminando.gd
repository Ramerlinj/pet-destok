extends Node2D

var speed = 300
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200, 200)
var idler_timer = 0.0
var is_idling = false
@onready var animate_sprite = $AnimatedSprite2D
@onready var area =$AnimatedSprite2D/Area2D
var is_dragging = false
var drag_offset = Vector2()

func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	
	# Gestionar el estado de descanso/dormir
	if is_idling:
		idler_timer -= delta
		if idler_timer <= 0:
			is_idling = false
			speed = 300
			animate_sprite.play("walk")
		return # Detiene el movimiento mientras duerme/espera
	
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))

	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animate_sprite.flip_h = !animate_sprite.flip_h
		maybe_idle()
		
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()

func maybe_idle():
	# 30% de probabilidad al chocar con un borde
	if randf() < 0.8:
		is_idling = true
		idler_timer = randf_range(2.0, 4.0)
		speed = 0
		animate_sprite.play("sleep")

func _on_area_input (_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging =true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animate_sprite.play("walk")
	area.input_event.connect(_on_area_input)
