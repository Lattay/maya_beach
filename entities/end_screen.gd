extends Node2D

onready var panda = $panda
onready var leo = $leo
onready var label 

onready var dialog = {
    "tuto_1": [
        leo,
        "Hi, I am the boss here, and you work for me !\nThis is a beach I just bought and I want you to make as much money as possible from it.\nI gave you a boat and a bit of money to start.\nOk let's start !",
        funcref(self, "advance_tuto")
    ],
    "tuto_2": [
        leo,
        "Let's start buy building a small dock. Click on the shop icon on top left of the screen and build a small dock.",
        funcref(self, "advance_tuto")
    ],
    "tuto_3": [
        leo,
        "Cool, here is the first boat of people.\nClick on the boat, then on the dock to let them land.",
        funcref(self, "advance_tuto")
    ],
    "tuto_4": [
        leo,
        "Perfect !\nNow let the have fun but not too long because they'll get board.\nWhen the time cursor is on the green, click on the flag, then on an empty boat to call them back.",
        funcref(self, "advance_tuto")
    ],
    "tuto_5": [
        leo,
        "I think you get it, work well, make money.\nAnd beware of ecologists, they are so anoying.",
        funcref(self, "advance_tuto")
    ],
    "loose_money": [
        leo,
        "Oh buddy ! What have you done ? This was easy money and you messed up !\nYou better pay me back my investment because I know people here who would give me a good price for you liver !",
        funcref(self, "you_loose")
    ],
    "loose_eco": [
        panda,
        "Excuse me sir but the government, under the pressure of environmental organisations, is going to close this beach to let nature recover.\n\nAlso you are going to jail.",
        funcref(self, "you_loose")
    ],
    "win_money": [
        leo,
        "Hey buddy ! Good job here, you made a hell of a money !\nOh, by the way, a friend of mine got caugth selling girls in the harbor so he told cops you were the boss... Sorry, you're going to jail for a long time.\nDon't worry, I'll keep an eye on your beach and you're money !",
        funcref(self, "you_win")
    ]
}

var current_dialog
var next

func go_to_menu():
    get_tree().change_scene("res://menu.tscn")
    
func load_reason(dial_id):
    current_dialog = dial_id
    var l = dialog[dial_id]
    l[0].visible = true
    show_message(l[1])
    next = l[2]

    
func you_loose():
    show_message("You loose !")

func advance_tuto():
    pass

func show_message(msg):
    label.text = msg
