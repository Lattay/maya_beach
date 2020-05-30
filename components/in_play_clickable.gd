extends Area2D

onready var sprite = $Sprite
var enabled = true

signal clicked(event)

func _on_mouse_entered() -> void:
    if enabled:
        sprite.set_visible(true)



func _on_mouse_exited() -> void:
    if enabled:
        sprite.set_visible(false)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    emit_signal("clicked", event)
