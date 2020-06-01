extends Area2D

onready var sprite = $Sprite
var enabled = true
var selected = false

signal clicked(event)

func _on_mouse_entered() -> void:
    if enabled:
        sprite.set_visible(true)

func select():
    selected = true
    sprite.set_visible(true)

func deselect():
    selected = false
    sprite.set_visible(false)

func _on_mouse_exited() -> void:
    if enabled and !selected:
        sprite.set_visible(false)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    emit_signal("clicked", event)
