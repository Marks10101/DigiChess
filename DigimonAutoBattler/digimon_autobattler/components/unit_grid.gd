class_name UnitGrid
extends Node

signal unit_grid_change

@export var size: Vector2i
var units: Dictionary

func _ready() -> void:
	for i in size.x:
		for j in size.y:
			units [Vector2i(i, j)] = null
			
func add_unit(tile: Vector2i, unit: Node) -> void:
	units[tile] = unit
	unit_grid_changed.emit()
