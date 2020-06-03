extends Node2D

onready var cursor = $gauge_bar/cursor
onready var player = $player

func start():
    player.play("time_run")
    
func get_score():
    if player.get_current_animation() == "time_run":
        var pos = cursor.position.y
        if pos <= 0 or pos >= 70:
            return 0
        elif pos < 30:
            return pos/35
        elif pos >= 40:
            return (70 - pos)/35
        else: # pos in [30, 40] == bonus
            return 1.5
    else:
        return 0
    
        
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
    if anim_name == "time_out":
        player.play("time_run")
