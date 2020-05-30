extends Position2D

onready var player: AnimationPlayer = $AnimationPlayer
var is_free = true

func start():
    is_free = false
    player.play("enter")

func reset():
    player.seek(0)
