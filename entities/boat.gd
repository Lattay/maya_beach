extends KinematicBody2D

export var max_speed = 200
export var rot_gain = 5
export var accel = 100

# state changes
signal go_to_dock(boat)
signal reached_dock(boat, dock)
signal disembark(boat, dock, people)
signal raised_flag(boat, dock, flag)
signal leave_dock(boat, dock, anchor)
signal leave_screen(boat)
signal leave_on_time_out(flag)

# input
signal clicked_when_waiting_for_dock(boat)
signal clicked_when_docked(boat)

onready var timer = $Timer
onready var gauge = $Sprite2/gauge
onready var clickable = $in_play_clickable


const Couple = preload("res://entities/couple.tscn")

enum State {
    TRACKING,
    WAITING_FOR_SLOT,
    MOVE_TO_DOCK
    DOCKED,
    RAISING_FLAG,
    WAITING_FOR_PEOPLE,
    LEAVE,
}
var state = State.TRACKING

var velocity = Vector2.ZERO

var target
var flag_color
var way_out

var attached_dock = null
var attached_anchor = 0

var raised_flag
var group_score

enum {
    DISEMBARKING,
    WAITING,
    EMBARKING
}
var docked_phase = DISEMBARKING
export(int) var capacity = 10
onready var on_board = capacity

func wait_for_slot():
    # enable waiting for player input
    state = State.WAITING_FOR_SLOT
    target = get_global_position()
    
func go_to_dock(dock):
    emit_signal("go_to_dock", self)
    state = State.MOVE_TO_DOCK
    var anchor = dock.reserve_free_anchor()
    target = anchor.get_global_position()
    attached_dock = dock
    attached_anchor = anchor.dock_index
    
func get_attached_anchor_index():
    return attached_anchor
    
func _ready():
    update_gauge()

func set_flag_color(color):
    flag_color = color
    
func set_score(score):
    group_score = score

func set_way_out(obj):
    way_out = obj

func _process(_dt):
    if target is Vector2 and get_global_position().distance_squared_to(target) < 30:
        match state:
            State.MOVE_TO_DOCK:
                dock()
            State.LEAVE:
                emit_signal("leave_screen", self)
            _:
                pass

func _physics_process(dt):
    match state:
        State.WAITING_FOR_SLOT, State.DOCKED, \
        State.WAITING_FOR_PEOPLE, State.LEAVE, \
        State.MOVE_TO_DOCK:
            move_global_to(dt, target)
        State.TRACKING:
            move_local_to(dt, Vector2.ZERO)
            
func dock():
    state = State.DOCKED
    target = get_global_position()
    disembark_people()
    emit_signal("reached_dock", self, attached_dock)
    

func move_global_to(dt, pos):
    var glob_pos = get_global_position()
    if glob_pos.is_equal_approx(pos):
        return
        
    var speed
    if state == State.LEAVE:
        speed = 3 * max_speed
        rotation -= 3 * rot_gain * dt * simple_angle(
            Vector2.LEFT.angle_to(Vector2.UP)
            + rotation
            - glob_pos.angle_to_point(pos)
        )
    else:
        rotation -= rot_gain * dt * simple_angle(
            Vector2.LEFT.angle_to(Vector2.UP)
            + rotation
            - glob_pos.angle_to_point(pos)
        )
        speed = min(max_speed, 4 * glob_pos.distance_to(pos))
    velocity = velocity.move_toward(Vector2.UP.rotated(rotation) * speed, dt * accel * 10)
    velocity = move_and_slide(velocity)

func move_local_to(dt, pos):
    if position.is_equal_approx(pos):
        return
    rotation -= 5 * dt * simple_angle(
        Vector2.LEFT.angle_to(Vector2.UP)
        + rotation
        - position.angle_to_point(pos)
    )
    var speed = min(max_speed, position.distance_to(pos))
    velocity = velocity.move_toward(Vector2.UP.rotated(rotation) * speed, dt * accel * 10)
    velocity = move_and_slide(velocity)

func simple_angle(angle):
    while angle > PI:
        angle -= 2 * PI
    while angle < -PI:
        angle += 2 * PI
    return angle

func _on_clicked(_event) -> void:
    match state:
        State.WAITING_FOR_SLOT:
            emit_signal("clicked_when_waiting_for_dock", self)
        State.DOCKED:
            if on_board == 0:
                emit_signal("clicked_when_docked", self)
        _:
            pass

func _on_Timer_timeout() -> void:
    disembark_people()

func disembark_people():
    if docked_phase == DISEMBARKING and on_board > 0:
        var people = Couple.instance()
        on_board -= people.quantity
        update_gauge()
        emit_signal("disembark", self, attached_dock, people)
        
        if on_board > 0:
            timer.start()
        else:
            timer.stop()
            docked_phase = WAITING
        

func update_gauge():
    gauge.set_current_animation("gauge")
    gauge.seek(0.1 * ceil(on_board/2), true)

func embark(people):
    on_board += people.quantity
    people.queue_free()
    update_gauge()
    if on_board >= capacity:
        leave()

func select():
    clickable.select()

func deselect():
    clickable.deselect()

func raise_flag(flag):
    add_child(flag)
    flag_color = flag.flag_color
    flag.position = Vector2(15, -30)
    flag.scale *= 0.7
    state = State.WAITING_FOR_PEOPLE
    docked_phase = EMBARKING
    raised_flag = flag
    emit_signal("raised_flag", self, attached_dock, flag_color)

func leave():
    emit_signal("leave_dock", self, attached_dock, attached_anchor, group_score)
    state = State.LEAVE
    target = way_out.get_global_position()

func _on_time_out(flag):
    if state == State.WAITING_FOR_SLOT:
        attached_dock = null
        attached_anchor = null
        group_score = 0
        leave()
        emit_signal("leave_on_time_out", flag)
