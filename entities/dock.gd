extends Node2D

signal clicked_when_free(dock)

enum DockSize { BIG, SMALL }

export(DockSize) var dock_size = DockSize.SMALL
var is_free: Array = []
var anchors = []
onready var clickable = $in_play_clickable
onready var exit = $exit

func _ready():
    if dock_size == DockSize.SMALL:
        is_free = [true]
        anchors = [$anchor]
    else:
        is_free = [true, true]
        anchors = [$anchor_left, $anchor_right]

    var i = 0
    for anc in anchors:
        anc.dock_index = i
        i += 1

func is_small():
    return dock_size == DockSize.SMALL

func dock_out():
    return exit

func free_anchor(i):
    is_free[i] = true
    
func has_free_anchor():
    return is_free.find(true) != -1

func reserve_free_anchor():
    match dock_size:
        DockSize.SMALL:
            if is_free[0]:
                is_free[0] = false
                return anchors[0]
            else:
                return null
        DockSize.BIG:
            if is_free[0]:
                is_free[0] = false
                return anchors[0]
            elif is_free[1]:
                is_free[1] = false
                return anchors[1]
            else:
                return null                

func _on_clicked(_event) -> void:
    if has_free_anchor():
        emit_signal("clicked_when_free", self)

func select():
    clickable.select()

func deselect():
    clickable.deselect()
