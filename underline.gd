extends ColorRect

const THICKNESS = 2

@export var show_underline = true

@onready var Dialogue = $".."
@onready var TextCursor = $"../TextCursor"
@onready var font = $"..".get_theme_font("normal_font")
@onready var font_size = $"..".get_theme_font_size("normal_font_size")

func _ready():
	if !show_underline:
		hide()
	
	color = Color(get_theme_color("default_color", "RichTextLabel"))
	size = Vector2(0, THICKNESS)
