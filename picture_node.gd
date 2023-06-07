extends GraphNode

signal position_changed(new_position : Vector2)

var original_size : Vector2

@onready var PicturePath = $VBoxContainer/HBoxContainer2/PicturePath
@onready var PreviewRect = $VBoxContainer/PreviewRect
@onready var PreviewButton = $VBoxContainer/CenterContainer2/HBoxContainer/PreviewButton
@onready var SizeXSpinBox = $VBoxContainer/HBoxContainer3/SizeXSpinBox
@onready var SizeYSpinBox = $VBoxContainer/HBoxContainer3/SizeYSpinBox
@onready var ResetSizeButton = $VBoxContainer/HBoxContainer3/ResetSizeButton
@onready var KeepAspectBox = $VBoxContainer/HBoxContainer3/KeepAspectBox
@onready var PosXSpinBox = $VBoxContainer/HBoxContainer/PosXSpinBox
@onready var PosYSpinBox = $VBoxContainer/HBoxContainer/PosYSpinBox
@onready var CenterXCheck = $VBoxContainer/HBoxContainer/CenterXCheck

@onready var ExamplePictureWindow = $ExamplePictureWindow
@onready var ExamplePictureContainer = $ExamplePictureWindow/PictureContainer
@onready var ExamplePictureRect = $ExamplePictureWindow/PictureContainer/PictureRect
@onready var example_border_width_left = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_left
@onready var example_border_width_top = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_top
@onready var example_border_width_right = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_right
@onready var example_border_width_bottom = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_bottom


func _ready():
	remove_child($ExamplePictureWindow)
	$"..".add_child(ExamplePictureWindow)
	
	SizeXSpinBox.value = ExamplePictureContainer.size.x
	SizeYSpinBox.value = ExamplePictureContainer.size.y
	original_size = ExamplePictureContainer.size
	PosXSpinBox.value = ExamplePictureContainer.global_position.x
	PosYSpinBox.value = ExamplePictureContainer.global_position.y


func _on_close_request():
	queue_free()
	ExamplePictureWindow.queue_free()


func _on_resize_request(new_minsize):
	size = new_minsize


func _on_open_button_pressed():
	$FileDialog.popup_centered()


func _on_file_dialog_file_selected(path):
	PicturePath.text = path
	PreviewRect.texture = load(path)
	if PreviewButton.button_pressed:
		PreviewRect.show()
	
	ExamplePictureRect.texture = null
	ExamplePictureContainer.custom_minimum_size = Vector2(0, 0)
	ExamplePictureContainer.reset_size()
	ExamplePictureRect.expand_mode = 0
	ExamplePictureRect.texture = PreviewRect.texture
	
	await get_tree().process_frame
	CenterXCheck.emit_signal("toggled", CenterXCheck.button_pressed)
	
	original_size = ExamplePictureContainer.get_combined_minimum_size()
	SizeXSpinBox.value = ExamplePictureContainer.get_combined_minimum_size().x
	SizeYSpinBox.value = ExamplePictureContainer.get_combined_minimum_size().y
	
	PosXSpinBox.value = ExamplePictureContainer.global_position.x
	PosYSpinBox.value = ExamplePictureContainer.global_position.y


func _on_show_example_box_toggled(button_pressed):
	if button_pressed:
		ExamplePictureWindow.show()
	else:
		ExamplePictureWindow.hide()


func _on_preview_button_toggled(button_pressed):
	if button_pressed and PicturePath.text != "":
		PreviewRect.show()
	else:
		PreviewRect.hide()
		reset_size()


func _on_clear_button_pressed():
	PicturePath.text = ""
	PreviewRect.texture = null
	PreviewRect.hide()
	reset_size()
	
	ExamplePictureRect.texture = null
	original_size = Vector2(204, 204)
	ResetSizeButton.emit_signal("pressed")


func _on_center_x_check_toggled(button_pressed):
	if button_pressed:
		ExamplePictureContainer.center_x = true
		PosXSpinBox.editable = false
		ExamplePictureContainer.global_position.x = (get_viewport().get_visible_rect().size.x - ExamplePictureContainer.size.x) / 2
		emit_signal("position_changed", ExamplePictureContainer.global_position)
	else:
		ExamplePictureContainer.center_x = false
		PosXSpinBox.editable = true


func _on_position_changed(new_position):
	PosXSpinBox.value = new_position.x
	PosYSpinBox.value = new_position.y


func _on_picture_container_dragged(new_position):
	emit_signal("position_changed", new_position)


func _on_pos_x_spin_box_value_changed(value):
	ExamplePictureContainer.global_position.x = value


func _on_pos_y_spin_box_value_changed(value):
	ExamplePictureContainer.global_position.y = value


func _on_size_x_spin_box_value_changed(value):
	if value < original_size.x:
		ExamplePictureRect.expand_mode = 1
	
	ExamplePictureContainer.size.x = value
	
	if KeepAspectBox.button_pressed:
		var value_no_border = value - example_border_width_left - example_border_width_right
		var OG_size_no_border = original_size - Vector2(example_border_width_left + example_border_width_right, example_border_width_top + example_border_width_bottom)
		var size_y_no_border = value_no_border * OG_size_no_border.y / OG_size_no_border.x
		
		SizeYSpinBox.value = size_y_no_border + example_border_width_top + example_border_width_bottom
	
	CenterXCheck.emit_signal("toggled", CenterXCheck.button_pressed)


func _on_size_y_spin_box_value_changed(value):
	if value < original_size.y:
		ExamplePictureRect.expand_mode = 1
	
	ExamplePictureContainer.size.y = value
	
	if KeepAspectBox.button_pressed:
		var value_no_border = value - example_border_width_top - example_border_width_bottom
		var OG_size_no_border = original_size - Vector2(example_border_width_left + example_border_width_right, example_border_width_top + example_border_width_bottom)
		var size_x_no_border = value_no_border * OG_size_no_border.x / OG_size_no_border.y
		
		SizeXSpinBox.value = size_x_no_border + example_border_width_left + example_border_width_right
	
	CenterXCheck.emit_signal("toggled", CenterXCheck.button_pressed)


func _on_reset_size_button_pressed():
	ExamplePictureRect.expand_mode = 0
	ExamplePictureContainer.size = original_size
	SizeXSpinBox.value = ExamplePictureContainer.size.x
	SizeYSpinBox.value = ExamplePictureContainer.size.y
	CenterXCheck.emit_signal("toggled", CenterXCheck.button_pressed)


func _on_keep_aspect_box_toggled(button_pressed):
	if button_pressed:
		ExamplePictureRect.stretch_mode = 5
		SizeXSpinBox.emit_signal("value_changed", ExamplePictureContainer.size.x)
	
	else:
		ExamplePictureRect.stretch_mode = 0
