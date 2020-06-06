extends Node2D

onready var profit_label = $profit/value
onready var booking_label = $booking/value
onready var wealth_label = $wealth/value
onready var anger_label = $ecoanger/value
onready var popularity_label = $popularity/value

func update_values(profit, booking, wealth, anger, popularity):
    profit_label.update_value(profit)
    booking_label.update_value(booking)
    wealth_label.update_value(wealth)
    anger_label.update_value(anger)
    popularity_label.update_value(popularity)
