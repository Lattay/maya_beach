extends Node2D

signal close


func _on_back_button_clicked(_event) -> void:
    emit_signal("close")


func _on_exit_button_clicked(_event) -> void:
    get_tree().quit()
