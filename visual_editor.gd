extends GraphEdit

var global_node_count = 0
var node_offset = Vector2(60, 0)

var dialogue_node = preload("res://dialogue_node.tscn")
var dialogue_node_index = 0
var dialogue_node_pos = Vector2(20, 120)

var picture_node = preload("res://picture_node.tscn")
var picture_node_index = 0
var picture_node_pos = Vector2(20, 620)

var drag_position = null
var json_string

var frame_preset_dict = {}
var frame_preset_id = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	# This is recommended for some reason, idk why.
	OS.low_processor_usage_mode = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func clear_nodes():
	clear_connections()
	get_tree().call_group("graph_nodes", "queue_free")
	$HBoxContainer/HBoxContainer/Label2.text = "New File"
	dialogue_node_index = 0
	dialogue_node_pos = Vector2(20, 120)
	picture_node_index = 0
	picture_node_pos = Vector2(20, 620)
	global_node_count = 0
	
	frame_preset_dict.clear()
	frame_preset_id = 1


func save(path : String, thing_to_save):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(thing_to_save)


func load_json_file(path: String):
	if FileAccess.file_exists(path):
		var json_file = FileAccess.open(path, FileAccess.READ)
		var parsed = JSON.parse_string(json_file.get_as_text())
		
		if parsed is Dictionary:
			return parsed
		
		else:
			print("Error: Parsed result not dictionary.")
		
	else:
		print("Error: File does not exist.")


func _input(event):
	if event.is_action_pressed("new_dialogue_node"):
		$HBoxContainer/DialogueNodeButton.emit_signal("pressed")
	elif event.is_action_pressed("new_picture_node"):
		$HBoxContainer/PictureNodeButton.emit_signal("pressed")
	elif event.is_action_pressed("save_dialogue_json"):
		$HBoxContainer/RunButton.emit_signal("pressed")
	elif event.is_action_pressed("save_picture_json"):
		$HBoxContainer/PictureRunButton.emit_signal("pressed")
	elif event.is_action_pressed("load_json"):
		$HBoxContainer/LoadJSON.emit_signal("pressed")
	elif event.is_action_pressed("clear_connections"):
		$HBoxContainer/ClearConnections.emit_signal("pressed")
	elif event.is_action_pressed("clear_nodes"):
		$HBoxContainer/ClearNodes.emit_signal("pressed")
	elif event.is_action_pressed("quit_visual_editor"):
		$HBoxContainer/QuitButton.emit_signal("pressed")


func _on_dialogue_node_button_pressed():
	# Instance dialogue node.
	var dialogue_node_instance = dialogue_node.instantiate()
	
	dialogue_node_instance.connect("dragged", _on_dialogue_node_instance_dragged)
	dialogue_node_instance.connect("frame_preset_added", _on_dialogue_node_instance_frame_preset_added)
	dialogue_node_instance.connect("frame_preset_removed", _on_dialogue_node_instance_frame_preset_removed)
	
	dialogue_node_instance.title += " " + str(dialogue_node_index)
#	dialogue_node_instance.position_offset += (node_offset + Vector2(dialogue_node_instance.size.x, 0)) * dialogue_node_index
	if dialogue_node_index != 0:
		dialogue_node_instance.position_offset = dialogue_node_pos + (node_offset + Vector2(dialogue_node_instance.size.x, 0))
	
	dialogue_node_pos = dialogue_node_instance.position_offset
	
	add_child(dialogue_node_instance)
	dialogue_node_index += 1
	global_node_count += 1


func _on_dialogue_node_instance_dragged(from, to):
	if from == dialogue_node_pos:
		dialogue_node_pos = to


func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)


func _on_run_button_pressed():
	var connection_list = get_connection_list()
	var dialogue_connections = []
	var node_dict = {}
	var picture_dict = {}
	
	for i in connection_list.size():
		var from_node = get_node(str(connection_list[i].from))
		var to_node = get_node(str(connection_list[i].to))
		var from_node_id = str(from_node)
		var to_node_id = str(to_node)
		
		if from_node_id.contains("Picture"):
			if not picture_dict.has(from_node):
				picture_dict[from_node] = {"from": null, "to": to_node}
			else:
				picture_dict[from_node]["to"] = to_node
		if to_node_id.contains("Picture"):
			if not picture_dict.has(to_node):
				picture_dict[to_node] = {"from": from_node, "to": null} 
			else:
				picture_dict[to_node]["from"] = from_node
	
