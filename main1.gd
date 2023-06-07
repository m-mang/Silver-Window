extends Node

var dialogue_script_index = 0
var dialogue_window = preload("res://dialogue_window.tscn")
var picture_window = preload("res://picture_window.tscn")
var window
var old_box
var paired_window
var active_pictures = {}

@onready var SpeakerFrame = $SpeakerFrame
@onready var SpeakerName = $SpeakerName
@onready var FrameLineControl = $FrameLineControl

# Called when the node enters the scene tree for the first time.
func _ready():
#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	await $StartDelayTimer.timeout
	next_dialogue()


func next_dialogue():
	var type = StaticData.dialogue_script[str(dialogue_script_index)]["type"]
	var start_pic = StaticData.dialogue_script[str(dialogue_script_index)]["start picture"]
	var end_pic = StaticData.dialogue_script[str(dialogue_script_index)]["end picture"]
	
	if type == "text":
		var speaker_name = StaticData.dialogue_script[str(dialogue_script_index)]["name"]
		var text = StaticData.dialogue_script[str(dialogue_script_index)]["text"]
		var new_box = StaticData.dialogue_script[str(dialogue_script_index)]["new"]
		
		
		if new_box:
			var width = StaticData.dialogue_script[str(dialogue_script_index)]["width"]
			var pos_x = StaticData.dialogue_script[str(dialogue_script_index)]["pos x"]
			var pos_y = StaticData.dialogue_script[str(dialogue_script_index)]["pos y"]
			var paired = StaticData.dialogue_script[str(dialogue_script_index)]["paired"]
			var lines = StaticData.dialogue_script[str(dialogue_script_index)]["lines"]
			
			var dialogue_window_instance = dialogue_window.instantiate()
			var Dialogue = dialogue_window_instance.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue")
			
			if end_pic:
				var pic_to_end = StaticData.dialogue_script[str(dialogue_script_index)]["picture to end"]
				
				for i in pic_to_end.size():
					active_pictures.get(pic_to_end[i]).get_child(0).shrink()
					active_pictures.erase(pic_to_end[i])
			
			if paired_window != null:
				paired_window.get_child(0).shrink()
			
			if window != null:
			#	if SpeakerName.is_visible_in_tree():
				SpeakerName.reset()
				if SpeakerFrame.is_visible_in_tree():
					SpeakerFrame.reset()
				window.get_child(0).shrink()
				await window.tree_exited
			
			window = dialogue_window_instance
			old_box = Dialogue
			
			Dialogue.dialogue_finished.connect(_on_Dialogue_dialogue_finished)
			
			dialogue_window_instance.position = Vector2(pos_x, pos_y)
			Dialogue.text = text
			Dialogue.dialogue_width = width
			Dialogue.lines = lines
			
			add_child(dialogue_window_instance)
			
			if paired:
				var texture_path = StaticData.dialogue_script[str(dialogue_script_index)]["path"]
				var picture_pos_x = StaticData.dialogue_script[str(dialogue_script_index)]["paired pos x"]
				var picture_pos_y = StaticData.dialogue_script[str(dialogue_script_index)]["paired pos y"]
				var paired_auto_option = StaticData.dialogue_script[str(dialogue_script_index)]["paired auto option"]
				var speaker_option = StaticData.dialogue_script[str(dialogue_script_index)]["speaker option"]
				
				var picture_window_instance = picture_window.instantiate()
				var PictureRect = picture_window_instance.get_node("ExpandShrinkContainer/PictureContainer/Control/PictureRect")
				
				paired_window = picture_window_instance
				PictureRect.texture = load(texture_path)
				
				add_child(picture_window_instance)
				
				picture_window_instance.z_index = 1
				picture_window_instance.position = Vector2(picture_pos_x, picture_pos_y)
				
				if paired_auto_option == 0 or paired_auto_option == 1:
					picture_window_instance.position.y = dialogue_window_instance.position.y - (picture_window_instance.get_child(0).size.y - dialogue_window_instance.get_child(0).size.y)
				
				SpeakerFrame.show()
				SpeakerFrame.size = picture_window_instance.get_child(0).size + Vector2(14, 14)
				SpeakerFrame.position = picture_window_instance.position - Vector2(7, 7)
				SpeakerFrame.pulse()
				
				FrameLineControl.move_to_frame()
				
				SpeakerName.text = speaker_name
				SpeakerName.reset_size()
				
				if speaker_option == 0:
					SpeakerName.position = SpeakerFrame.position - Vector2(0, SpeakerName.size.y)
				elif speaker_option == 1:
					SpeakerName.position = SpeakerFrame.position + Vector2(0, SpeakerFrame.size.y)
				elif speaker_option == 2:
					SpeakerName.position = SpeakerFrame.position + Vector2(-(SpeakerName.size.x + 10), (SpeakerFrame.size.y / 2) - (SpeakerName.size.y / 2))
				elif speaker_option == 3:
					SpeakerName.position = SpeakerFrame.position + Vector2(SpeakerFrame.size.x + 10, (SpeakerFrame.size.y / 2) - (SpeakerName.size.y / 2))
				
				SpeakerName.begin()
				
			else:
				var show_frame = StaticData.dialogue_script[str(dialogue_script_index)]["show frame"]
				
				if show_frame:
				
					var frame_size_x = StaticData.dialogue_script[str(dialogue_script_index)]["frame size x"]
					var frame_size_y = StaticData.dialogue_script[str(dialogue_script_index)]["frame size y"]
					var frame_pos_x = StaticData.dialogue_script[str(dialogue_script_index)]["frame pos x"]
					var frame_pos_y = StaticData.dialogue_script[str(dialogue_script_index)]["frame pos y"]
					var speaker_pos_x = StaticData.dialogue_script[str(dialogue_script_index)]["speaker pos x"]
					var speaker_pos_y = StaticData.dialogue_script[str(dialogue_script_index)]["speaker pos y"]
					
					SpeakerFrame.show()
					SpeakerFrame.size = Vector2(frame_size_x, frame_size_y)
					SpeakerFrame.position = Vector2(frame_pos_x, frame_pos_y)
					SpeakerFrame.pulse()
					
					FrameLineControl.move_to_frame()
					
					SpeakerName.text = speaker_name
					SpeakerName.reset_size()
					SpeakerName.position = Vector2(speaker_pos_x, speaker_pos_y)
					SpeakerName.begin()
			
		else:
			# Reuse the old box and just update the text.
			var wipe = StaticData.dialogue_script[str(dialogue_script_index)]["wipe"]
			
			if wipe:
				window.get_node("ExpandShrinkContainer/DialogueContainer/BoxWipeContainer").box_wipe_vertical(text)
			else:
				window.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue").add_to_next_line(text)
			
			window.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue").allow_input = true
	
	
	elif type == "blank":
		var dialogue_window_instance = dialogue_window.instantiate()
		var Dialogue = dialogue_window_instance.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue")
		
		if end_pic:
			var pic_to_end = StaticData.dialogue_script[str(dialogue_script_index)]["picture to end"]
			
			for i in pic_to_end.size():
				active_pictures.get(pic_to_end[i]).get_child(0).shrink()
				active_pictures.erase(pic_to_end[i])
		
		if paired_window != null:
			paired_window.get_child(0).shrink()

		if window != null:
		#	if SpeakerName.is_visible_in_tree():
			SpeakerName.reset()
			if SpeakerFrame.is_visible_in_tree():
				SpeakerFrame.reset()
			window.get_child(0).shrink()
			await window.tree_exited
		
		window = dialogue_window_instance
		old_box = Dialogue
		Dialogue.blank = true
		Dialogue.text = ""
		Dialogue.dialogue_finished.connect(_on_Dialogue_dialogue_finished)
		add_child(dialogue_window_instance)
		dialogue_window_instance.hide()
	
	if start_pic:
		var pic_to_start = StaticData.dialogue_script[str(dialogue_script_index)]["picture to start"]
		var pic_path = StaticData.dialogue_script[str(dialogue_script_index)]["picture path"]
		var pic_pos_x = StaticData.dialogue_script[str(dialogue_script_index)]["picture pos x"]
		var pic_pos_y = StaticData.dialogue_script[str(dialogue_script_index)]["picture pos y"]
		var _pic_size_x = StaticData.dialogue_script[str(dialogue_script_index)]["picture size x"]
		var _pic_size_y = StaticData.dialogue_script[str(dialogue_script_index)]["picture size y"]
		
		for i in pic_to_start.size():
			var picture_window_instance = picture_window.instantiate()
			var PictureMarginContainer = picture_window_instance.get_child(0)
			var PictureRect = picture_window_instance.get_node("ExpandShrinkContainer/PictureContainer/Control/PictureRect")
			
			PictureMarginContainer.position = Vector2(pic_pos_x[i], pic_pos_y[i])
			PictureRect.texture = load(pic_path[i])
		#	PictureRect.size = Vector2(pic_size_x[i], pic_size_y[i])
			
			add_child(picture_window_instance)
			active_pictures[pic_to_start[i]] = picture_window_instance


func _on_Dialogue_dialogue_finished():
	dialogue_script_index += 1
	
	if dialogue_script_index <= StaticData.dialogue_script.size() - 1:
		next_dialogue()
	
	else:
	#	if SpeakerName.is_visible_in_tree():
		SpeakerName.reset()
		if SpeakerFrame.is_visible_in_tree():
			SpeakerFrame.reset()
		window.get_child(0).shrink()
		
		if paired_window != null:
			paired_window.get_child(0).shrink()
		
		if not active_pictures.is_empty():
			for key in active_pictures:
				active_pictures.get(key).get_child(0).shrink()
