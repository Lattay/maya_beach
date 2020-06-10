extends Node

const Flag = preload("res://entities/flag.tscn")
var flags = []

func spawn_flag(start_pos, color, strength):
    var new_flag = Flag.instance()
    new_flag.set_strength(strength)
    add_child(new_flag)
    flags.append(new_flag)
    new_flag.set_global_position(start_pos)
    new_flag.set_color(color)
    return new_flag

func _process(dt):
    var i = 0
    for flag in flags:
        var target = Vector2.UP * 40 * i
        var delta = (target - flag.position)
        if target.distance_squared_to(flag.position) > 400:
            flag.position += 4 * delta * dt
        else:
            flag.position = target
            if not flag.has_gauge:
                flag.add_gauge()
        i += 1

func drop_flag(flag):
    flags.erase(flag)
    var score = flag.drop_gauge()
    remove_child(flag)
    return score
    
func _on_boat_leave_on_time_out(flag):
    drop_flag(flag)
