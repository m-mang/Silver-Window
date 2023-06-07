extends PanelContainer

signal dragged(new_position : Vector2)

var drag_position = null
var center_x = false


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
		var max_pos = get_viewport().get_visible_rect().size - size
		
		box_pos = snapped(box_pos, Vector2(10, 10))
		
		if !center_x:
			box_pos.x = clampi(box_pos.x, 0, max_pos.x)
		else:
			box_pos.x = (get_viewport().get_visible_rect().size.x - size.x) / 2
		
		box_pos.y = clampi(box_pos.y, 0, max_pos.y)
		
		global_position = box_pos
		dragged.emit(global_position)
