extends "res://scripts/MCNPMesh.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize("res://tank10.csv", true, 1.0/100)
