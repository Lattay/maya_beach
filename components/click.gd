extends Node

enum {
    NOTHING,
    SENDING_BOAT_TO_DOCK,
    SENDING_FLAG_TO_BOAT,
    DEFORESTATING,
}

onready var flag_container = $"../flags"

var state = NOTHING
var selected_boat = null
var selected_flag = null

func _on_click_on_waiting_boat(boat):
    match state:
        NOTHING:
            boat.select()
            selected_boat = boat
            state = SENDING_BOAT_TO_DOCK
        SENDING_BOAT_TO_DOCK:
            if boat == selected_boat:
                selected_boat.deselect()
                selected_boat = null
                state = NOTHING
            else:
                selected_boat.deselect()
                boat.select()
                selected_boat = boat

        _:
            pass

func _on_click_on_docked_boat(boat):
    match state:
        SENDING_FLAG_TO_BOAT:
            selected_flag.deselect()
            state = NOTHING
            flag_container.drop_flag(selected_flag)
            boat.raise_flag(selected_flag)
            selected_flag = null
        _:
            pass

func _on_click_on_flag(flag):
    match state:
        NOTHING:
            selected_flag = flag
            state = SENDING_FLAG_TO_BOAT
            flag.select()
        SENDING_FLAG_TO_BOAT:
            if selected_flag == flag:
                selected_flag.deselect()
                selected_flag = null
                state = NOTHING
            else:
                selected_flag.deselect()
                flag.select()
                selected_flag = flag
        _:
            pass

func _on_click_on_dock(dock):
    match state:
        SENDING_BOAT_TO_DOCK:
            selected_boat.deselect()
            selected_boat.go_to_dock(dock)
            selected_boat = null
            state = NOTHING
        _:
            pass
