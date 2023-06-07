extends GraphNode

signal frame_preset_added(preset_name : String)
signal frame_preset_removed(preset_id : int)

var margin_left
var char_size
#var frame_preset_dict = {}
#var frame_preset_id = 1

@onready var PairedPreview = $VBoxContainer/TextureRect
@onready var PairedPreviewButton = $VBoxContainer/HBoxContainer2/CheckButton
@onready var PairedPath = $VBoxContainer/HBoxContainer/PairedPath
@onready var PairedPosX = $VBoxContainer/HBoxContainer/PairedPosX
@onready var PairedPosY = $VBoxContainer/HBoxContainer/PairedPosY
@onready var PairedAuto = $VBoxContainer/HBoxContainer2/PairedAuto
@onready var PairedAutoOptions = $VBoxContainer/HBoxContainer2/PairedAutoOptions
@onready var TWSpinBox = $VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/TextWidthSpinBox
@onready var AutoWidth = $VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/AutoWidth
@onready var DialogueTextEdit = $VBoxContainer/TextEdit
@onready var LinesBox = $VBoxContainer/MarginContainer3/HBoxContainer/LinesBox
@onready var AutoLines = $VBoxContainer/MarginContainer3/HBoxContainer/AutoLines
@onready var font = $VBoxContainer/TextEdit.get_theme_font("font")
@onready var font_size = $VBoxContainer/TextEdit.get_theme_font_size("font_size")
@onready var PosX = $VBoxContainer/MarginContainer2/HBoxContainer/PositionX
@onready var PosY = $VBoxContainer/MarginContainer2/HBoxContainer/PositionY
@onready var WipeButton = $VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton
@onready var BoxSizeX = $VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/BoxSizeX
@onready var BoxSizeY = $VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/BoxSizeY
@onready var CenterX = $VBoxContainer/HBoxContainer6/CenterX

@onready var ExampleControl = $Control
@onready var ExampleWindow = $Control/ExampleWindow
@onready var ExampleMargin = $Control/ExampleWindow/MarginContainer
@onready var ExampleText = $Control/ExampleWindow/MarginContainer/ExampleText
@onready var ExamplePaired = $Control/ExamplePaired
@onready var ExamplePairedTexRec = $Control/ExamplePaired/TextureRect
@onready var example_font = $Control/ExampleWindow/MarginContainer/ExampleText.get_theme_font("normal_font")
@onready var example_font_size = $Control/ExampleWindow/MarginContainer/ExampleText.get_theme_font_size("normal_font_size")

@onready var ShowFrame = $VBoxContainer/HBoxContainer4/HBoxContainer/ShowFrame
@onready var FramePosX = $VBoxContainer/HBoxContainer4/FramePosX
@onready var FramePosY = $VBoxContainer/HBoxContainer4/FramePosY
@onready var FrameSizeX = $VBoxContainer/HBoxContainer5/FrameSizeX
@onready var FrameSizeY = $VBoxContainer/HBoxContainer5/FrameSizeY
@onready var SavePreset = $VBoxContainer/HBoxContainer5/HBoxContainer/SavePreset
@onready var FramePresets = $VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets
@onready var SpeakerOptions = $VBoxContainer/HBoxContainer3/SpeakerOptions
@onready var SpeakerName = $VBoxContainer/HBoxContainer3/LineEdit

@onready var ExampleName = $Control/ExampleName
@onready var ExampleFrame = $Control/ExampleFrame

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child($Control)
	$"..".add_child(ExampleControl)
	
	ExampleWindow.global_position = Vector2(PosX.value, PosY.value)
	ExampleText.text = DialogueTextEdit.text
	ExampleText.custom_minimum_size.x = TWSpinBox.value
	char_size = example_font.get_char_size("A".to_utf8_buffer()[0], example_font_size)
	margin_left = ExampleMargin.get_theme_constant("margin_left")
	ExampleMargin.add_theme_constant_override("margin_right", margin_left + char_size.x + 9)
	#ExampleWindow.size.x = ExampleText.size.x + 35 + 14 + 4
	ExampleWindow.reset_size()
	
	BoxSizeX.value = ExampleWindow.size.x
	BoxSizeY.value = ExampleWindow.size.y
	
	FramePosX.value = ExampleFrame.global_position.x
	FramePosY.value = ExampleFrame.global_position.y
	FrameSizeX.value = ExampleFrame.size.x
	FrameSizeY.value = ExampleFrame.size.y
	
	ExampleName.position = ExampleFrame.position - Vector2(0, ExampleName.size.y)
	
	for key in $"..".frame_preset_dict:
		FramePresets.add_item(key, $"..".frame_preset_dict[key]["id"])


