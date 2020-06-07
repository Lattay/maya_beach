extends Node2D

var paused = false

enum {
    SHOP,
    PAUSE,
    DIALOG,
}

var pause_type = PAUSE

onready var dash_board = $dash_board
onready var dialog_screen = $dialog_screen
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

func show_screen(type):
    dash_board.visible = type == SHOP
    dialog_screen.visible = type == DIALOG
    pause_screen.visible = type == PAUSE

func _on_dash_board_close() -> void:
    unpause()

func _on_pause_screen_close() -> void:
    unpause()

func _on_dialog_screen_close() -> void:
    unpause()
