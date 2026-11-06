extends Node2D

var speed = 300
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200, 200)
var idler_timer = 0.0
var is_idling = false
@onready var animate_sprite = $AnimatedSprite2D
@onready var area =$AnimatedSprite2D/Area2D
@onready var dialog_label = $DialogueLabel
var is_dragging = false
var drag_offset = Vector2()
var click_start = Vector2()
var dialog : Tween

var frases: Array[String] = [
	"Tú puedes con todo hoy!",
	"A darle con ganas!",
	"Un pasito a la vez, crack.",
	"No te rindas ahora!",
	"Hoy toca romperla!",
	"Si la vida te da limones cogelos",
	"Si te caes, levantate.",
	"La vida es mejor cuando eres bueno",
	"La vida es bella, disfrutala",
	"Dame una banana, Si?"
]


func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	
	if is_idling:
		idler_timer -= delta
		if idler_timer <= 0:
			is_idling = false
			speed = 300
			animate_sprite.play("walk")
			var tween = create_tween()
			var base_scale = animate_sprite.scale
			
			tween.tween_property(animate_sprite, "scale", Vector2(base_scale.x * 1.2, base_scale.y * 0.8), 0.08)
			tween.tween_property(animate_sprite, "scale", base_scale, 0.12).set_trans(Tween.TRANS_BOUNCE)
		return 
	
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
	var r = randf()
	if r < 0.5:
		is_idling = true
		idler_timer = randf_range(2.0, 4.0)
		speed = 0
		animate_sprite.play("sleep")
		var tween = create_tween()
		var base_scale = animate_sprite.scale
			
		tween.tween_property(animate_sprite, "scale", Vector2(base_scale.x * 1.2, base_scale.y * 0.8), 0.08)
		tween.tween_property(animate_sprite, "scale", base_scale, 0.12).set_trans(Tween.TRANS_BOUNCE)
	elif r < 0.8:
		is_idling = true
		idler_timer = randf_range(1.5, 3.0)
		speed = 0
		animate_sprite.play("sit")
		look_at_mouse()

func _on_area_input (_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		
		if event.pressed:
			is_dragging =true
			click_start = mouse_pos
			animate_sprite.play("sit")
			
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false
			animate_sprite.play("walk")
			if click_start.distance_to(mouse_pos) < 5.0:
				animate_sprite.play("greeting")
				say_something()

var last_phrase: String = ""

func squash_and_stretch():
	var base_scale = animate_sprite.scale
	var tween = create_tween()
	tween.tween_property(animate_sprite, "scale", Vector2(base_scale.x * 1.2, base_scale.y * 0.8), 0.08)
	tween.tween_property(animate_sprite, "scale", base_scale, 0.12).set_trans(Tween.TRANS_BOUNCE)

func say_something():
	squash_and_stretch()
	if dialog and dialog.is_valid():
		dialog.kill()
	
	is_idling = true
	idler_timer =2.4
	speed =0
	
	dialog_label.text = frases.pick_random()
	dialog_label.modulate.a = 1.0
	dialog_label.visible = true
	
	dialog = create_tween()
	dialog.tween_interval(2.0)
	dialog.tween_property(dialog_label,"modulate:a",0.0,0.4)
	dialog.tween_callback(func(): dialog_label.visible =false)
	
func look_at_mouse():
	var mouse_pos = Vector2(DisplayServer.mouse_get_position())
	var win_pos = Vector2(DisplayServer.window_get_position())
	
	if mouse_pos.x < win_pos.x:
		direction.x = -1
		animate_sprite.flip_h = true
	else:
		direction.x = 1
		animate_sprite.flip_h = false

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animate_sprite.play("walk")
	area.input_event.connect(_on_area_input)
	dialog_label.visible = false
	