func _on_close_request():
	queue_free()
	ExampleControl.queue_free()


func _on_resize_request(new_minsize):
	size = new_minsize


func _on_text_edit_text_changed():
	ExampleText.text = DialogueTextEdit.text
	
	if AutoLines.button_pressed:
		LinesBox.value = DialogueTextEdit.get_line_count()
	
	if AutoWidth.button_pressed:
		TWSpinBox.value = example_font.get_multiline_string_size(ExampleText.text, HORIZONTAL_ALIGNMENT_LEFT, -1, example_font_size, -1, 3).x
	
	if PairedAuto.button_pressed and PairedAutoOptions.selected == 1: # Right
		ExampleWindow.emit_signal("position_changed", ExampleWindow.position)
	elif PairedAuto.button_pressed and PairedAutoOptions.selected == 3: # Top right
		ExampleWindow.emit_signal("position_changed", ExampleWindow.position)


func _on_show_example_box_toggled(button_pressed):
	if button_pressed:
		ExampleControl.show()
		
		if PairedAuto.button_pressed:
			PairedAuto.emit_signal("toggled", PairedAuto.button_pressed)
		
	else:
		ExampleControl.hide()


func _on_button_pressed():
	$FileDialog.popup_centered()


func _on_file_dialog_file_selected(path):
	PairedPath.text = path
	PairedPreview.texture = load(path)
	if PairedPreviewButton.button_pressed:
		PairedPreview.show()
	
	ExamplePaired.show()
	ExamplePairedTexRec.texture = null
	ExamplePaired.size = Vector2(0, 0)
	ExamplePairedTexRec.texture = PairedPreview.texture
	#await ExamplePaired.resized
	PairedAuto.emit_signal("toggled", PairedAuto.button_pressed)
	
	if PairedAuto.button_pressed and PairedAutoOptions.selected == 0: # Left
		PairedPosX.value = ExampleWindow.position.x - ExamplePaired.size.x - 10
		PairedPosY.value = ExampleWindow.position.y - (ExamplePaired.size.y - ExampleWindow.size.y)
	elif PairedAuto.button_pressed and PairedAutoOptions.selected == 1: # Right
		PairedPosX.value = ExampleWindow.position.x + ExampleWindow.size.x + 10
		PairedPosY.value = ExampleWindow.position.y - (ExamplePaired.size.y - ExampleWindow.size.y)
	elif PairedAuto.button_pressed and PairedAutoOptions.selected == 2: # Top left
		PairedPosX.value = ExampleWindow.position.x
		PairedPosY.value = ExampleWindow.position.y - ExamplePaired.size.y - 10
	elif PairedAuto.button_pressed and PairedAutoOptions.selected == 3: # Top right
		PairedPosX.value = ExampleWindow.position.x + ExampleWindow.size.x - ExamplePaired.size.x
		PairedPosY.value = ExampleWindow.position.y - ExamplePaired.size.y - 10
	
	ShowFrame.button_pressed = false
	ShowFrame.disabled = true


func _on_check_button_toggled(button_pressed):
	if button_pressed and PairedPath.text != "":
		PairedPreview.show()
	else:
		PairedPreview.hide()
		reset_size()


func _on_example_window_dragged(new_position):
	PosX.value = new_position.x
	PosY.value = new_position.y
	ExampleWindow.emit_signal("position_changed", new_position)


func _on_position_x_value_changed(value):
	ExampleWindow.global_position.x = value
	ExampleWindow.emit_signal("position_changed", Vector2(value, ExampleWindow.global_position.y))


func _on_position_y_value_changed(value):
	ExampleWindow.global_position.y = value
	ExampleWindow.emit_signal("position_changed", Vector2(ExampleWindow.global_position.x, value))


func _on_text_width_spin_box_value_changed(value):
	ExampleText.custom_minimum_size.x = value
	#ExampleWindow.size.x = ExampleText.size.x + 35 + 14 + 4
	ExampleWindow.reset_size()
	
	CenterX.emit_signal("toggled", CenterX.button_pressed)


