extends Node2D

var paused = false

enum {
    SHOP,
    PAUSE,
    END,
}

var pause_type = PAUSE

onready var dash_board = $dash_board
onready var end_screen = $end_screen
onready var pause_screen = $pause_screen

func _process(_dt):
    if Input.is_action_just_pressed("cancel") and paused:
       unpause()
       
func pause(type):
    get_tree().paused = true
    visible = true
    paused = true
    pause_type = type
    show_screen(pause_type)
    
func unpause():
    get_tree().paused = false
    visible = false
    paused = false

func _on_dash_board_close() -> void:
    unpause()

func show_screen(type):
    dash_board.visible = type == SHOP
    end_screen.visible = type == END
    pause_screen.visitble = type == PAUSE
