#
# Finální skript pro Hráče
#
extends CharacterBody2D

signal objekt_sebran(typ_objektu)
signal hrac_zemrel

@export var rychlost = 300.0

# Odkazy na VŠECHNY potomky hráče
@onready var animace = $Animace
@onready var zvuk_mince = $ZvukMince
@onready var zvuk_drahokam = $ZvukDrahokam
@onready var zvuk_smrti = $ZvukSmrti


var je_mrtvy = false

func _physics_process(delta):
	if je_mrtvy:
		velocity.x = 0
		move_and_slide()
		return

	var smer = Input.get_axis("ui_left", "ui_right")
	velocity.x = smer * rychlost
	
	if smer > 0:
		animace.flip_h = false
	elif smer < 0:
		animace.flip_h = true

	aktualizuj_animaci()
	move_and_slide()

func aktualizuj_animaci():
	if animace.is_playing() and (animace.animation == "sebrani" or animace.animation == "smrt"):
		return

	if velocity.x == 0:
		animace.play("idle")
	else:
		animace.play("run")

func _on_detekcni_zona_body_entered(body):
	if je_mrtvy:
		return

	if body is RigidBody2D and "typ" in body:
		if body.typ == body.Typ.KAMEN:
			smrt()
		else:
			seber_objekt(body.typ)
		body.queue_free()

func seber_objekt(typ_objektu):
	print("HRÁČ DEBUG: Sbírám objekt. Chystám se vyslat signál.")
	animace.play("sebrani")
	emit_signal("objekt_sebran", typ_objektu)
	
	if typ_objektu == PadajiciObjekt.Typ.MINCE:
		zvuk_mince.play()
	elif typ_objektu == PadajiciObjekt.Typ.DRAHOKAM:
		zvuk_drahokam.play()

func smrt():
	je_mrtvy = true
	velocity.x = 0
	animace.play("smrt")
	zvuk_smrti.play() # Přehrání zvuku smrti
	emit_signal("hrac_zemrel")

func _on_animace_animation_finished():
	if animace.animation == "sebrani":
		aktualizuj_animaci()
