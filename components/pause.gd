extends Node2D

var paused = false

func _process(_dt):
    # if Input.is_action_just_pressed("pause") and paused:
    #    unpause()
    pass
       
func pause():
    get_tree().paused = true
    visible = true
    paused = true
    
func unpause():
    get_tree().paused = false
    visible = false
    paused = false

func _on_dash_board_close() -> void:
    unpause()
