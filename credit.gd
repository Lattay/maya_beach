extends Node2D



func _on_in_play_clickable_clicked(event) -> void:
    get_tree().change_scene("res://menu.tscn")
