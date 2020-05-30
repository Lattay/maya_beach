extends KinematicBody2D

const ACC = 100
const VEL = 10

signal go_to_deck(boat)
signal leave_deck(boat)

enum State {
    MOVING,
    TRACKING,
    WAITING_FOR_SLOT,
    WAITING_TO_LEAVE
}
var state = State.TRACKING

var velocity = Vector2.ZERO

var target

func wait_user():
    # enable waiting for player input
    state = State.WAITING
    
func go_to_deck(deck):
    state = State.MOVING
    target = deck.get_free_anchor()

func _physics_process(dt):
    match state:
        State.MOVING:
            rotation += 10 * dt * (velocity.angle() - rotation)
            velocity = move_and_slide(velocity)
            velocity = velocity.move_toward(VEL * (target.position - position).normalized(), ACC * dt)
        State.WAITING_FOR_SLOT, State.WAITIN_TO_LEAVE:
            velocity = move_and_slide(velocity)
            velocity = velocity.move_toward(-0.1 * position, 10 * dt * ACC)
        State.TRACKING:
            velocity = move_and_slide(velocity)
            velocity = velocity.move_toward(-0.1 * position, 10 * dt * ACC)
            


func _on_clicked(event) -> void:
    match state:
        State.WAITING_FOR_SLOT:
            state = State.MOVING
            emit_signal("go_to_deck", self)
        State.WAITING_TO_LEAVE:
            state = State.MOVING
            emit_signal("leave_deck", self)
