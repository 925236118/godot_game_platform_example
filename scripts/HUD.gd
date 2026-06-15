extends CanvasLayer

## HUD - ARPG抬头显示

var hp_label: Label
var mp_label: Label
var level_label: Label
var coin_label: Label
var xp_bar: ColorRect
var xp_bg: ColorRect
var pause_overlay: ColorRect
var death_panel: Panel
var coins: int = 0

func _ready() -> void:
	hp_label = $TopLeft/StatsRow/HP
	mp_label = $TopLeft/StatsRow/MP
	level_label = $TopLeft/Level
	coin_label = $TopLeft/Coins
	xp_bar = $Bottom/XP/Bar
	xp_bg = $Bottom/XP/BarBg
	pause_overlay = $PauseOverlay
	death_panel = $DeathPanel

	pause_overlay.hide()
	death_panel.hide()

	var player: ArpgPlayer = get_tree().get_first_node_in_group("player")
	if player:
		player.hp_changed.connect(_on_hp)
		player.mp_changed.connect(_on_mp)
		player.xp_changed.connect(_on_xp)
		player.level_up.connect(_on_level)
		player.player_died.connect(_on_death)
		player.dropped_coins.connect(_on_coins)
		_on_hp(player.hp, player.max_hp)
		_on_mp(player.mp, player.max_mp)
		_on_level(player.level)
		coin_label.text = "🪙 0"

func _process(delta: float) -> void:
	pause_overlay.visible = GameManager.is_paused

func _on_hp(current: float, max_hp: float) -> void:
	hp_label.text = "❤️ " + str(int(current)) + "/" + str(int(max_hp))

func _on_mp(current: float, max_hp: float) -> void:
	mp_label.text = "💧 " + str(int(current)) + "/" + str(int(max_hp))

func _on_xp(current: int, needed: int) -> void:
	var label: Label = $Bottom/XP/XPLabel
	if label:
		label.text = "⚡ " + str(current) + "/" + str(needed)
	var ratio: float = float(current) / float(needed) if needed > 0 else 0.0
	xp_bar.size.x = xp_bg.size.x * ratio

func _on_level(lvl: int) -> void:
	level_label.text = "Lv." + str(lvl)

func _on_coins(amount: int) -> void:
	coins += amount
	coin_label.text = "🪙 " + str(coins)

func _on_death() -> void:
	death_panel.show()
	await get_tree().create_timer(3.0).timeout
	death_panel.hide()
	get_tree().reload_current_scene()
