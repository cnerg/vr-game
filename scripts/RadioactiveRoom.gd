extends "res://scripts/MCNPMesh.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize("res://tworoom10msht.csv", false, 1.0/100)
