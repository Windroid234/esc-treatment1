class_name GGameGlobals extends Node

static var instance: GGameGlobals = null


func _ready() -> void:
	self.name = "GGameGlobals"
	instance = self
