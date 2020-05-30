extends Node2D

const Deck = preload("res://entities/deck.gd")
const SmallDeck = preload("res://entities/small_deck.tscn")
const BigDeck = preload("res://entities/big_deck.tscn")
const Boat = preload("res://entities/boat.tscn")

onready var forest_container = $forest
onready var deck_container = $decks
onready var boat_container = $boat_container

onready var boat_driver_enter = $boat_driver_enter
onready var sea_anchor = $sea_anchor

var capacity
var forest
var popularity = 2
var advise = 0
var eco_angst = 0
var bad_buzz = 0
var earning
var visit_per_day
var visit_cost
var side_earning
var satisfaction = 0
var decks = 0
var trash = 0



func update_vars():
    forest = forest_container.get_child_count()
    capacity = 200 - 12 * forest

func create_deck():
    var slot = available_deck_slot()
    if slot:
        var deck = SmallDeck.instance()
        slot.add_child(deck)
        decks += 1
    
func upgrade_deck():
    var slot = upgradable_deck()
    if slot:
        # upgrade deck
        decks += 1
    
func upgradable_deck():
    for slot in deck_container.get_children():
        if slot.children_count() != 0:
            var deck = slot.get_child(0)
            if deck.deck_size == "small":
                return slot

func available_deck_slot():
    for child in deck_container.get_children():
        if child.children_count() == 0:
            return child

func boat_arrive():
    var boat = Boat.instance()
    boat_driver_enter.add_child(boat)
    boat_driver_enter.start()

# Called when the node enters the scene tree for the first time.
func _ready():
    update_vars()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    eco_angst += (decks + trash - (forest - 10)) * delta
    popularity += (advise - eco_angst - bad_buzz + satisfaction) * delta
    earning = visit_per_day * visit_cost + side_earning    
    
    visit_per_day = 10
    visit_cost = 1
    side_earning = 0


func _on_boat_driver_entered(anim_name: String) -> void:
    var boat = boat_driver_enter.get_child(0) as Node2D
    var pos = boat.get_global_position()
    var rot = boat.get_global_rotation()
    boat_driver_enter.remove_child(boat)
    boat_container.add_child(boat)
    boat.set_global_position(pos)
    boat.set_global_rotation(rot)
    boat.wait_user()
    boat.connect("go_to_deck", self, "_on_boat_go_to_deck")
    boat.connect("leave_deck", self, "_on_boat_leave_deck")
    
func _on_boat_go_to_deck(boat):
    var free_anchor = get_free_anchor()
    if free_anchor:
        boat_driver_enter.reset()
        boat.go_to_deck(free_anchor)

func _on_boat_leave_deck(deck):
    deck.set_free()

func get_free_anchor():
    if deck_container.get_children_count == 0:
        return sea_anchor
    
    for slot in deck_container.get_children():
        if slot.children_count() != 0:
            var deck = slot.get_child(0)
            match deck.deck_size:
                Deck.DeckSize.SMALL:
                    if deck.is_free:
                        return deck.get_node("anchor")
                Deck.DeckSize.BIG:
                    if deck.is_free_left:
                        return deck.get_node("anchor_left")
                    elif deck.is_free_right:
                        return deck.get_node("anchor_right")
    return null
