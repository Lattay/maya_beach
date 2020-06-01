extends Sprite

signal clicked(flag)

onready var player = $AnimationPlayer
onready var clickable = $in_play_clickable

var flag_color

func set_color(color):
    player.play(color)
    flag_color = color

func _on_clicked(event) -> void:
    if event is InputEventMouseButton and event.pressed:
        emit_signal("clicked", self)

func select():
    clickable.select()

func deselect():
    clickable.deselect()
