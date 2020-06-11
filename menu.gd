extends Node2D

func _on_play_button_clicked(_event) -> void:
    get_tree().change_scene("res://main.tscn")


func _on_about_button_clicked(_event) -> void:
    get_tree().change_scene("res://credit.tscn")


func _on_exit_button_clicked(_event) -> void:
    get_tree().quit()