#	print(picture_dict)
	
	for i in connection_list.size():
		if connection_list[i]["from_port"] == 0 and connection_list[i]["to_port"] == 0:
			dialogue_connections.append(connection_list[i])
	
	if dialogue_connections.size() == 0:
		$SaveErrorDialog.popup_centered()
		return
	
	for i in dialogue_connections.size():
		var from_node = get_node(str(dialogue_connections[i].from))
		var to_node = get_node(str(dialogue_connections[i].to))
		var node = from_node
		var type
		
		if node.get_node("VBoxContainer/TextEdit").text != "":
			type = "text"
		else:
			type = "blank"
		
		if type == "blank":
			node_dict[str(i)] = {"type": "blank"}
		
		elif type == "text":
			var new_box = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").button_pressed
			var speaker_name = node.get_node("VBoxContainer/HBoxContainer3/LineEdit").text
			var speaker_option = node.get_node("VBoxContainer/HBoxContainer3/SpeakerOptions").selected
			var text = node.get_node("VBoxContainer/TextEdit").text
			var auto_width = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/AutoWidth").button_pressed
			var width = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/TextWidthSpinBox").value
			var lines = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/LinesBox").value
			var auto_lines = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/AutoLines").button_pressed
			
			if !new_box:
				var wipe = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton").button_pressed
				var old_box_index = i - 1
				
				while node_dict[str(old_box_index)]["new"] == false:
					old_box_index -= 1
					
				if width > node_dict[str(old_box_index)]["width"]:
					node_dict[str(old_box_index)]["width"] = width
					node_dict[str(old_box_index)]["auto_width"] = false
				
				if lines > node_dict[str(old_box_index)]["lines"] and wipe:
					node_dict[str(old_box_index)]["lines"] = lines
					node_dict[str(old_box_index)]["auto_lines"] = false
				
				if !wipe and node_dict[str(old_box_index)]["auto_lines"]:
					node_dict[str(old_box_index)]["lines"] = node_dict[str(old_box_index)]["lines"] + lines
					node_dict[str(old_box_index)]["auto_lines"] = false
					
