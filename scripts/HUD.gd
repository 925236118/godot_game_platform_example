extends CanvasLayer

## HUD - 平台跳跃游戏抬头显示（代码生成UI）

var health_label: Label
var coin_label: Label
var score_label: Label
var pause_overlay: ColorRect
var game_over_panel: Panel

func _ready() -> void:
	_build_ui()
	_connect_signals()

func _build_ui() -> void:
	# 左上角信息：血量、金币、分数
	var top_vbox := VBoxContainer.new()
	top_vbox.name = "TopInfo"
	top_vbox.position = Vector2(10, 10)
	add_child(top_vbox)

	health_label = Label.new()
	health_label.name = "HealthLabel"
	health_label.text = "❤️ 3/3"
	health_label.add_theme_color_override("font_color", Color.WHITE)
	top_vbox.add_child(health_label)

	coin_label = Label.new()
	coin_label.name = "CoinLabel"
	coin_label.text = "🪙 0"
	coin_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	top_vbox.add_child(coin_label)

	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "⭐ 0"
	score_label.add_theme_color_override("font_color", Color(1, 1, 0))
	top_vbox.add_child(score_label)

	# 暂停遮罩
	pause_overlay = ColorRect.new()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.color = Color(0, 0, 0, 0.7)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_overlay.hide()
	add_child(pause_overlay)

	var pause_label := Label.new()
	pause_label.name = "PauseLabel"
	pause_label.text = "⏸ 暂停"
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_overlay.add_child(pause_label)

	# 死亡面板
	game_over_panel = Panel.new()
	game_over_panel.name = "GameOverPanel"
	game_over_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	game_over_panel.size = Vector2(200, 100)
	game_over_panel.position = Vector2(-100, -50)
	game_over_panel.hide()
	add_child(game_over_panel)

	var panel_vbox := VBoxContainer.new()
	panel_vbox.name = "PanelVBox"
	panel_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_over_panel.add_child(panel_vbox)

	var title := Label.new()
	title.name = "Title"
	title.text = "💀 游戏结束"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel_vbox.add_child(title)

	var retry_btn := Button.new()
	retry_btn.name = "RetryBtn"
	retry_btn.text = "重新开始"
	retry_btn.pressed.connect(_on_retry_pressed)
	panel_vbox.add_child(retry_btn)

	var quit_btn := Button.new()
	quit_btn.name = "QuitBtn"
	quit_btn.text = "退出游戏"
	quit_btn.pressed.connect(_on_quit_pressed)
	panel_vbox.add_child(quit_btn)

func _connect_signals() -> void:
	if GameManager.has_signal("game_paused"):
		GameManager.game_paused.connect(func(): pause_overlay.show())
	if GameManager.has_signal("game_resumed"):
		GameManager.game_resumed.connect(func(): pause_overlay.hide())

	var player: PlatformerPlayer = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.coin_collected.connect(_on_coin_changed)
		player.score_changed.connect(_on_score_changed)
		player.player_died.connect(_on_player_died)
		_on_health_changed(player.current_health, player.max_health)
		_on_coin_changed(0)
		_on_score_changed(0)

func _on_health_changed(current: int, max_hp: int) -> void:
	health_label.text = "❤️ " + str(current) + "/" + str(max_hp)

func _on_coin_changed(total: int) -> void:
	coin_label.text = "🪙 " + str(total)

func _on_score_changed(points: int) -> void:
	score_label.text = "⭐ " + str(points)

func _on_player_died() -> void:
	game_over_panel.show()
	await get_tree().create_timer(3.0).timeout
	game_over_panel.hide()
	GameManager.restart_level()

func _on_retry_pressed() -> void:
	game_over_panel.hide()
	GameManager.restart_level()

func _on_quit_pressed() -> void:
	GameManager.quit_game()
