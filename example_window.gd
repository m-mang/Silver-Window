extends PanelContainer

signal dragged(new_position : Vector2)
signal position_changed(new_position : Vector2)

var drag_position = null
var center_x = false
var paired_size = Vector2(0, 0)
var paired_offset = Vector2(0, 0)
var auto_type = 0 # 0 left, 1 right, 2 top left, 3 top right

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# Start dragging.
			drag_position = get_global_mouse_position() - global_position
		
		else:
			# End dragging.
			drag_position = null
	
	if event is InputEventMouseMotion and drag_position:
		var box_pos = get_global_mouse_position() - drag_position
		var max_pos
		var min_pos
		
		if auto_type == 0: # Left
			max_pos = get_viewport().get_visible_rect().size - size
			min_pos = paired_size + paired_offset
		
		elif auto_type == 1: # Right
			max_pos = get_viewport().get_visible_rect().size - paired_size - size + paired_offset
			min_pos = Vector2(0, paired_size.y - size.y)
		
		elif auto_type == 2: # Top left
			max_pos = get_viewport().get_visible_rect().size - size
			min_pos = paired_size + paired_offset
		
		elif auto_type == 3: # Top right
			max_pos = get_viewport().get_visible_rect().size - size
			min_pos = paired_size + paired_offset
		
		box_pos = snapped(box_pos, Vector2(10, 10))
		
		if !center_x:
			box_pos.x = clampi(box_pos.x, min_pos.x, max_pos.x)
		else:
			box_pos.x = (get_viewport().get_visible_rect().size.x - size.x) / 2
		
		box_pos.y = clampi(box_pos.y, min_pos.y, max_pos.y)
		
		global_position = box_pos
		dragged.emit(global_position)

