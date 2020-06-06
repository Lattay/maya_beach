extends Node2D

onready var sprite = $Sprite
var enabled = true
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
    if event is InputEventMouseButton and event.pressed:
        emit_signal("clicked", event)


func _on_focus_exited() -> void:
    if show_hover and enabled and not selected:
        sprite.set_visible(false)

func _on_focus_entered() -> void:
    if show_hover and enabled:
        sprite.set_visible(true)
