extends KinematicBody2D

export(int) var speed = 200
export(int) var accel = 300
export(float) var concentration_min = 1
export(float) var concentration_max = 3
export(float, 0, 1) var angular_momentum = 0.5
export(int, 1, 3) var quantity = 1

signal ask_for_target(people, prev_target)
signal set_color(color)

enum State {
    IDLE,
    LEAVE_DOCK,
    GO_TO,
    FLEEING,
    GO_BACK_TO_DOCK,
    SWIMING
}
var state = State.IDLE
var group_color = "blue"

onready var timer = $Timer
onready var player = $player

var rng = RandomNumberGenerator.new()

var velocity = Vector2.ZERO


var target
var target_boat

func _process(_dt: float) -> void:
    match state:
        State.GO_TO:
            if get_global_position().distance_to(target) < 20:
                state = State.IDLE
        State.GO_BACK_TO_DOCK:
            if get_global_position().distance_squared_to(target_boat.get_global_position()) < 100:
                target_boat.embark(self)
            
func _physics_process(delta: float) -> void:
    match state:
        State.LEAVE_DOCK, State.GO_TO, State.GO_BACK_TO_DOCK:
            velocity = velocity.move_toward(
                speed * (target - get_global_position()).normalized(),
                delta * accel
            )
            rotation = angular_momentum * rotation + (1 - angular_momentum) * Vector2.UP.angle_to(velocity)
            velocity = move_and_slide(velocity)
        _:
            pass


func _on_Area2D_area_entered(area: Area2D) -> void:
    if state == State.LEAVE_DOCK and area.name == "end":
        state = State.IDLE
        target = get_global_position()
        ask_target()
    if state == State.GO_BACK_TO_DOCK and area.name == "end":
        target = target_boat.get_global_position()
        
func get_random_target():
    return Vector2(500, 300)

func _on_timeout() -> void:
    if state == State.GO_TO or state == State.IDLE:
        ask_target()
    else:
        timer.stop()

func ask_target():
    emit_signal("ask_for_target", self, target)

func set_target(new_target):
    if state == State.GO_TO or state == State.IDLE:
        timer.set_wait_time(rng.randf_range(concentration_min, concentration_max))
        timer.start()
        state = State.GO_TO
        target = new_target


func leave_dock(pos):
    target = pos
    state = State.LEAVE_DOCK

func set_color(color):
    group_color = color
    emit_signal("set_color", color)
    
func call_back(boat, dock):
    state = State.GO_BACK_TO_DOCK
    target = dock.get_node("target").get_global_position()
    target_boat = boat