#					if node_dict[str(old_box_index)]["paired"] and node_dict[str(old_box_index)]["paired auto"]:
#						if node_dict[str(old_box_index)]["paired auto option"] == 0 or node_dict[str(old_box_index)]["paired auto option"] == 1:
#							node_dict[str(old_box_index)]["paired pos y"] = 
				
				node_dict[str(i)] = {
					"type": type,
					"new": new_box,
					"name": speaker_name,
					"speaker option": speaker_option,
					"text": text,
					"width": width,
					"auto_width": auto_width,
					"wipe": wipe
				}
			else:
				var dialogue_center_x = node.get_node("VBoxContainer/HBoxContainer6/CenterX").button_pressed
				var pos_x = node.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionX").value
				var pos_y = node.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionY").value
				var paired
				
				if node.get_node("VBoxContainer/HBoxContainer/PairedPath").text != "":
					paired = true
				else:
					paired = false
				
				if paired:
					var path = node.get_node("VBoxContainer/HBoxContainer/PairedPath").text
					var paired_auto = node.get_node("VBoxContainer/HBoxContainer2/PairedAuto").button_pressed
					var paired_auto_option = node.get_node("VBoxContainer/HBoxContainer2/PairedAutoOptions").selected
					var paired_pos_x = node.get_node("VBoxContainer/HBoxContainer/PairedPosX").value
					var paired_pos_y = node.get_node("VBoxContainer/HBoxContainer/PairedPosY").value
					
					node_dict[str(i)] = {
						"type": type,
						"new": new_box,
						"name": speaker_name,
						"speaker option": speaker_option,
						"text": text,
						"width": width,
						"auto_width": auto_width,
						"lines": lines,
						"auto_lines": auto_lines,
						"dialogue center x": dialogue_center_x,
						"pos x": pos_x,
						"pos y": pos_y,
						"paired": paired,
						"paired_auto": paired_auto,
						"paired auto option": paired_auto_option,
						"path": path,
						"paired pos x": paired_pos_x,
						"paired pos y": paired_pos_y
					}
				else:
					var show_frame = node.get_node("VBoxContainer/HBoxContainer4/HBoxContainer/ShowFrame").button_pressed
					
					node_dict[str(i)] = {
						"type": type,
						"new": new_box,
						"name": speaker_name,
						"speaker option": speaker_option,
						"text": text,
						"width": width,
						"auto_width": auto_width,
						"lines": lines,
						"auto_lines": auto_lines,
						"dialogue center x": dialogue_center_x,
						"pos x": pos_x,
						"pos y": pos_y,
						"paired": paired,
						"show frame": show_frame
					}
					
					if show_frame:
						var frame_preset = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_item_id(node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_selected())
						var frame_pos_x = node.get_node("VBoxContainer/HBoxContainer4/FramePosX").value
						var frame_pos_y = node.get_node("VBoxContainer/HBoxContainer4/FramePosY").value
						var frame_size_x = node.get_node("VBoxContainer/HBoxContainer5/FrameSizeX").value
						var frame_size_y = node.get_node("VBoxContainer/HBoxContainer5/FrameSizeY").value
						var speaker_pos_x = node.ExampleName.position.x
						var speaker_pos_y = node.ExampleName.position.y
						
						node_dict[str(i)]["frame preset"] = frame_preset
						node_dict[str(i)]["frame pos x"] = frame_pos_x
						node_dict[str(i)]["frame pos y"] = frame_pos_y
						node_dict[str(i)]["frame size x"] = frame_size_x
						node_dict[str(i)]["frame size y"] = frame_size_y
						node_dict[str(i)]["speaker pos x"] = speaker_pos_x
						node_dict[str(i)]["speaker pos y"] = speaker_pos_y
		
		var start_picture = false
		var pic_to_start = []
		var picture_path = []
		var picture_pos_x = []
		var picture_pos_y = []
		var center_x = []
		var picture_size_x = []
		var picture_size_y = []
		var keep_aspect = []
		
		var end_picture = false
		var pic_to_end = []
		
		for key in picture_dict.keys():
			if picture_dict[key].from == node:
				start_picture = true
				pic_to_start.append(str(key))
				picture_path.append(key.get_node("VBoxContainer/HBoxContainer2/PicturePath").text)
				picture_pos_x.append(key.get_node("VBoxContainer/HBoxContainer/PosXSpinBox").value)
				picture_pos_y.append(key.get_node("VBoxContainer/HBoxContainer/PosYSpinBox").value)
				center_x.append(key.get_node("VBoxContainer/HBoxContainer/CenterXCheck").button_pressed)
				picture_size_x.append(key.get_node("VBoxContainer/HBoxContainer3/SizeXSpinBox").value)
				picture_size_y.append(key.get_node("VBoxContainer/HBoxContainer3/SizeYSpinBox").value)
				keep_aspect.append(key.get_node("VBoxContainer/HBoxContainer3/KeepAspectBox").button_pressed)
			
			if picture_dict[key].to == node:
				end_picture = true
				pic_to_end.append(str(key))
		
		if start_picture:	
			node_dict[str(i)]["start picture"] = true
			node_dict[str(i)]["picture to start"] = pic_to_start
			node_dict[str(i)]["picture path"] = picture_path
			node_dict[str(i)]["picture pos x"] = picture_pos_x
			node_dict[str(i)]["picture pos y"] = picture_pos_y
			node_dict[str(i)]["center x"] = center_x
			node_dict[str(i)]["picture size x"] = picture_size_x
			node_dict[str(i)]["picture size y"] = picture_size_y
			node_dict[str(i)]["keep aspect"] = keep_aspect
			
		else:
			node_dict[str(i)]["start picture"] = false
		
		if end_picture:
			node_dict[str(i)]["end picture"] = true
			node_dict[str(i)]["picture to end"] = pic_to_end
		else:
			node_dict[str(i)]["end picture"] = false
		
		# Saves information for the final node.
		if i == dialogue_connections.size() - 1:
			node = to_node
			
			if node.get_node("VBoxContainer/TextEdit").text != "":
				type = "text"
			else:
				type = "blank"
			
			if type == "blank":
				node_dict[str(i + 1)] = {"type": "blank"}
		
			elif type == "text":
				var new_box = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").button_pressed
				var speaker_name = node.get_node("VBoxContainer/HBoxContainer3/LineEdit").text
				var speaker_option = node.get_node("VBoxContainer/HBoxContainer3/SpeakerOptions").selected
				var text = node.get_node("VBoxContainer/TextEdit").text
				var width = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/TextWidthSpinBox").value
				var auto_width = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/AutoWidth").button_pressed
				var lines = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/LinesBox").value
				var auto_lines = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/AutoLines").button_pressed
				
				if !new_box:
					var wipe = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton").button_pressed
					var old_box_index = i
					
					while node_dict[str(old_box_index)]["new"] == false:
						old_box_index -= 1
						
					if width > node_dict[str(old_box_index)]["width"]:
						node_dict[str(old_box_index)]["width"] = width
						node_dict[str(old_box_index)]["auto_width"] = false
					
					if lines > node_dict[str(old_box_index)]["lines"] and wipe:
						node_dict[str(old_box_index)]["lines"] = lines
						node_dict[str(old_box_index)]["auto_lines"] = false
					
					if !wipe and node_dict[str(old_box_index)]["auto_lines"]:
						node_dict[str(old_box_index)]["lines"] = node_dict[str(old_box_index)]["lines"] + lines
						node_dict[str(old_box_index)]["auto_lines"] = false
					
					node_dict[str(i + 1)] = {
						"type": type,
						"new": new_box,
						"name": speaker_name,
						"text": text,
						"width": width,
						"auto_width": auto_width,
						"wipe": wipe
					}
				else:
					var dialogue_center_x = node.get_node("VBoxContainer/HBoxContainer6/CenterX").button_pressed
					var pos_x = node.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionX").value
					var pos_y = node.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionY").value
					var paired
					
					if node.get_node("VBoxContainer/HBoxContainer/PairedPath").text != "":
						paired = true
					else:
						paired = false
					
					if paired:
						var path = node.get_node("VBoxContainer/HBoxContainer/PairedPath").text
						var paired_auto = node.get_node("VBoxContainer/HBoxContainer2/PairedAuto").button_pressed
						var paired_auto_option = node.get_node("VBoxContainer/HBoxContainer2/PairedAutoOptions").selected
						var paired_pos_x = node.get_node("VBoxContainer/HBoxContainer/PairedPosX").value
						var paired_pos_y = node.get_node("VBoxContainer/HBoxContainer/PairedPosY").value
						
						node_dict[str(i + 1)] = {
							"type": type,
							"new": new_box,
							"name": speaker_name,
							"speaker option": speaker_option,
							"text": text,
							"width": width,
							"auto_width": auto_width,
							"lines": lines,
							"auto_lines": auto_lines,
							"dialogue center x": dialogue_center_x,
							"pos x": pos_x,
							"pos y": pos_y,
							"paired": paired,
							"paired_auto": paired_auto,
							"paired auto option": paired_auto_option,
							"path": path,
							"paired pos x": paired_pos_x,
							"paired pos y": paired_pos_y
						}
						
					else:
						var show_frame = node.get_node("VBoxContainer/HBoxContainer4/HBoxContainer/ShowFrame").button_pressed
						
						node_dict[str(i + 1)] = {
							"type": type,
							"new": new_box,
							"name": speaker_name,
							"speaker option": speaker_option,
							"text": text,
							"width": width,
							"auto_width": auto_width,
							"lines": lines,
							"auto_lines": auto_lines,
							"dialogue center x": dialogue_center_x,
							"pos x": pos_x,
							"pos y": pos_y,
							"paired": paired,
							"show frame": show_frame
						}
						
						if show_frame:
							var frame_preset = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_item_id(node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_selected())
							var frame_pos_x = node.get_node("VBoxContainer/HBoxContainer4/FramePosX").value
							var frame_pos_y = node.get_node("VBoxContainer/HBoxContainer4/FramePosY").value
							var frame_size_x = node.get_node("VBoxContainer/HBoxContainer5/FrameSizeX").value
							var frame_size_y = node.get_node("VBoxContainer/HBoxContainer5/FrameSizeY").value
							var speaker_pos_x = node.ExampleName.position.x
							var speaker_pos_y = node.ExampleName.position.y
							
							node_dict[str(i + 1)]["frame preset"] = frame_preset
							node_dict[str(i + 1)]["frame pos x"] = frame_pos_x
							node_dict[str(i + 1)]["frame pos y"] = frame_pos_y
							node_dict[str(i + 1)]["frame size x"] = frame_size_x
							node_dict[str(i + 1)]["frame size y"] = frame_size_y
							node_dict[str(i + 1)]["speaker pos x"] = speaker_pos_x
							node_dict[str(i + 1)]["speaker pos y"] = speaker_pos_y
			
			start_picture = false
			var pic_to_start2 = []
			var picture_path2 = []
			var picture_pos_x2 = []
			var picture_pos_y2 = []
			var center_x2 = []
			var picture_size_x2 = []
			var picture_size_y2 = []
			var keep_aspect2 = []
			
			end_picture = false
			var pic_to_end2 = []
			
			for key in picture_dict.keys():
				if picture_dict[key].from == node:
					start_picture = true
					pic_to_start2.append(str(key))
					picture_path2.append(key.get_node("VBoxContainer/HBoxContainer2/PicturePath").text)
					picture_pos_x2.append(key.get_node("VBoxContainer/HBoxContainer/PosXSpinBox").value)
					picture_pos_y2.append(key.get_node("VBoxContainer/HBoxContainer/PosYSpinBox").value)
					center_x2.append(key.get_node("VBoxContainer/HBoxContainer/CenterXCheck").button_pressed)
					picture_size_x2.append(key.get_node("VBoxContainer/HBoxContainer3/SizeXSpinBox").value)
					picture_size_y2.append(key.get_node("VBoxContainer/HBoxContainer3/SizeYSpinBox").value)
					keep_aspect2.append(key.get_node("VBoxContainer/HBoxContainer3/KeepAspectBox").button_pressed)
				
				if picture_dict[key].to == node:
					end_picture = true
					pic_to_end2.append(str(key))
			
			if start_picture:
				node_dict[str(i + 1)]["start picture"] = true
				node_dict[str(i + 1)]["picture to start"] = pic_to_start2
				node_dict[str(i + 1)]["picture path"] = picture_path2
				node_dict[str(i + 1)]["picture pos x"] = picture_pos_x2
				node_dict[str(i + 1)]["picture pos y"] = picture_pos_y2
				node_dict[str(i + 1)]["center x"] = center_x2
				node_dict[str(i + 1)]["picture size x"] = picture_size_x2
				node_dict[str(i + 1)]["picture size y"] = picture_size_y2
				node_dict[str(i + 1)]["keep aspect"] = keep_aspect2
				
			else:
				node_dict[str(i + 1)]["start picture"] = false
			
			if end_picture:
				node_dict[str(i + 1)]["end picture"] = true
				node_dict[str(i + 1)]["picture to end"] = pic_to_end2
			else:
				node_dict[str(i + 1)]["end picture"] = false
	
	node_dict[str(0)]["frame preset dict"] = frame_preset_dict
	node_dict[str(0)]["frame preset id"] = frame_preset_id
	
	json_string = JSON.stringify(node_dict)
	$FileDialog.popup_centered()
