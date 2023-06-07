extends Control

@export var show_boxes = true

var char_size
var modulate_step
var modulate_color

@onready var Dialogue = $".."
@onready var font = $"..".get_theme_font("normal_font")
@onready var font_size = $"..".get_theme_font_size("normal_font_size")
@onready var stylebox = $HollowBox.get_theme_stylebox("panel")


func _ready():
	if !show_boxes:
		hide()
	
	char_size = font.get_char_size("A".to_utf8_buffer()[0], font_size)
	modulate_step = 1.0 / get_child_count()
	modulate_color = 1.0
	
	for child in get_children():
		child.custom_minimum_size = Vector2(char_size.x - 4, char_size.y)
		child.reset_size()
		child.self_modulate.a = modulate_color
		modulate_color -= modulate_step
	
	stylebox.border_color = Color(get_theme_color("default_color", "RichTextLabel"))


func get_char_size_array(string : String):
	var char_size_array = []
	
	for c in string:
		char_size_array.append(font.get_char_size(c.to_utf8_buffer()[0], font_size))
	
	return char_size_array
