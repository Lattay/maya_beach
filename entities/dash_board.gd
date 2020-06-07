extends Node2D

signal close

onready var day_label = $day_num

onready var boats_label = $boats
var boats = 0 setget set_boats

onready var small_docks_label = $small_docks
var small_docks = 0 setget set_small_docks

onready var big_docks_label = $big_docks
var big_docks = 0 setget set_big_docks

onready var capacity_label = $beach_capacity
var capacity = 0 setget set_capacity

onready var wealth_label = $wealth
var wealth = 0 setget set_wealth

onready var ref_cheap = $ref_cheap
onready var ref_mild = $ref_mild
onready var ref_expensive = $ref_expensive
onready var cursor = $cursor

var forest = 0
var hired_kids = 0
var instagram_investment = 0
var corruption_investment = 0

enum {
    CHEAP,
    MILD,
    EXPENSIVE
}
onready var ticket_price = CHEAP setget set_ticket_price

onready var boat_price = $boat_price.value
onready var boat_cost = $boat_cost.value
onready var small_dock_price = $small_dock_price.value
onready var big_dock_price = $big_dock_price.value
onready var deforest_price = $deforest_price.value
onready var insta_price = $insta_price.value
onready var corrupt_price = $corrupt_price.value
onready var kid_price = $kid_price.value


func init_values(day, new_wealth, new_ticket_price, new_boats, new_small_docks, new_big_docks, new_capacity, new_forest):
    day_label.update_value(day)
    set_boats(new_boats)
    set_small_docks(new_small_docks)
    set_big_docks(new_big_docks)
    set_capacity(new_capacity)
    forest = new_forest
    set_wealth(new_wealth)
    set_ticket_price(new_ticket_price)
        
func get_values():
    return [
        wealth, ticket_price, boats,
        small_docks, big_docks, forest,
        hired_kids, instagram_investment,
        corruption_investment
    ]

func set_wealth(val):
    wealth = val
    wealth_label.update_value(wealth)
    
func set_boats(val):
    boats = val
    boats_label.update_value(boats)
    
func set_small_docks(val):
    small_docks = val
    small_docks_label.update_value(small_docks)
    
func set_big_docks(val):
    big_docks = val
    big_docks_label.update_value(big_docks)
    
func set_capacity(val):
    capacity = val
    capacity_label.update_value(capacity)
    
func set_ticket_price(val):
    ticket_price = val
    match val:
        CHEAP:
            cursor.position = ref_cheap.position
        MILD:
            cursor.position = ref_mild.position
        EXPENSIVE:
            cursor.position = ref_expensive.position


func cannot_pay():
    pass

func _on_boat_button_clicked(_event) -> void:
    if wealth >= boat_price:
        set_boats(boats + 1)
        set_wealth(wealth - boat_price)
    else:
        cannot_pay()

func _on_dock_button_clicked(_event) -> void:
    if wealth >= small_dock_price and small_docks + big_docks < 8:
        set_small_docks(small_docks + 1)
        set_wealth(wealth - small_dock_price)
    else:
        cannot_pay()

func _on_upgrade_button_clicked(_event) -> void:
    if wealth >= big_dock_price and small_docks > 0:
        set_small_docks(small_docks - 1)
        set_big_docks(big_docks + 1)
        set_wealth(wealth - big_dock_price)
    else:
        cannot_pay()

func _on_deforest_button_clicked(_event) -> void:
    if wealth >= deforest_price and forest > 0:
        forest -= 1
        set_wealth(wealth - deforest_price)
    else:
        cannot_pay()

func _on_insta_button_clicked(_event) -> void:
    if wealth >= insta_price:
        instagram_investment += 1
        set_wealth(wealth - insta_price)
    else:
        cannot_pay()

func _on_corrupt_button_clicked(_event) -> void:
    if wealth >= corrupt_price:
        corruption_investment += 1
        set_wealth(wealth - corrupt_price)
    else:
        cannot_pay()

func _on_kid_button_clicked(_event) -> void:
    hired_kids += 1
    set_wealth(wealth)

func _on_close_button_clicked(_event) -> void:
    emit_signal("close")

func _on_cheap_button_clicked(_event) -> void:
    set_ticket_price(CHEAP)

func _on_mild_button_clicked(_event) -> void:
     set_ticket_price(MILD)


func _on_expensive_button_clicked(_event) -> void:
    set_ticket_price(EXPENSIVE)
