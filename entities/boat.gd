extends KinematicBody2D

const ACC = 100
const VEL = 150

signal go_to_dock(boat)
signal leave_dock(boat, dock)
signal reached_dock(boat, dock)
signal leave_screen(boat)
signal disembark(boat, dock, people)

onready var timer = $Timer
onready var gauge = $Sprite2/gauge

const Couple = preload("res://entities/couple.tscn")

enum State {
    MOVING,
    TRACKING,
    WAITING_FOR_SLOT,
    WAITING_TO_LEAVE,
    DOCKED
}
var state = State.TRACKING

var velocity = Vector2.ZERO

var target

var attached_dock = null
var attached_anchor = 0

var docked_phase = "disembarking"
var on_board = 10

func wait_for_slot():
    # enable waiting for player input
    state = State.WAITING_FOR_SLOT
    target = get_global_position()
    
func go_to_dock(dock):
    state = State.MOVING
    var anchor = dock.reserve_free_anchor()
    target = anchor.get_global_position()
    attached_dock = dock
    attached_anchor = anchor.dock_index
    
func get_attached_anchor_index():
    return attached_anchor
    
func _ready():
    update_gauge()

func _process(_dt):
    match state:
        State.MOVING:
            if position.is_equal_approx(target):
                dock()
        State.DOCKED:
            if docked_phase == "disembarking" and on_board == 0:
                docked_phase = "embarking"
        _:
            pass

func _physics_process(dt):
    match state:
        State.MOVING:
            move_global_to(dt, target)
        State.WAITING_FOR_SLOT, State.WAITING_TO_LEAVE, State.DOCKED:
            move_global_to(dt, target)
        State.TRACKING:
            move_local_to(dt, Vector2.ZERO)
            
func dock():
    state = State.DOCKED
    timer.start()
    target = get_global_position()
    emit_signal("reached_dock", self, attached_dock)            

func move_global_to(dt, pos):
    var glob_pos = get_global_position()
    if glob_pos.is_equal_approx(pos):
        return
    rotation -= 5 * dt * (
        Vector2.LEFT.angle_to(Vector2.UP)
        + rotation
        - glob_pos.angle_to_point(pos)
    )
    var speed = min(VEL, 4 * glob_pos.distance_to(pos))
    velocity = velocity.move_toward(Vector2.UP.rotated(rotation) * speed, dt * ACC * 10)
    velocity = move_and_slide(velocity)

func move_local_to(dt, pos):
    if position.is_equal_approx(pos):
        return
    rotation -= 5 * dt * (
        Vector2.LEFT.angle_to(Vector2.UP)
        + rotation
        - position.angle_to_point(pos)
    )
    var speed = min(VEL, position.distance_to(pos))
    velocity = velocity.move_toward(Vector2.UP.rotated(rotation) * speed, dt * ACC * 10)
    velocity = move_and_slide(velocity)

func _on_clicked(event) -> void:
    if event is InputEventMouseButton && event.pressed:
        match state:
            State.WAITING_FOR_SLOT:
                state = State.MOVING
                emit_signal("go_to_dock", self)
            State.WAITING_TO_LEAVE:
                state = State.MOVING
                emit_signal("leave_dock", self, attached_dock)

func _on_Timer_timeout() -> void:
    if on_board > 0:
        var people = Couple.instance()
        on_board -= 2
        update_gauge()
        emit_signal("disembark", self, attached_dock, people)
        timer.start()

func update_gauge():
    gauge.set_current_animation("gauge")
    gauge.seek(0.1 * ceil(on_board/2), true)