#	print(node_dict)


func _on_clear_connections_pressed():
	$ClearConnectionsDialog.popup_centered()


func _on_picture_node_button_pressed():
	# Instance picture node.
	var picture_node_instance = picture_node.instantiate()
	
	picture_node_instance.connect("dragged", _on_picture_node_instance_dragged)
	
	picture_node_instance.title += " " + str(picture_node_index)
#	picture_node_instance.position_offset += (node_offset + Vector2(272, 0) + Vector2(picture_node_instance.size.x, 0)) * picture_node_index
	if picture_node_index != 0:
		picture_node_instance.position_offset = picture_node_pos + (node_offset + Vector2(239, 0) + Vector2(picture_node_instance.size.x, 0))
	
	picture_node_pos = picture_node_instance.position_offset
	
	add_child(picture_node_instance)
	picture_node_index += 1
	global_node_count += 1


func _on_picture_node_instance_dragged(from, to):
	if from == picture_node_pos:
		picture_node_pos = to


func _on_file_dialog_file_selected(path):
	save(path, json_string)
	$HBoxContainer/HBoxContainer/Label2.text = path


func _on_load_json_pressed():
	$LoadFileDialog.popup_centered()


func _on_load_file_dialog_file_selected(path):
	var script = {}
	var to
	var from
	var even_connect = false
	var node_instance
	var pic_node_dict = {}
	
	clear_nodes()
	$HBoxContainer/HBoxContainer/Label2.text = path
	
	script = load_json_file(path)
	
	frame_preset_dict = script["0"]["frame preset dict"]
	frame_preset_id = script["0"]["frame preset id"]
	
	for i in script.size():
		var dict = script[str(i)]
		
		if !dict.has_all(["type", "start picture", "end picture"]):
			$LoadFileDialog.hide()
			$LoadErrorDialog.popup_centered()
			clear_nodes()
			print("Load error 1")
			return
		
		var type = script[str(i)]["type"]
		var start_pic = script[str(i)]["start picture"]
		var end_pic = script[str(i)]["end picture"]
		
		if type == "blank":
			var dialogue_node_instance = dialogue_node.instantiate()
			
			dialogue_node_instance.connect("dragged", _on_dialogue_node_instance_dragged)
			dialogue_node_instance.connect("frame_preset_added", _on_dialogue_node_instance_frame_preset_added)
			dialogue_node_instance.connect("frame_preset_removed", _on_dialogue_node_instance_frame_preset_removed)
			
			node_instance = dialogue_node_instance
			
			dialogue_node_instance.title += " " + str(dialogue_node_index)