func _on_auto_width_toggled(button_pressed):
	if button_pressed:
		TWSpinBox.editable = false
		TWSpinBox.value = example_font.get_multiline_string_size($VBoxContainer/TextEdit.text, HORIZONTAL_ALIGNMENT_LEFT, -1, example_font_size, -1, 3).x
	
	else:
		TWSpinBox.editable = true


func _on_clear_button_pressed():
	PairedPath.text = ""
	PairedPreview.texture = null
	PairedPreview.hide()
	reset_size()
	
	ExamplePairedTexRec.texture = null
	ExamplePaired.size = Vector2(0, 0)
	ExamplePaired.hide()
	ExampleWindow.paired_size = Vector2(0, 0)
	ExampleWindow.paired_offset = Vector2(0, 0)
	
	ShowFrame.disabled = false


func _on_example_paired_dragged(new_position):
	PairedPosX.value = new_position.x
	PairedPosY.value = new_position.y


func _on_paired_auto_toggled(button_pressed):
	if PairedPath.text != "":
		if button_pressed:
			ExamplePaired.draggable = false
			PairedPosX.editable = false
			PairedPosY.editable = false
			PairedAutoOptions.disabled = false
			ExampleWindow.emit_signal("position_changed", ExampleWindow.position)
			
			if PairedAutoOptions.selected == 0: # Left
				ExampleWindow.position = ExamplePaired.position + ExampleWindow.paired_size + ExampleWindow.paired_offset
			elif PairedAutoOptions.selected == 1: # Right
				ExampleWindow.position = ExamplePaired.position - ExampleWindow.size + ExampleWindow.paired_offset
			elif PairedAutoOptions.selected == 2: # Top left
				ExampleWindow.position = ExamplePaired.position + ExamplePaired.size + ExampleWindow.paired_offset
			elif PairedAutoOptions.selected == 3: # Top right
				ExampleWindow.position.x = ExamplePaired.position.x - (ExampleWindow.size.x - ExamplePaired.size.x)
				ExampleWindow.position.y = ExamplePaired.position.y + ExamplePaired.size.y + 10
		
		else:
			ExamplePaired.draggable = true
			PairedPosX.editable = true
			PairedPosY.editable = true
			PairedAutoOptions.disabled = true
			ExampleWindow.paired_size = Vector2(0, 0)
			ExampleWindow.paired_offset = Vector2(0, 0)
	
	else:
		if button_pressed:
			PairedAutoOptions.disabled = false
		else:
			PairedAutoOptions.disabled = true


func _on_paired_pos_x_value_changed(value):
	ExamplePaired.position.x = value


func _on_paired_pos_y_value_changed(value):
	ExamplePaired.position.y = value


