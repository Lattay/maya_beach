extends Node2D

const Gauge = preload("res://entities/gauge.tscn")

signal clicked(flag)

onready var clickable = $in_play_clickable
onready var sprite = $sprite

var flag_color
var has_gauge = false

func set_color(color):
    flag_color = color
    sprite.modulate = color

func _on_clicked(_event) -> void:
    if has_gauge:
        emit_signal("clicked", self)

func select():
    clickable.select()

func deselect():
    clickable.deselect()

func add_gauge():
    var gauge = Gauge.instance()
    gauge.position = Vector2.LEFT * 25 + Vector2.UP * 10
    add_child(gauge)
    gauge.start()
    has_gauge = true
    
func drop_gauge():
    var gauge = get_node("gauge")
    var score = gauge.get_score()
    remove_child(gauge)
    gauge.queue_free()
    has_gauge = false
    return score
