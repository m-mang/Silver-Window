extends RichTextLabel

signal dialogue_finished

const UNDERLINE_OFFSET = 7

# How many frames to wait before showing next character.
@export var typewrite_frames = 2
@export var dialogue_width = 500
@export var lines = 1

var all_chars_displayed = false
var window_expanded = false
var frame_count = 1
var cursor_positions
var margin_left
var no_tags_text
var start = 0
var blank = false
var allow_input = true

@onready var ExpandShrinkContainer = $"../../.."
@onready var DialogueContainer = $"../.."
@onready var DialoguePadding = $".."
@onready var BoxWipeContainer = $"../../BoxWipeContainer"
@onready var stylebox = $"../..".get_theme_stylebox("panel")
@onready var font = get_theme_font("normal_font")
@onready var font_size = get_theme_font_size("normal_font_size")
@onready var HollowBox = $HollowBoxControl/HollowBox
@onready var HollowBox2 = $HollowBoxControl/HollowBox2


func _ready():
	custom_minimum_size.x = dialogue_width
	custom_minimum_size.y = lines * (font.get_height(font_size) + get_theme_constant("line_separation"))
	visible_characters = 0
	margin_left = DialoguePadding.get_theme_constant("margin_left")
	DialoguePadding.add_theme_constant_override("margin_right", margin_left + $TextCursor.size.x)
	
	if blank:
		return
	
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	no_tags_text = regex.sub(text, "", true)
	
	cursor_positions = $TextCursor.get_cursor_positions(no_tags_text)
	$TextCursor.position = cursor_positions[0]
	
	if $Underline.show_underline and !$TextCursor.show_cursor:
		$Underline.size.x = 0
		
	else:
		$Underline.size.x = $TextCursor.size.x
		
	if $HollowBoxControl.show_boxes:
		$TextCursor.hide()
		$TextCursor.position = cursor_positions[2]
		
		for child in $HollowBoxControl.get_children():
			child.position = cursor_positions[0]
		
		$Underline.size.x = HollowBox.size.x
	
	$Underline.position.y = $TextCursor.position.y + $TextCursor.size.y + UNDERLINE_OFFSET


func _process(_delta):
	if window_expanded and !blank:
		
		if !all_chars_displayed:
			
			if frame_count % typewrite_frames == 0:
				
				# Moves the boxes before the text starts to show.
				if $HollowBoxControl.show_boxes and HollowBox.position == cursor_positions[start]:
					HollowBox.position = cursor_positions[start + 1]
					HollowBox.show()
					HollowBox2.position = cursor_positions[start]
					HollowBox2.show()
					$Underline.size.x = HollowBox.position.x + HollowBox.size.x
				
				# Moves the boxes while displaying text.	
				elif $HollowBoxControl.show_boxes:
					visible_characters += 1
					
					# False after text cursor reaches final position.
					if visible_characters + 2 <= cursor_positions.size() - 1:
						$TextCursor.position = cursor_positions[visible_characters + 2]
					
					# Display the cursor once it reaches its final place.
					if visible_characters + 2 == no_tags_text.length():
						$TextCursor.show()
					
					# Loop for moving the boxes. Handles out-of-bounds positions at the start
					# and end. Hides the boxes when they reach the second-to-last position.
					var index = 1
					for child in $HollowBoxControl.get_children():
						if visible_characters - abs(index) >= start:
							
							if visible_characters + index <= cursor_positions.size() - 2:
								child.position = cursor_positions[visible_characters + index]
								if !child.visible:
									child.show()
							else:
								child.hide()
						
						else:
							child.position = cursor_positions[start]
						
						index -= 1
					
					# Sets underline Y position.
					if visible_characters + 1 <= cursor_positions.size() - 1:
						$Underline.position.y = cursor_positions[visible_characters + 1].y + $TextCursor.size.y + UNDERLINE_OFFSET
					
					# Sets underline X position.
					if HollowBox.position == cursor_positions[-2] or HollowBox.position == cursor_positions[-1]:
						$Underline.size.x = $TextCursor.position.x + $TextCursor.size.x
					else:
						$Underline.size.x = HollowBox.position.x + HollowBox.size.x
				
				# Code for displaying the cursor when the boxes are turned off.
				else:
					visible_characters += 1
					$TextCursor.position = cursor_positions[visible_characters]
					
					if $Underline.show_underline and !$TextCursor.show_cursor:
						$Underline.size.x = $TextCursor.position.x
					else:
						$Underline.size.x = $TextCursor.position.x + $TextCursor.size.x
					
					$Underline.position.y = $TextCursor.position.y + $TextCursor.size.y + UNDERLINE_OFFSET
				
				# If boxes are turned off, everything is done now.
				# Flash cursor when all characters are visible.
				if visible_characters == no_tags_text.length():
					if !$HollowBoxControl.show_boxes:
						all_chars_displayed = true
					
					if $TextCursor.show_cursor:
						$TextCursor.flash_cursor()
				
				# If showing boxes, keep going until all boxes reach the end and are hidden.
				# Eight extra steps after text is fully visible.
				if visible_characters + 1 - $HollowBoxControl.get_child_count() == no_tags_text.length():
					all_chars_displayed = true
				
			if !all_chars_displayed:
				frame_count += 1