func _on_example_window_position_changed(new_position):
	if PairedAuto.button_pressed and PairedPath.text != "":
		# Auto left.
		if PairedAutoOptions.get_selected_id() == 0:
			var new_x = new_position.x - ExamplePaired.size.x - 10
			var new_y = new_position.y - (ExamplePaired.size.y - ExampleWindow.size.y)
			var max_pos = get_viewport().get_visible_rect().size - ExamplePaired.size
			
			ExampleWindow.auto_type = 0
			ExampleWindow.paired_size = ExamplePaired.size
			ExampleWindow.paired_offset = Vector2(10, -ExampleWindow.size.y)
			ExamplePaired.position.x = clampi(new_x, 0, max_pos.x)
			ExamplePaired.position.y = clampi(new_y, 0, max_pos.y)
			#ExamplePaired.position = Vector2(new_x, new_y)
			PairedPosX.value = ExamplePaired.position.x
			PairedPosY.value = ExamplePaired.position.y
		
		# Auto right.
		elif PairedAutoOptions.get_selected_id() == 1:
			var new_x = new_position.x + ExampleWindow.size.x + 10
			var new_y = new_position.y - (ExamplePaired.size.y - ExampleWindow.size.y)
			#var min_pos = ExampleWindow.size + Vector2(10, ExamplePaired.size.y)
			var max_pos = get_viewport().get_visible_rect().size - ExamplePaired.size
			
			ExampleWindow.auto_type = 1
			ExampleWindow.paired_size = ExamplePaired.size
			ExampleWindow.paired_offset = Vector2(-10, ExamplePaired.size.y)
			ExamplePaired.position.x = clampi(new_x, 0, max_pos.x)
			ExamplePaired.position.y = clampi(new_y, 0, max_pos.y)
			#ExamplePaired.position = Vector2(new_x, new_y)
			PairedPosX.value = ExamplePaired.position.x
			PairedPosY.value = ExamplePaired.position.y
		
		# Auto top left.
		if PairedAutoOptions.get_selected_id() == 2:
			var new_x = new_position.x
			var new_y = new_position.y - 10 - ExamplePaired.size.y
			var max_pos = get_viewport().get_visible_rect().size - ExamplePaired.size
			
			ExampleWindow.auto_type = 2
			ExampleWindow.paired_size = ExamplePaired.size
			ExampleWindow.paired_offset = Vector2(-ExamplePaired.size.x, 10)
			ExamplePaired.position.x = clampi(new_x, 0, max_pos.x)
			ExamplePaired.position.y = clampi(new_y, 0, max_pos.y)
			#ExamplePaired.position = Vector2(new_x, new_y)
			PairedPosX.value = ExamplePaired.position.x
			PairedPosY.value = ExamplePaired.position.y
		
		# Auto top right.
		if PairedAutoOptions.get_selected_id() == 3:
			var new_x = new_position.x + ExampleWindow.size.x - ExamplePaired.size.x
			var new_y = new_position.y - 10 - ExamplePaired.size.y
			var max_pos = get_viewport().get_visible_rect().size - ExamplePaired.size
			
			ExampleWindow.auto_type = 3
			ExampleWindow.paired_size = ExamplePaired.size
			ExampleWindow.paired_offset = Vector2(-ExamplePaired.size.x, 10)
			ExamplePaired.position.x = clampi(new_x, 0, max_pos.x)
			ExamplePaired.position.y = clampi(new_y, 0, max_pos.y)
			#ExamplePaired.position = Vector2(new_x, new_y)
			PairedPosX.value = ExamplePaired.position.x
			PairedPosY.value = ExamplePaired.position.y


func _on_auto_lines_toggled(button_pressed):
	if button_pressed:
		LinesBox.editable = false
		LinesBox.value = DialogueTextEdit.get_line_count()
	
	else:
		LinesBox.editable = true


func _on_lines_box_value_changed(value):
	ExampleText.custom_minimum_size.y = value * (example_font.get_height(example_font_size) + ExampleWindow.get_theme_constant("line_separation", "RichTextLabel"))
	#ExampleWindow.size.y = ExampleText.size.y + 12 + 4
	ExampleWindow.reset_size()
	
	if PairedAuto.button_pressed:
		PairedAuto.emit_signal("toggled", PairedAuto.button_pressed)


func _on_new_box_check_toggled(button_pressed):
	if button_pressed:
		WipeButton.disabled = true
	
	else:
		WipeButton.disabled = false


func _on_paired_auto_options_item_selected(index):
	if index == 0: # Left
		ExampleWindow.auto_type = 0
	elif index == 1: # Right
		ExampleWindow.auto_type = 1
	elif index == 2: # Top left
		ExampleWindow.auto_type = 2
	elif index == 3: # Top right
		ExampleWindow.auto_type = 3
	
	ExampleWindow.emit_signal("position_changed", ExampleWindow.position)



func _on_example_window_resized():
	BoxSizeX.value = ExampleWindow.size.x
	BoxSizeY.value = ExampleWindow.size.y


func _on_show_frame_toggled(button_pressed):
	if FramePresets.selected == 0:
		if button_pressed:
			ExampleFrame.show()
			ExampleName.show()
			FramePosX.editable = true
			FramePosY.editable = true
			FrameSizeX.editable = true
			FrameSizeY.editable = true
		else:
			ExampleFrame.hide()
			ExampleName.hide()
			FramePosX.editable = false
			FramePosY.editable = false
			FrameSizeX.editable = false
			FrameSizeY.editable = false
	else:
		if button_pressed:
			ExampleFrame.show()
			ExampleName.show()
		else:
			ExampleFrame.hide()
			ExampleName.hide()


func _on_line_edit_text_changed(new_text):
	ExampleName.text = new_text
	ExampleName.reset_size()
	
	ExampleFrame.emit_signal("transform_changed")


