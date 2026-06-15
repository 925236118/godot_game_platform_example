extends CanvasLayer

## HUD - 抬头显示（配合 tscn 场景）

var hp_label: Label
var level_label: Label
var timer_label: Label
var xp_bar: ColorRect
var xp_bg: ColorRect
var pause_overlay: ColorRect
var death_panel: Panel

func _ready() -> void:
	hp_label = $TopLeft/HP
	level_label = $TopLeft/Level
	timer_label = $TopRight/Timer
	xp_bar = $Bottom/XP/Bar
	xp_bg = $Bottom/XP/BarBg
	pause_overlay = $PauseOverlay
	death_panel = $DeathPanel

	pause_overlay.hide()
	death_panel.hide()

	var player: SurvivorPlayer = get_tree().get_first_node_in_group("player")
	if player:
		player.hp_changed.connect(_on_hp)
		player.xp_changed.connect(_on_xp)
		player.level_up.connect(_on_level)
		player.player_died.connect(_on_death)
		_on_hp(player.hp, player.max_hp)

func _process(delta: float) -> void:
	var player: SurvivorPlayer = get_tree().get_first_node_in_group("player") as SurvivorPlayer
	if player:
		var t: int = int(player.game_time)
		timer_label.text = "%02d:%02d" % [t / 60, t % 60]

	pause_overlay.visible = GameManager.is_paused

func _on_hp(current: float, max_hp: float) -> void:
	hp_label.text = "❤️ " + str(int(current)) + "/" + str(int(max_hp))

func _on_xp(current: int, needed: int) -> void:
	var ratio: float = float(current) / float(needed) if needed > 0 else 0.0
	xp_bar.size.x = xp_bg.size.x * ratio

func _on_level(lvl: int) -> void:
	level_label.text = "Lv." + str(lvl)

func _on_death() -> void:
	death_panel.show()
	await get_tree().create_timer(3.0).timeout
	death_panel.hide()
	get_tree().reload_current_scene()
