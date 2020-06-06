extends Node2D

onready var profit_label = $profit/value
onready var booking_label = $booking/value
onready var wealth_label = $wealth/value
onready var anger_label = $ecoanger/value
onready var popularity_label = $popularity/value

func update_values(profit, booking, wealth, anger, popularity):
    profit_label.text = str(profit)
    booking_label.text = str(booking)
    wealth_label.text = str(wealth)
    anger_label.text = str(anger)
    popularity_label.text = str(popularity)
    
