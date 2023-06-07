extends Control

signal frame_lines_finished

@export var tween_frames = 20
@export var frame_lines = true

var tween
var left_start
var right_start
var top_start
var bottom_start
var fade_out_frames = 10

@onready var SpeakerFrame = $"../SpeakerFrame"

func _ready():
	left_start = $FrameLineL.position
	right_start = $FrameLineR.position
	top_start = $FrameLineT.position
	bottom_start = $FrameLineB.position


func move_to_frame():
	if !frame_lines:
		return
	
	var tween_time = tween_frames / 60.0
	var fade_out_time = fade_out_frames / 60.0
	
	var left_final = Vector2(SpeakerFrame.position.x, 0)
	var right_final = Vector2(SpeakerFrame.position.x + SpeakerFrame.size.x, 0)
	var top_final = Vector2(0, SpeakerFrame.position.y)
	var bottom_final = Vector2(0, SpeakerFrame.position.y + SpeakerFrame.size.y)
	
	show()
	tween = get_tree().create_tween()
	tween.set_parallel()
	
	tween.tween_property($FrameLineL, "position", left_final, tween_time)
	tween.tween_property($FrameLineR, "position", right_final, tween_time)
	tween.tween_property($FrameLineT, "position", top_final, tween_time)
	tween.tween_property($FrameLineB, "position", bottom_final, tween_time)
	
	await tween.finished
	
	tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel()
	
	tween.tween_property($FrameLineL, "self_modulate", Color("ffffff00"), fade_out_time)
	tween.tween_property($FrameLineR, "self_modulate", Color("ffffff00"), fade_out_time)
	tween.tween_property($FrameLineT, "self_modulate", Color("ffffff00"), fade_out_time)
	tween.tween_property($FrameLineB, "self_modulate", Color("ffffff00"), fade_out_time)
	
	await tween.finished
	hide()
	
	$FrameLineL.self_modulate = Color("ffffff")
	$FrameLineR.self_modulate = Color("ffffff")
	$FrameLineT.self_modulate = Color("ffffff")
	$FrameLineB.self_modulate = Color("ffffff")
	
	$FrameLineL.position = left_start
	$FrameLineR.position = right_start
	$FrameLineT.position = top_start
	$FrameLineB.position = bottom_start
	
	emit_signal("frame_lines_finished")
