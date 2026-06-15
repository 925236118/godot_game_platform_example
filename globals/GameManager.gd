extends Node

## GameManager - ARPG全局状态管理器（Autoload）

var player_ref: Node2D = null
var current_level: String = "res://scenes/World.tscn"
var is_paused: bool = false

signal game_paused()
signal game_resumed()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	if is_paused:
		game_paused.emit()
	else:
		game_resumed.emit()