func _input(event):
	if allow_input:
		if event.is_action_pressed("advance_text") and window_expanded and !BoxWipeContainer.wiping and !ExpandShrinkContainer.shrinking and !blank:
			
			if !all_chars_displayed:
				visible_characters = no_tags_text.length()
				$TextCursor.position = cursor_positions.back()

				if $HollowBoxControl.show_boxes:
					$HollowBoxControl.hide()
					$TextCursor.show()

				if $Underline.show_underline and !$TextCursor.show_cursor:
					$Underline.size.x = $TextCursor.position.x
				else:
					$Underline.size.x = $TextCursor.position.x + $TextCursor.size.x

				$Underline.position.y = $TextCursor.position.y + $TextCursor.size.y + UNDERLINE_OFFSET

				if !$TextCursor.flashing:
					$TextCursor.flash_cursor()

				all_chars_displayed = true
			
			else:
				allow_input = false
			#	print("input")
				emit_signal("dialogue_finished")
		
		elif event.is_action_pressed("advance_text") and window_expanded and !ExpandShrinkContainer.shrinking and blank:
			allow_input = false
		#	print("input")
			emit_signal("dialogue_finished")


func reset_text(new_text : String, char_position : int):
	text = new_text
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	no_tags_text = regex.sub(new_text, "", true)
	visible_characters = char_position
	start = char_position
	cursor_positions = $TextCursor.get_cursor_positions(no_tags_text)
	
	if $TextCursor.show_cursor:
		$TextCursor.show()
		$TextCursor/TextCursor2.hide()
	
	if $Underline.show_underline:
		$Underline.show()
	
	$TextCursor.position = cursor_positions[visible_characters]
	
	if $TextCursor.flash_tween != null:
		$TextCursor.flash_tween.kill()
		$TextCursor.flashing = false
	
	$TextCursor.self_modulate = Color("ffffff")
	$TextCursor/TextCursor2.self_modulate = Color("ffffff00")
	
	if $Underline.show_underline and !$TextCursor.show_cursor:
		$Underline.size.x = $TextCursor.position.x
	else:
		$Underline.size.x = $TextCursor.position.x + $TextCursor.size.x
	
	if $HollowBoxControl.show_boxes:
		$HollowBoxControl.show()
		$TextCursor.hide()
		$TextCursor.position = cursor_positions[visible_characters + 2]
		
		for child in $HollowBoxControl.get_children():
			child.position = cursor_positions[visible_characters]
			child.hide()
		
		HollowBox.show()
		$Underline.size.x = HollowBox.size.x
	
	$Underline.position.y = $TextCursor.position.y + $TextCursor.size.y + UNDERLINE_OFFSET
	frame_count = 1
	all_chars_displayed = false


func add_to_next_line(string : String):
	var old_text = text
	reset_text(old_text + "\n" + string, old_text.length() + 1)
	start = old_text.length() + 1


func find_punctuation(string: String):
	var punct_positions = []
	var punctuation = [".", "?", "!"]
	
	for n in punctuation:
		if string.contains(n):
			var from = 0
			for i in string.count(n):
				punct_positions.append(string.find(n, from))
				from = punct_positions.back() + 1
	
	return punct_positions


func _on_expand_shrink_container_expanded():
	window_expanded = true
