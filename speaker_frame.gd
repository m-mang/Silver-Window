extends PanelContainer

@export var tween_time = 0.45

var tween

func _ready():
	self_modulate = Color("ffffff00")


func pulse():
	tween = get_tree().create_tween()
	
	tween.set_loops()
	tween.tween_property(self, "self_modulate", Color("ffffffe6"), tween_time)
	tween.tween_property(self, "self_modulate", Color("ffffff00"), tween_time)


func reset():
	tween.stop()
	self_modulate = Color("ffffff00")
	hide()
