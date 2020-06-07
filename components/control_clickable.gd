extends Node2D

onready var sprite = $Sprite
export(bool) var enabled = true
var selected = false
export(bool) var show_hover = false

signal clicked(event)

func _ready():
    sprite.set_visible(false)

func select():
    selected = true
    sprite.set_visible(true)

func deselect():
    selected = false
    sprite.set_visible(false)

func _on_input_event(event: InputEvent) -> void:
    if enabled and event is InputEventMouseButton and event.pressed:
        emit_signal("clicked", event)


func _on_focus_exited() -> void:
    if enabled and show_hover and not selected:
        sprite.set_visible(false)

func _on_focus_entered() -> void:
    if enabled and show_hover:
        sprite.set_visible(true)
