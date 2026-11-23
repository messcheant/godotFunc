@tool
extends Area2D

@onready var button: Sprite2D = $Sprite2D

@export var event: String = ""

@export var aturArah: Vector2 = Vector2(-1.0, -167.0):
	set(value):
		aturArah = value
		_update_button_position()

signal playEvent(event_name: String)

func _ready() -> void:
	_update_button_position()
	if not Engine.is_editor_hint():
		button.visible = false


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		buttonPress()


func _update_button_position() -> void:
	if button:
		button.position = aturArah


func buttonPress():
	if button.visible and Input.is_action_just_pressed("interact"):
		playEvent.emit(event)
		button.modulate.a = 0.0
		print(event)


func _on_body_entered(_body: Node2D) -> void:
	button.visible = true
	button.modulate.a = 0.0
	create_tween().tween_property(button, "modulate:a", 1.0, 0.25)


func _on_body_exited(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(button, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func(): button.visible = false)
