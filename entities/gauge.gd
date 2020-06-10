extends Node2D

signal time_out

enum {
    EASY = 0,
    MEDIUM = 1,
    HARD = 2
}

const size = Vector2(215, 30)

onready var gauge_bar = $gauge_bar
onready var cursor = $gauge_bar/cursor
onready var player = $player
export var score_strength = EASY setget set_strength
export(float) var speed = 0.7


func set_strength(strength):
    score_strength = strength
    match score_strength:
        EASY:
            gauge_bar.region_rect = Rect2(Vector2(40, 0), size)
        MEDIUM:
            gauge_bar.region_rect = Rect2(Vector2(40, 32), size)
        HARD:
            gauge_bar.region_rect = Rect2(Vector2(42, 65), size)

func start():
    player.play("time_run", speed)

func get_score():
    if player.get_current_animation() == "time_run":
        match score_strength:
            EASY:
                return get_score_range(-70, 0, 30, 100)
            MEDIUM:
                return get_score_range(30, 90, 60, 70)
            HARD:
                return get_score_range(76, 98, 88, 92)
    else:
        return 0

func get_score_range(mini, maxi, bmin, bmax):
    var pos = cursor.position.x
    if pos <= mini or pos >= maxi:
        return 0
    elif pos < bmin:
        return 2 * (pos - mini)/(maxi - mini)
    elif pos >= bmax:
        return 2 * (maxi - pos)/(maxi - mini)
    else: # pos in [bmini, bmaxi] == bonus
        return 1.5

func set_length(target_length):
    var length = player.get_animation("time_run").length
    speed = target_length / length
        
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
    if anim_name == "time_run":
        player.play("time_out", 1.0)
        emit_signal("time_out")
