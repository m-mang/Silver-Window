extends MarginContainer

@export var wipe_width = 3
@export var wipe_speed = 0.3
@export var wipe_color = Color("c8c8c8")

var wiping = false

@onready var DialogueContainer = $".."
@onready var Dialogue = $"../DialoguePadding/Dialogue"
@onready var TextCursor = $"../DialoguePadding/Dialogue/TextCursor"
@onready var Underline = $"../DialoguePadding/Dialogue/Underline"
@onready var stylebox = $"..".get_theme_stylebox("panel")
@onready var boxwipe_stylebox = $BoxWipe.get_theme_stylebox("panel")
@onready var border_left = $"..".get_theme_stylebox("panel").get_border_width(SIDE_LEFT)
@onready var border_right = $"..".get_theme_stylebox("panel").get_border_width(SIDE_RIGHT)
@onready var border_top = $"..".get_theme_stylebox("panel").get_border_width(SIDE_TOP)
@onready var border_bottom = $"..".get_theme_stylebox("panel").get_border_width(SIDE_BOTTOM)


func _ready():
	boxwipe_stylebox.bg_color = stylebox.bg_color
	boxwipe_stylebox.border_color = wipe_color


#func _input(event):
#	if event.is_action_pressed("wipe_box"):
#		box_wipe_vertical(Dialogue.text)


func box_wipe(new_text : String):
	wiping = true
	boxwipe_stylebox.border_width_top = 0
	boxwipe_stylebox.border_width_left = wipe_width
	add_theme_constant_override("margin_left", DialogueContainer.size.x - border_left - border_right - wipe_width)
	TextCursor.hide()
	Underline.hide()
	show()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "theme_override_constants/margin_left", 0, wipe_speed)
	await tween.finished
	boxwipe_stylebox.border_width_left = 0
	Dialogue.reset_text(new_text, 0)
	hide()
	wiping = false


func box_wipe_vertical(new_text : String):
	wiping = true
	boxwipe_stylebox.border_width_left = 0
	boxwipe_stylebox.border_width_top = wipe_width
	add_theme_constant_override("margin_top", DialogueContainer.size.y - border_top - border_bottom - wipe_width)
	TextCursor.hide()
	Underline.hide()
	show()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "theme_override_constants/margin_top", 0, wipe_speed)
	await tween.finished
	boxwipe_stylebox.border_width_top = 0
	Dialogue.reset_text(new_text, 0)
	hide()
	wiping = false