func _on_example_frame_dragged(new_position):
	FramePosX.value = new_position.x
	FramePosY.value = new_position.y
	
	ExampleFrame.emit_signal("transform_changed")


func _on_speaker_options_item_selected(_index):
	ExampleFrame.emit_signal("transform_changed")


func _on_frame_pos_x_value_changed(value):
	ExampleFrame.position.x = value
	
	ExampleFrame.emit_signal("transform_changed")


func _on_frame_pos_y_value_changed(value):
	ExampleFrame.position.y = value
	
	ExampleFrame.emit_signal("transform_changed")


func _on_frame_size_x_value_changed(value):
	ExampleFrame.size.x = value
	
	ExampleFrame.emit_signal("transform_changed")


func _on_frame_size_y_value_changed(value):
	ExampleFrame.size.y = value
	
	ExampleFrame.emit_signal("transform_changed")


func _on_example_frame_transform_changed():
	if SpeakerOptions.selected == 0:
		ExampleName.position = ExampleFrame.position - Vector2(0, ExampleName.size.y)
	elif SpeakerOptions.selected == 1:
		ExampleName.position = ExampleFrame.position + Vector2(0, ExampleFrame.size.y)
	elif SpeakerOptions.selected == 2:
		ExampleName.position = ExampleFrame.position + Vector2(-(ExampleName.size.x + 10), (ExampleFrame.size.y / 2) - (ExampleName.size.y / 2))
	elif SpeakerOptions.selected == 3:
		ExampleName.position = ExampleFrame.position + Vector2(ExampleFrame.size.x + 10, (ExampleFrame.size.y / 2) - (ExampleName.size.y / 2))


func _on_save_preset_pressed():
	$PopupPanel/LineEdit.clear()
	$PopupPanel.popup_centered()
	$PopupPanel/LineEdit.grab_focus()


func _on_line_edit_text_submitted(new_text):
	$"..".frame_preset_dict[new_text] = {"name": SpeakerName.text, "speaker option": SpeakerOptions.selected, "id": $"..".frame_preset_id, "pos x": FramePosX.value, "pos y": FramePosY.value, "size x": FrameSizeX.value, "size y": FrameSizeY.value}
	FramePresets.add_item(new_text, $"..".frame_preset_id)
	FramePresets.select(FramePresets.get_item_index($"..".frame_preset_id))
	FramePresets.emit_signal("item_selected", FramePresets.get_selected())
	$"..".frame_preset_id += 1
	
	$PopupPanel.hide()
	emit_signal("frame_preset_added", new_text)


func _on_remove_preset_pressed():
	if FramePresets.selected != 0:
		var removed_id = FramePresets.get_item_id(FramePresets.get_selected())
		
		$"..".frame_preset_dict.erase(FramePresets.get_item_text(FramePresets.get_selected()))
		FramePresets.remove_item(FramePresets.get_selected())
		FramePresets.select(0)
		FramePresets.emit_signal("item_selected", 0)
		
		emit_signal("frame_preset_removed", removed_id)


func _on_frame_presets_item_selected(index):
	if index != 0:
		SpeakerName.text = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["name"]
		SpeakerName.emit_signal("text_changed", SpeakerName.text)
		SpeakerOptions.selected = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["speaker option"]
		FramePosX.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["pos x"]
		FramePosY.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["pos y"]
		FrameSizeX.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["size x"]
		FrameSizeY.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["size y"]
		
		FramePosX.editable = false
		FramePosY.editable = false
		FrameSizeX.editable = false
		FrameSizeY.editable = false
		
		ExampleFrame.draggable = false
	
	else:
		if ShowFrame.button_pressed:
			FramePosX.editable = true
			FramePosY.editable = true
			FrameSizeX.editable = true
			FrameSizeY.editable = true
		
		ExampleFrame.draggable = true


func _on_center_x_toggled(button_pressed):
	if button_pressed:
		ExampleWindow.center_x = true
		PosX.editable = false
		ExampleWindow.global_position.x = (get_viewport().get_visible_rect().size.x - ExampleWindow.size.x) / 2
		ExampleWindow.emit_signal("dragged", ExampleWindow.global_position)
	else:
		ExampleWindow.center_x = false
		PosX.editable = true
