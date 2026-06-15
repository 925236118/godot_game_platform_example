extends Node

## GameManager - 全局游戏状态管理器（Autoload）

var current_level: String = ""
var total_coins: int = 0
var total_score: int = 0
var player_ref: PlatformerPlayer = null
var hud_ref: Control = null
var is_paused: bool = false

signal game_paused()
signal game_resumed()
signal level_changed(level_name: String)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

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

func restart_level() -> void:
	if player_ref:
		player_ref.respawn()
	get_tree().paused = false
	is_paused = false

func change_scene(scene_path: String) -> void:
	current_level = scene_path
	get_tree().change_scene_to_file(scene_path)
	level_changed.emit(scene_path)

func quit_game() -> void:
	get_tree().quit()