#			dialogue_node_instance.position_offset += (node_offset + Vector2(dialogue_node_instance.size.x, 0)) * dialogue_node_index
			
			if dialogue_node_index != 0:
				dialogue_node_instance.position_offset = dialogue_node_pos + (node_offset + Vector2(dialogue_node_instance.size.x, 0))
			
			dialogue_node_pos = dialogue_node_instance.position_offset
			
			add_child(dialogue_node_instance)
			dialogue_node_index += 1
			global_node_count += 1
		
		elif type == "text":
			var dialogue_node_instance = dialogue_node.instantiate()
			
			dialogue_node_instance.connect("dragged", _on_dialogue_node_instance_dragged)
			dialogue_node_instance.connect("frame_preset_added", _on_dialogue_node_instance_frame_preset_added)
			dialogue_node_instance.connect("frame_preset_removed", _on_dialogue_node_instance_frame_preset_removed)
			
			node_instance = dialogue_node_instance
			
			dialogue_node_instance.title += " " + str(dialogue_node_index)
#			dialogue_node_instance.position_offset += (node_offset + Vector2(dialogue_node_instance.size.x, 0)) * dialogue_node_index
			
			if dialogue_node_index != 0:
				dialogue_node_instance.position_offset = dialogue_node_pos + (node_offset + Vector2(dialogue_node_instance.size.x, 0))
			
			dialogue_node_pos = dialogue_node_instance.position_offset
			
			add_child(dialogue_node_instance)
			dialogue_node_index += 1
			global_node_count += 1
			
			if !dict.has_all(["text", "name", "speaker option", "new", "width", "auto_width"]):
				$LoadFileDialog.hide()
				$LoadErrorDialog.popup_centered()
				clear_nodes()
				print("Load error 2")
				return
			
			var text = script[str(i)]["text"]
			var speaker_name = script[str(i)]["name"]
			var speaker_option = script[str(i)]["speaker option"]
			var new = script[str(i)]["new"]
			var width = script[str(i)]["width"]
			var auto_width = script[str(i)]["auto_width"]
			
			dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").button_pressed = new
			dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/LineEdit").text = speaker_name
			dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/LineEdit").emit_signal("text_changed", speaker_name)
			dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/SpeakerOptions").selected = speaker_option
			dialogue_node_instance.get_node("VBoxContainer/TextEdit").text = text
			dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/TextWidthSpinBox").value = width
			dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/AutoWidth").button_pressed = auto_width
			dialogue_node_instance.get_node("VBoxContainer/TextEdit").emit_signal("text_changed")
			
			if new:
				if !dict.has_all(["dialogue center x", "pos x", "pos y", "paired", "lines", "auto_lines"]):
					$LoadFileDialog.hide()
					$LoadErrorDialog.popup_centered()
					clear_nodes()
					print("Load error 3")
					return
				
				var dialogue_center_x = script[str(i)]["dialogue center x"]
				var pos_x = script[str(i)]["pos x"]
				var pos_y = script[str(i)]["pos y"]
				var paired = script[str(i)]["paired"]
				var lines = script[str(i)]["lines"]
				var auto_lines = script[str(i)]["auto_lines"]
				
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer6/CenterX").button_pressed = dialogue_center_x
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer6/CenterX").emit_signal("toggled", dialogue_center_x)
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionX").value = pos_x
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionY").value = pos_y
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/LinesBox").value = lines
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/AutoLines").button_pressed = auto_lines
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/AutoLines").emit_signal("toggled", auto_lines)
				
				
				if paired:
					if !dict.has_all(["path", "paired_auto", "paired auto option", "paired pos x", "paired pos y"]):
						$LoadFileDialog.hide()
						$LoadErrorDialog.popup_centered()
						clear_nodes()
						print("Load error 4")
						return
					
					var paired_path = script[str(i)]["path"]
					var paired_auto = script[str(i)]["paired_auto"]
					var paired_auto_option = script[str(i)]["paired auto option"]
					var paired_x = script[str(i)]["paired pos x"]
					var paired_y = script[str(i)]["paired pos y"]
					
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer2/PairedAuto").button_pressed = paired_auto
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer2/PairedAutoOptions").selected = paired_auto_option
					dialogue_node_instance.get_node("FileDialog").emit_signal("file_selected", paired_path)
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer/PairedPosX").value = paired_x
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer/PairedPosY").value = paired_y
				
				else:
					if !dict.has("show frame"):
						$LoadFileDialog.hide()
						$LoadErrorDialog.popup_centered()
						clear_nodes()
						print("Load error 5")
						return
					
					var show_frame = script[str(i)]["show frame"]
					
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer4/HBoxContainer/ShowFrame").button_pressed = show_frame
					
					if show_frame:
						if !dict.has_all(["frame preset", "frame pos x", "frame pos y", "frame size x", "frame size y"]):
							$LoadFileDialog.hide()
							$LoadErrorDialog.popup_centered()
							clear_nodes()
							print("Load error 6")
							return
						
						var frame_preset = script[str(i)]["frame preset"]
						
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").selected = dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_item_index(frame_preset)
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").emit_signal("item_selected", dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_selected())
						
						if frame_preset == 0:
							var frame_pos_x = script[str(i)]["frame pos x"]
							var frame_pos_y = script[str(i)]["frame pos y"]
							var frame_size_x = script[str(i)]["frame size x"]
							var frame_size_y = script[str(i)]["frame size y"]
							
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer4/FramePosX").value = frame_pos_x
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer4/FramePosY").value = frame_pos_y
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/FrameSizeX").value = frame_size_x
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/FrameSizeY").value = frame_size_y
			
			else:
				var wipe = script[str(i)]["wipe"]
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton").button_pressed = wipe
		
		else:
			$LoadFileDialog.hide()
			$LoadErrorDialog.popup_centered()
			clear_nodes()
			print("Load error 7")
			return
		
		if start_pic:
			
			if !dict.has_all(["picture to start", "picture path", "picture pos x", "picture pos y", "center x", "picture size x", "picture size y", "keep aspect"]):
				$LoadFileDialog.hide()
				$LoadErrorDialog.popup_centered()
				clear_nodes()
				print("Load error 8")
				return
			
			var pics_to_start = script[str(i)]["picture to start"]
			var pic_paths = script[str(i)]["picture path"]
			var pic_pos_x = script[str(i)]["picture pos x"]
			var pic_pos_y = script[str(i)]["picture pos y"]
			var center_x = script[str(i)]["center x"]
			var pic_size_x = script[str(i)]["picture size x"]
			var pic_size_y = script[str(i)]["picture size y"]
			var keep_aspect = script[str(i)]["keep aspect"]
			
			for j in pics_to_start.size():
				var picture_node_instance = picture_node.instantiate()
				
				picture_node_instance.connect("dragged", _on_picture_node_instance_dragged)
				
				picture_node_instance.title += " " + str(picture_node_index)
				
				if picture_node_index != 0:
					picture_node_instance.position_offset = picture_node_pos + (node_offset + Vector2(272, 0) + Vector2(picture_node_instance.size.x, 0))
				
				picture_node_pos = picture_node_instance.position_offset
		
				add_child(picture_node_instance)
				pic_node_dict[pics_to_start[j]] = picture_node_instance
				picture_node_index += 1
				global_node_count += 1
				
				picture_node_instance.get_node("VBoxContainer/HBoxContainer2/PicturePath").text = pic_paths[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer/PosXSpinBox").value = pic_pos_x[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer/PosYSpinBox").value = pic_pos_y[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer/CenterXCheck").button_pressed = center_x[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer3/KeepAspectBox").button_pressed = keep_aspect[j]
				
				picture_node_instance.get_node("FileDialog").emit_signal("file_selected", pic_paths[j])
				await get_tree().process_frame
				picture_node_instance.get_node("VBoxContainer/HBoxContainer3/SizeXSpinBox").value = pic_size_x[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer3/SizeYSpinBox").value = pic_size_y[j]
				
				connect_node(node_instance.get_name(), 1, picture_node_instance.get_name(), 0)
		
		if end_pic:
			
			if !dict.has("picture to end"):
				$LoadFileDialog.hide()
				$LoadErrorDialog.popup_centered()
				clear_nodes()
				print("Load error 9")
				return
			
			var pics_to_end = script[str(i)]["picture to end"]
			
			for j in pics_to_end.size():
				connect_node(pic_node_dict.get(pics_to_end[j]).get_name(), 0, node_instance.get_name(), 1)
		
		if i % 2 == 0:
			if !even_connect:
				from = node_instance
			else:
				to = node_instance
				connect_node(from.get_name(), 0, to.get_name(), 0)
				from = to
				even_connect = !even_connect
		else:
			if !even_connect:
				to = node_instance
				connect_node(from.get_name(), 0, to.get_name(), 0)
				from = to
				even_connect = !even_connect
			else:
				from = node_instance


func _on_clear_nodes_pressed():
	$ConfirmationDialog.popup_centered()


func _on_confirmation_dialog_confirmed():
	clear_nodes()


func _on_clear_connections_dialog_confirmed():
	clear_connections()


func _on_quit_button_pressed():
	$QuitConfirmationDialog.popup_centered()


func _on_quit_confirmation_dialog_confirmed():
	get_tree().quit()


func _on_test_button_pressed():
#	print(get_connection_list())
	var connections = get_connection_list()
	var picture_dict = {}
	
	for i in connections.size():
		var from_node = str(get_node(str(connections[i].from)))
		var to_node = str(get_node(str(connections[i].to)))
		var from_port = connections[i].from_port
		var to_port = connections[i].to_port
		
		if from_node.contains("Picture"):
			if not picture_dict.has(from_node):
				picture_dict[from_node] = {"from": "", "to": to_node}
			else:
				picture_dict[from_node]["to"] = to_node
		if to_node.contains("Picture"):
			if not picture_dict.has(to_node):
				picture_dict[to_node] = {"from": from_node, "to": ""} 
			else:
				picture_dict[to_node]["from"] = from_node
		
		if from_port == 1 or to_port == 1:
			print(connections[i])


func _on_dialogue_node_instance_frame_preset_added(preset_name):
	for node in get_tree().get_nodes_in_group("dialogue_nodes"):
		var FramePresets = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets")
		
		if FramePresets.get_item_index(frame_preset_dict[preset_name]["id"]) == -1:
			FramePresets.add_item(preset_name, frame_preset_dict[preset_name]["id"])


func _on_dialogue_node_instance_frame_preset_removed(preset_id):
	for node in get_tree().get_nodes_in_group("dialogue_nodes"):
		var FramePresets = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets")
		
		if FramePresets.get_item_index(preset_id) != -1:
			FramePresets.remove_item(FramePresets.get_item_index(preset_id))
			FramePresets.select(0)
			FramePresets.emit_signal("item_selected", 0)
