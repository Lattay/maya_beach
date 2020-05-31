extends KinematicBody2D

const VEL = 50
const ACC = 100

signal ask_for_target(people, prev_target)

enum State {
    IDLE,
    LEAVE_DOCK,
    GO_TO,
    FLEEING,
    SWIMING
}
var state = State.IDLE

onready var timer = $Timer

var rng = RandomNumberGenerator.new()

var velocity = Vector2.ZERO


var target

func _process(dt: float) -> void:
    match state:
        State.GO_TO:
            if get_global_position().distance_to(target) < 20:
                state = State.IDLE
            
func _physics_process(delta: float) -> void:
    match state:
        State.LEAVE_DOCK, State.GO_TO:
            velocity = velocity.move_toward(
                VEL * (target - get_global_position()).normalized(),
                delta * ACC
            )
            rotation = 0.7 * rotation + 0.3 * Vector2.UP.angle_to(velocity)
            velocity = move_and_slide(velocity)
        _:
            pass


func _on_Area2D_area_entered(area: Area2D) -> void:
    if state == State.LEAVE_DOCK and area.name == "end":
        state = State.IDLE
        target = get_global_position()
        ask_target()
        
func get_random_target():
    return Vector2(500, 300)

func _on_timeout() -> void:
    ask_target()

func ask_target():
    emit_signal("ask_for_target", self, target)

func set_target(new_target):
    timer.set_wait_time(rng.randf_range(4, 15))
    timer.start()
    state = State.GO_TO
    target = new_target


func leave_dock(pos):
    target = pos
    state = State.LEAVE_DOCK
