extends Node2D

const Dock = preload("res://entities/dock.gd")
const SmallDock = preload("res://entities/small_dock.tscn")
const BigDock = preload("res://entities/big_dock.tscn")
const Boat = preload("res://entities/boat.tscn")

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

# constant

var flag_colors = {
    "blue": true,
    "orange": true
   }

export var group_score_factor = 1
export var visit_factor = 10
export var hype_factor = 4
export var hype_decrease = 0.5
export var satisfaction_factor = 10
export var clean_beach_capacity = 200

# strategic parameters
export var visit_cost = 10
var capacity # capacity of the beach in number of people
var forest  # number of forest pieces left
var docks = 0  # number of anchor available
export(int) var boats = 1 # number of boat availables

# longrun variables
var popularity = 2
var eco_angst = 0
var total_earning
var trash = 0
var hype = 1

# daily variables
var satisfaction = 0
var side_earning = 0
export var visit_today = 30
onready var people_waiting = visit_today

# other variables
onready var free_boat = boats
onready var last_use
onready var people_on_ground = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    last_use = Array()
    for c in target_containers.get_children():
        last_use.append(0.0)
    rng.randomize()
    update_forest()

func day_review():
    # update longrun variables
    total_earning = (visit_today - people_waiting) * visit_cost + side_earning
    
    satisfaction -= 0.5 * people_waiting
    
    eco_angst += (docks + trash - (forest - 10))
    popularity += satisfaction_factor * satisfaction / visit_cost
    
    hype *= hype_decrease
    
    print("total earning ", total_earning)
    print("satisfaction ", satisfaction)
    print("popularity ", popularity)
    # reset daily variables
    visit_today = (popularity - eco_angst + hype_factor * hype) * visit_factor
    people_waiting = visit_today
    satisfaction = 0
    side_earning = 0
    
    
func _process(_delta):
    if (
        people_waiting >= 10
        and free_boat  > 0
        and people_on_ground < capacity
        and boat_driver_enter.is_free
    ):
        people_waiting -= 10
        boat_arrive()
    
    if Input.is_action_just_pressed("create_dock"):
        create_dock()

func update_forest():
    forest = forest_container.get_child_count()
    capacity = clean_beach_capacity - 12 * forest

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
    var flag_color = get_available_color()
    boat.set_flag_color(flag_color)
    var new_flag = flag_container.spawn_flag(boat.get_global_position(), flag_color)
    new_flag.connect("clicked", click_controller, "_on_click_on_flag")
    boat.wait_for_slot()
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

func _on_boat_reached_dock(_boat, _dock):
    people_on_ground += 10

func _on_boat_leave_dock(_boat, dock, anchor, group_score):
    satisfaction += group_score_factor * (group_score - 0.5)
    print(group_score)
    people_on_ground -= 10
    dock.free_anchor(anchor)

func _on_boat_leave_screen(boat):
    free_boat += 1
    flag_colors[boat.flag_color] = true
    boat.queue_free()
    
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
    var index = rng.randi_range(0, target_n-1)
    var target = target_containers.get_child(index).get_global_position()
    var now = OS.get_system_time_msecs()
    while target.distance_to(prev_target) < 100 or now - last_use[index] < 0.2:
        index = rng.randi_range(0, target_n-1)
        target = target_containers.get_child(index).get_global_position()
    last_use[index] = now
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
