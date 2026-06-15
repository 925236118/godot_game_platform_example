extends CanvasLayer

## HUD - ARPG游戏抬头显示

var hp_label: Label
var mp_label: Label
var xp_bar: ColorRect
var xp_bg: ColorRect
var xp_label: Label
var level_label: Label
var coin_label: Label
var pause_overlay: ColorRect
var death_panel: Panel
var death_label: Label

func _ready() -> void:
	# 获取节点引用
	hp_label = $TopLeft/HBoxContainer/HP
	mp_label = $TopLeft/HBoxContainer/MP
	xp_bar = $Bottom/XP/Bar
	xp_bg = $Bottom/XP/BarBg
	xp_label = $Bottom/XP/Label
	level_label = $TopLeft/Level
	coin_label = $TopLeft/Coins
	pause_overlay = $PauseOverlay
	death_panel = $DeathPanel

	# 连接玩家信号
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

	# 连接GameManager
	if GameManager.has_signal("game_paused"):
		GameManager.game_paused.connect(_on_game_paused)
	if GameManager.has_signal("game_resumed"):
		GameManager.game_resumed.connect(_on_game_resumed)

	pause_overlay.hide()
	death_panel.hide()

func _on_hp_changed(current: float, max_value: float) -> void:
	hp_label.text = "❤️ " + str(int(current)) + "/" + str(int(max_value))

func _on_mp_changed(current: float, max_value: float) -> void:
	mp_label.text = "💧 " + str(int(current)) + "/" + str(int(max_value))

func _on_xp_changed(current: int, needed: int) -> void:
	xp_label.text = "⚡ " + str(current) + "/" + str(needed)
	var ratio: float = float(current) / float(needed) if needed > 0 else 0.0
	xp_bar.size.x = xp_bg.size.x * ratio

func _on_level_up(lvl: int) -> void:
	level_label.text = "Lv." + str(lvl)

var coins: int = 0
func _on_coins_changed(amount: int) -> void:
	coins += amount
	coin_label.text = "🪙 " + str(coins)

func _on_game_paused() -> void:
	pause_overlay.show()

func _on_game_resumed() -> void:
	pause_overlay.hide()

func _on_player_died() -> void:
	death_panel.show()
	await get_tree().create_timer(3.0).timeout
	death_panel.hide()
	GameManager.restart_level()
