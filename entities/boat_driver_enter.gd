extends Position2D

onready var player: AnimationPlayer = $AnimationPlayer
var is_free = true
var tracked_boat = null

func start(boat):
    is_free = false
    tracked_boat = boat
    player.play("enter")

func reset():
    tracked_boat = null
    player.seek(0, true)
    is_free = true
