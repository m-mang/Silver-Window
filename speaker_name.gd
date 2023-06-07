extends Label

@export var blink_in = true

var tween
var tween_time = 0.25
var opaque = Color("ffffff")
var transparent = Color("ffffff00")
var intro = false
var block_signal = false

func _ready():
	if blink_in:
		self_modulate = opaque
	else:
		self_modulate = transparent


func _process(_delta):
	if intro and blink_in:
		if is_visible_in_tree():
			hide()
		else:
			show()


func begin():
	block_signal = false
	if blink_in:
		show()
		intro = true
	else:
		show()
		phase_in()


func phase_in():
	self_modulate = transparent
	tween = get_tree().create_tween()
	
	tween.tween_property(self, "self_modulate", opaque, tween_time)
	
	await tween.finished
	$NameTimer.start()


func phase_out():
	tween = get_tree().create_tween()
	
	tween.tween_property(self, "self_modulate", transparent, tween_time )
	
	await tween.finished
	hide()
	
	if blink_in:
		self_modulate = opaque


func reset():
	$NameTimer.stop()
	if tween != null:
		tween.stop()
	intro = false
	hide()
	block_signal = true
	
	if !blink_in:
		self_modulate = transparent
	else:
		self_modulate = opaque


func _on_name_timer_timeout():
	phase_out()


func _on_frame_line_control_frame_lines_finished():
	if blink_in and !block_signal:
		intro = false
		show()
		$NameTimer.start()
