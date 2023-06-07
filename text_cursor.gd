extends PanelContainer

const START_POS_X = 0
const START_POS_Y = 0
const BORDER_WIDTH = 2

@export_enum("Box", "Outline", "Underline", "Line") var cursor_type: String = "Outline"
@export var show_cursor = true


var char_size
var flash_tween
var flashing = false

@onready var Dialogue = $".."
@onready var Underline = $"../Underline"
@onready var font = $"..".get_theme_font("normal_font")
@onready var font_size = $"..".get_theme_font_size("normal_font_size")
@onready var stylebox = get_theme_stylebox("panel")
@onready var stylebox2 = $TextCursor2.get_theme_stylebox("panel")


func _ready():
	if !show_cursor:
		hide()
	
	char_size = font.get_char_size("A".to_utf8_buffer()[0], font_size)
	stylebox.bg_color = Color(get_theme_color("default_color", "RichTextLabel").to_html(false))
	stylebox.border_color = stylebox.bg_color
	stylebox2.bg_color = stylebox.bg_color
	stylebox.set_border_width_all(BORDER_WIDTH)
	stylebox2.set_border_width_all(BORDER_WIDTH)
	stylebox2.set_expand_margin_all(BORDER_WIDTH)
	position = Vector2(START_POS_X, START_POS_Y)
	
	if cursor_type == "Box":
		stylebox.draw_center = true
		size = Vector2(char_size.x + 5, char_size.y - START_POS_Y)
	
	elif cursor_type == "Outline":
		stylebox.draw_center = false
		size = Vector2(char_size.x + 9, char_size.y + 5)
		
	elif cursor_type == "Underline":
		stylebox.draw_center = false
		stylebox.border_width_left = 0
		stylebox.border_width_right = 0
		stylebox.border_width_bottom = 0
		stylebox.border_width_top = 2
		size = Vector2(char_size.x, 2)
		position.y = char_size.y - size.y
	
	elif cursor_type == "Line":
		stylebox.draw_center = false
		stylebox.border_width_left = 2
		stylebox.border_width_right = 0
		stylebox.border_width_bottom = 0
		stylebox.border_width_top = 0
		size = Vector2(2, char_size.y - START_POS_Y)
	
	$TextCursor2.size = size


func get_cursor_positions(string : String):
	var lines = []
	var pos_x = START_POS_X
	var pos_y
	
	if cursor_type == "Box" or cursor_type == "Outline" or cursor_type == "Line":
		pos_y = START_POS_Y
	
	elif cursor_type == "Underline":
		pos_y = char_size.y - size.y
	
	var cursor_positions = [Vector2(pos_x, pos_y)]
	
	if string.contains("\n"):
		var from = 0
		
		for i in string.count("\n"):
			var new_line = string.find("\n", from)
			lines.append(string.left(new_line))
			string = string.right(-(new_line))
			from = 1
	
	lines.append(string)
	
	for s in lines:
		
		for i in s.length():
			pos_x = font.get_string_size(s.left(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			cursor_positions.append(Vector2(pos_x, pos_y))
		
		pos_y += font.get_height(font_size) + Dialogue.get_theme_constant("line_separation")
	
	return cursor_positions


func flash_cursor():
	flash_tween = create_tween()
	var tween_time = 0.625
	
	if cursor_type == "Outline":
		$TextCursor2.show()
		$TextCursor2.self_modulate = Color("ffffff00")
	
	flash_tween.set_loops()
	flash_tween.tween_property(self, "self_modulate", Color("ffffff00"), tween_time)
	flash_tween.parallel().tween_property($TextCursor2, "self_modulate", Color("ffffff"), tween_time)
	flash_tween.tween_property(self, "self_modulate", Color("ffffff"), tween_time)
	flash_tween.parallel().tween_property($TextCursor2, "self_modulate", Color("ffffff00"), tween_time)
	
	flashing = true
