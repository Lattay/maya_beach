extends Node

enum {
    NOTHING,
    DRAGGING_BOAT_TO_DOCK,
    DRAGGING_FLAG_TO_BOAT,
    DEFORESTATING,
}

var state = NOTHING
var dragging_boat = null
var dragging_flag = null

func _on_drag_to_dock(boat):
    if state == NOTHING:
        print("catch boat")
        dragging_boat = boat
        state = DRAGGING_BOAT_TO_DOCK

func _on_drag_flag_to_boat(flag):
    if state == NOTHING:
        dragging_flag = flag
        state = DRAGGING_FLAG_TO_BOAT

func _on_release_on_dock(dock):
    if state == DRAGGING_BOAT_TO_DOCK:
        if dock.has_free_anchor():
            dragging_boat.go_to_dock(dock)
        state = NOTHING

func _on_release_on_boat(boat):
    if state == DRAGGING_FLAG_TO_BOAT:
        if boat.on_board == 0:
            boat.attach_flag(dragging_flag)
            dragging_boat.call_group()

func _process(_dt):
    pass
