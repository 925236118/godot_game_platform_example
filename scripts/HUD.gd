extends CanvasLayer

## HUD - ARPG游戏抬头显示（代码生成UI）

var hp_label: Label
var mp_label: Label
var xp_bar: ColorRect
var xp_bg: ColorRect
var level_label: Label
var coin_label: Label
var pause_overlay: ColorRect
var death_panel: Panel
var coins: int = 0

func _ready() -> void:
	_build_ui()
	_connect_signals()

func _build_ui() -> void:
	# 左上角
	var top_left := VBoxContainer.new()
	top_left.name = "TopLeft"
	top_left.position = Vector2(10, 10)
	add_child(top_left)

	var stats_row := HBoxContainer.new()
	stats_row.name = "StatsRow"
	top_left.add_child(stats_row)

	hp_label = Label.new()
	hp_label.name = "HP"
	hp_label.text = "❤️ 100/100"
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_font_size_override("font_size", 18)
	stats_row.add_child(hp_label)

	mp_label = Label.new()
	mp_label.name = "MP"
	mp_label.text = "💧 50/50"
	mp_label.add_theme_color_override("font_color", Color(0.3, 0.6, 1))
	mp_label.add_theme_font_size_override("font_size", 18)
	stats_row.add_child(mp_label)

	level_label = Label.new()
	level_label.name = "Level"
	level_label.text = "Lv.1"
	level_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	level_label.add_theme_font_size_override("font_size", 16)
	top_left.add_child(level_label)

	coin_label = Label.new()
	coin_label.name = "Coins"
	coin_label.text = "🪙 0"
	coin_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	coin_label.add_theme_font_size_override("font_size", 16)
	top_left.add_child(coin_label)

	# 底部经验条
	var bottom := Control.new()
	bottom.name = "Bottom"
	bottom.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	bottom.size = Vector2(220, 20)
	add_child(bottom)

	var xp_container := Control.new()
	xp_container.name = "XP"
	xp_container.position = Vector2(-110, 0)
	xp_container.size = Vector2(220, 14)
	bottom.add_child(xp_container)

	xp_bg = ColorRect.new()
	xp_bg.name = "BarBg"
	xp_bg.size = Vector2(220, 12)
	xp_bg.color = Color(0.2, 0.2, 0.3)
	xp_container.add_child(xp_bg)

	xp_bar = ColorRect.new()
	xp_bar.name = "Bar"
	xp_bar.size = Vector2(0, 12)
	xp_bar.color = Color(0.2, 1.0, 0.2)
	xp_container.add_child(xp_bar)

	var xp_label := Label.new()
	xp_label.name = "Label"
	xp_label.position = Vector2(0, -2)
	xp_label.size = Vector2(220, 16)
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	xp_label.text = "⚡ 0/50"
	xp_label.add_theme_color_override("font_color", Color.WHITE)
	xp_label.add_theme_font_size_override("font_size", 14)
	xp_container.add_child(xp_label)

	# 暂停遮罩
	pause_overlay = ColorRect.new()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.color = Color(0, 0, 0, 0.7)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_overlay.hide()
	add_child(pause_overlay)

	var pause_label := Label.new()
	pause_label.name = "Label"
	pause_label.text = "⏸ 暂停"
	pause_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_overlay.add_child(pause_label)

	# 死亡面板
	death_panel = Panel.new()
	death_panel.name = "DeathPanel"
	death_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	death_panel.size = Vector2(200, 80)
	death_panel.hide()
	add_child(death_panel)

	var death_label := Label.new()
	death_label.name = "Label"
	death_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_label.text = "💀 你死了\n3秒后重新开始"
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_panel.add_child(death_label)

func _connect_signals() -> void:
	var player: ArpgPlayer = get_tree().get_first_node_in_group("player")
	if player:
		player.hp_changed.connect(_on_hp_changed)
		player.mp_changed.connect(_on_mp_changed)
		player.xp_changed.connect(_on_xp_changed)
		player.level_up.connect(_on_level_up)
		player.player_died.connect(_on_player_died)
		player.dropped_coins.connect(_on_coins_changed)
		_on_hp_changed(player.hp, player.max_hp)
		_on_mp_changed(player.mp, player.max_mp)
		_on_xp_changed(0, player.xp_to_next)
		level_label.text = "Lv." + str(player.level)
		coin_label.text = "🪙 0"

func _process(delta: float) -> void:
	pause_overlay.visible = GameManager.is_paused

func _on_hp_changed(current: float, max_value: float) -> void:
	hp_label.text = "❤️ " + str(int(current)) + "/" + str(int(max_value))

func _on_mp_changed(current: float, max_value: float) -> void:
	mp_label.text = "💧 " + str(int(current)) + "/" + str(int(max_value))

func _on_xp_changed(current: int, needed: int) -> void:
	var label: Label = xp_bar.get_parent().get_node("Label")
	label.text = "⚡ " + str(current) + "/" + str(needed)
	var ratio: float = float(current) / float(needed) if needed > 0 else 0.0
	xp_bar.size.x = xp_bg.size.x * ratio

func _on_level_up(lvl: int) -> void:
	level_label.text = "Lv." + str(lvl)

func _on_coins_changed(amount: int) -> void:
	coins += amount
	coin_label.text = "🪙 " + str(coins)

func _on_player_died() -> void:
	death_panel.show()
	await get_tree().create_timer(3.0).timeout
	death_panel.hide()
	get_tree().reload_current_scene()
