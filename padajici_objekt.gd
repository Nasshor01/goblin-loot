#
# Finální skript pro Padající Objekt
#
class_name PadajiciObjekt
extends RigidBody2D

enum Typ { MINCE, DRAHOKAM, KAMEN }

@export var typ: Typ = Typ.MINCE

func _ready():
	var sprite = $Grafika
	match typ:
		Typ.MINCE:
			sprite.texture = load("res://assets/mince.png")
		Typ.DRAHOKAM:
			sprite.texture = load("res://assets/drahokam.png")
		Typ.KAMEN:
			sprite.texture = load("res://assets/kamen.png")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
