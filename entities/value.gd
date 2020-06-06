extends Node2D

export(float) var value = 0
export(bool) var approx = false

onready var label = $label

func _ready() -> void:
    update_value(value)

func update_value(val):
    value = val
    if not approx:
        label.text = str(round(val*100)/100)
    else:
        var repr
        if val >= 1.0e9:
            repr = str(round(val/1.0e8)/10) + "G"
        elif val >= 1.0e6:
            repr = str(round(val/1.0e5)/10) + "M"
        elif val >= 1.0e3:
            repr = str(round(val/100)/10) + "K"
        else:
            repr = str(round(val*10)/10)
            
        label.text = repr
