#
# Finální skript pro Hlavní scénu
#
extends Node2D

@export var scena_objektu: PackedScene
@export var spawn_x_min = 50
@export var spawn_x_max = 1100
@export var spawn_y = -50

var skore = 0
var high_score = 0

const SAVE_PATH = "user://savegame.save"

# Odkazy na VŠECHNY potomky hlavní scény (UI, zvuky atd.)
@onready var skore_label = $UI/SkoreLabel
@onready var game_over_menu = $UI/GameOverMenu
@onready var skore_konec_label = $UI/GameOverMenu/MenuKontejner/SkoreKonecLabel
@onready var highscore_label = $UI/GameOverMenu/MenuKontejner/HighscoreLabel
@onready var zvuk_klik = $ZvukKlik
@onready var spawn_timer = $SpawnTimer

func _ready():
	load_high_score()
	aktualizuj_skore_ui()

func aktualizuj_skore_ui():
	skore_label.text = "Skóre: %s" % skore

func _on_spawn_timer_timeout():
	var novy_objekt = scena_objektu.instantiate()
	var typy = [
		novy_objekt.Typ.MINCE, novy_objekt.Typ.MINCE, novy_objekt.Typ.MINCE,
		novy_objekt.Typ.DRAHOKAM, novy_objekt.Typ.KAMEN
	]
	novy_objekt.typ = typy.pick_random()
	novy_objekt.position = Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)
	add_child(novy_objekt)

func _on_hrac_objekt_sebran(typ_objektu):
	print("MAIN DEBUG: Signál přijat! Zpracovávám skóre.")
	match typ_objektu:
		PadajiciObjekt.Typ.MINCE:
			skore += 1
		PadajiciObjekt.Typ.DRAHOKAM:
			skore += 5
	
	aktualizuj_skore_ui()

	if skore > 0 and skore % 5 == 0:
		spawn_timer.wait_time = max(spawn_timer.wait_time * 0.9, 0.2)

func game_over():
	spawn_timer.stop()
	
	if skore > high_score:
		high_score = skore
		save_high_score()
		
	skore_konec_label.text = "Skóre: %s" % skore
	highscore_label.text = "Nejvyšší skóre: %s" % high_score
	game_over_menu.show()

func _on_hrac_hrac_zemrel():
	game_over()

func _on_restart_button_pressed():
	zvuk_klik.play()
	get_tree().reload_current_scene()

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(high_score)
	file.close()

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = file.get_var()
		file.close()
