extends Node2D

const GROUP_SCORE_FACTOR = 1

const Dock = preload("res://entities/dock.gd")
const SmallDock = preload("res://entities/small_dock.tscn")
const BigDock = preload("res://entities/big_dock.tscn")
const Boat = preload("res://entities/boat.tscn")

const FAC = 0.01

var rng = RandomNumberGenerator.new()

onready var forest_container = $forest
onready var dock_container = $docks
onready var boat_container = $boat_container
onready var tourist_container = $tourists
onready var target_containers = $tourist_targets
onready var flag_container = $flags

onready var boat_driver_enter = $boat_driver_enter
onready var sea_anchor = $sea_anchor
onready var click_controller = $click
onready var boat_exit = $boat_exit

# Parameters
var capacity  # capacity of the beach in number of people
var forest  # number of forest pieces left
var docks = 0  # number of anchor available
export(int) var boats = 1 # number of boat availables

# Real time variables
var popularity = 2  # 
var advise = 0
var eco_angst = 0
var bad_buzz = 0
var earning
var visit_per_day
var visit_cost
var side_earning
var satisfaction = 0
var trash = 0
var hype = 1
export var people_waiting = 8
onready var free_boat = boats

var flag_colors = {
    "blue": true,
    "orange": true
   }

# Called when the node enters the scene tree for the first time.
func _ready():
    update_vars()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    people_waiting += delta * (popularity + hype) * FAC
        
    visit_per_day = 10
    visit_cost = 1
    side_earning = 0
    
    eco_angst += (docks + trash - (forest - 10)) * delta
    popularity += (advise - eco_angst - bad_buzz + satisfaction) * delta
    earning = visit_per_day * visit_cost + side_earning
    
    hype *= 0.9

    print(people_waiting)
    
    if people_waiting >= 10 and free_boat  > 0:
        people_waiting -= 10
        boat_arrive()
    
    if Input.is_action_just_pressed("create_dock"):
        create_dock()

func update_vars():
    forest = forest_container.get_child_count()
    capacity = 200 - 12 * forest

func create_dock():
    var slot = available_dock_slot()
    if slot:
        var dock = SmallDock.instance()
        slot.add_child(dock)
        dock.connect("clicked_when_free", click_controller, "_on_click_on_dock")
        docks += 1
    
func upgrade_dock():
    var slot = upgradable_dock()
    if slot:
        # upgrade dock
        docks += 1
    
func upgradable_dock():
    for slot in dock_container.get_children():
        if slot.get_child_count() != 0:
            var dock = slot.get_child(0)
            if dock.dock_size == "small":
                return slot

func available_dock_slot():
    for child in dock_container.get_children():
        if child.get_child_count() == 0:
            return child

func boat_arrive():
    if free_boat > 0:
        free_boat -= 1
        var boat = Boat.instance()
        boat_driver_enter.add_child(boat)
        boat_driver_enter.start(boat)

func _on_boat_driver_entered(_anim_name: String) -> void:
    var boat = boat_driver_enter.tracked_boat
    var pos = boat.get_global_position()
    var rot = boat.get_global_rotation()
    boat_driver_enter.remove_child(boat)
    boat_container.add_child(boat)
    boat.set_global_position(pos)
    boat.set_global_rotation(rot)
    boat.wait_for_slot()
    boat.set_flag_color(get_available_color())
    boat.set_way_out(boat_exit)
    boat.connect("go_to_dock", self, "_on_boat_go_to_dock")
    boat.connect("reached_dock", self, "_on_boat_reached_dock")
    boat.connect("disembark", self, "_on_disembark")
    boat.connect("raised_flag", self, "_on_raised_flag")
    boat.connect("leave_dock", self, "_on_boat_leave_dock")
    boat.connect("leave_screen", self, "_on_boat_leave_screen")
    
    boat.connect("clicked_when_waiting_for_dock", click_controller, "_on_click_on_waiting_boat")
    boat.connect("clicked_when_docked", click_controller, "_on_click_on_docked_boat")

func _on_boat_go_to_dock(_boat):
    boat_driver_enter.reset()

func _on_boat_reached_dock(boat, _dock):
    var flag_color = boat.flag_color
    var new_flag = flag_container.spawn_flag(boat.get_global_position(), flag_color)
    new_flag.connect("clicked", click_controller, "_on_click_on_flag")

func _on_boat_leave_dock(_boat, dock, anchor, group_score):
    satisfaction += GROUP_SCORE_FACTOR * (group_score - 0.5)
    dock.free_anchor(anchor)

func _on_boat_leave_screen(boat, flag_color):
    free_boat += 1
    flag_colors[flag_color] = true
    
func _on_disembark(boat, dock, people):
    var target = dock.get_node("target")
    var spawner = dock.get_node("spawner")
    tourist_container.add_child(people)
    people.connect("ask_for_target", self, "_on_ask_for_target")
    people.set_color(boat.flag_color)
    people.set_global_position(spawner.get_global_position())
    people.leave_dock(target.get_global_position())
    
func get_free_dock():
    if dock_container.get_child_count() == 0:
        return sea_anchor
    
    for slot in dock_container.get_children():
        if slot.get_child_count() != 0:
            var dock = slot.get_child(0)
            if dock.has_free_anchor():
                return dock
    return null

func _on_ask_for_target(people, prev_target):
    var target_n = target_containers.get_child_count()
    var target = target_containers.get_child(rng.randi_range(0, target_n-1)).get_global_position()
    while target.distance_to(prev_target) < 200:
        target = target_containers.get_child(rng.randi_range(0, target_n-1)).get_global_position()
    
    people.set_target(target)

func get_available_color():
    for color in flag_colors.keys():
        if flag_colors[color] == true:
            flag_colors[color] = false
            return color

func _on_raised_flag(boat, dock, color):
    for people in tourist_container.get_children():
        if people.group_color == color:
            people.call_back(boat, dock)
