extends Node2D

enum DockSize { BIG, SMALL }

export(DockSize) var dock_size = DockSize.SMALL
var is_free: Array = []
var anchors = []

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

func free_anchor(i):
    is_free[i] = true
    
func has_free_anchor():
    return is_free.find(true) != -1

func reserve_free_anchor():
    match dock_size:
        DockSize.SMALL:
            if is_free:
                return anchors[0]
            else:
                return null
        DockSize.BIG:
            if is_free[0]:
                return anchors[0]
            elif is_free[1]:
                return anchors[1]
            else:
                return null                

func _on_clicked(_event) -> void:
    pass # Replace with function body.
