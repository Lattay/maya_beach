extends Node2D

export(String, FILE) var scene

func _on_in_play_clickable_clicked(event) -> void:
    get_tree().change_scene(scene)
