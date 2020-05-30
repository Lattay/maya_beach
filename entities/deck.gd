extends Node2D

enum DeckSize { BIG, SMALL }

export(DeckSize) var deck_size = DeckSize.SMALL
var is_free: Array = []
var anchors = []

func _ready():
    if deck_size == DeckSize.SMALL:
        is_free = [true]
        anchors = [$anchor]
    else:
        is_free = [true, true]
        anchors = [$anchor_left, $anchor_right]
        
func set_free(i):
    is_free[i] = true
    
func is_free():
    return is_free.find(true) != -1

func get_free_anchor():
    match deck_size:
        DeckSize.SMALL:
            if is_free:
                return anchors[0]
            else:
                return null
        DeckSize.BIG:
            if is_free[0]:
                return anchors[0]
            elif is_free[1]:
                return anchors[1]
            else:
                return null                

func _on_clicked(event) -> void:
    pass # Replace with function body.
