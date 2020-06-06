extends Node2D

var paused = false

func _process(_dt):
    if Input.is_action_just_pressed("pause"):
        if paused:
            get_tree().paused = false
            visible = false
            paused = false
        else:
            get_tree().paused = true
            visible = true
            paused = true
