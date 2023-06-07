extends MarginContainer

signal picture_finished

@export var tween_frames : int = 13

var shrinking = false
var expanding = true

@onready var PictureContainer = $PictureContainer
@onready var PictureRect = $PictureContainer/Control/PictureRect
@onready var border_left = $PictureContainer.get_theme_stylebox("panel").border_width_left
@onready var border_top = $PictureContainer.get_theme_stylebox("panel").border_width_top
@onready var border_right = $PictureContainer.get_theme_stylebox("panel").border_width_right
@onready var border_bottom = $PictureContainer.get_theme_stylebox("panel").border_width_bottom


func _ready():
	custom_minimum_size.x = PictureRect.size.x + border_left + border_right
	custom_minimum_size.y = PictureRect.size.y + border_top + border_bottom
	reset_size()
	hide()
#	await get_tree().create_timer(1.0).timeout
	expand()


func _input(event):
	if event.is_action_pressed("advance_text") and !expanding and !shrinking:
		emit_signal("picture_finished")


func set_all_margins(left : int, top : int, right : int, bottom : int):
	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_right", right)
	add_theme_constant_override("margin_bottom", bottom)


func expand():
	expanding = true
	
	var full_size = size
	var left_marg = (full_size.x / 2) - border_left
	var right_marg = (full_size.x / 2) - border_right
	var top_marg = (full_size.y / 2) - border_top
	var bottom_marg = (full_size.y / 2) - border_bottom
	
#	PictureRect.hide()
	set_all_margins(left_marg, top_marg, right_marg, bottom_marg)
	show()
	
	var tween = get_tree().create_tween()
	var tween_time = tween_frames/60.0
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_left", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_top", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_right", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_bottom", 0, tween_time)

	await tween.finished
#	PictureRect.show()
	expanding = false


func shrink():
	shrinking = true
	
	var full_size = size
	var left_marg = (full_size.x / 2) - border_left
	var right_marg = (full_size.x / 2) - border_right
	var top_marg = (full_size.y / 2) - border_top
	var bottom_marg = (full_size.y / 2) - border_bottom
	
#	PictureRect.hide()
	set_all_margins(0, 0, 0, 0)
	
	var tween = get_tree().create_tween()
	var tween_time = tween_frames/60.0
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_left", left_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_top", top_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_right", right_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_bottom", bottom_marg, tween_time)
	
	await tween.finished
	hide()
	shrinking = false
	$"..".queue_free()
