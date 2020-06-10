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
onready var hud = $hud
onready var pause_controller = $pause
onready var dash_board = $pause/dash_board
onready var dialog_controller = $dialog_controller

# constant

var flag_colors = {}

var boat_cost = 100
var kid_cost = 10

export(float) var group_score_factor = 1
export(float) var visit_factor = 10
export(float) var hype_factor = 4
export(float) var hype_decrease = 0.5
export(float) var satisfaction_factor = 0.3
export(int) var clean_beach_capacity = 200
export(int) var cheap_ticket = 10
export(int) var mild_ticket = 50
export(int) var expensive_ticket = 300
enum {
    CHEAP,
    MILD,
    EXPENSIVE
}

# strategic parameters
var ticket_price = CHEAP setget set_ticket_price
var visit_cost = 10
var capacity # capacity of the beach in number of people
var forest = 0  # number of forest pieces left
var small_docks = 0  # number of small available
var big_docks = 0 # number of big docks available
export(int) var boats = 1 # number of boat availables

# longrun variables
var day = 1
var popularity = 2
var eco_anger = 0
var trash = 0
var hype = 0
export(int) var wealth = 1400
var kids_number = 0

# daily variables
var satisfaction = 0
export var visit_today = 30
onready var people_waiting = 0
var profit = 0

# other variables
var forest_max
var max_people_on_ground = 0
onready var free_boat = boats
onready var last_use
onready var people_on_ground = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    last_use = Array()
    for c in target_containers.get_children():
        last_use.append(0.0)
    rng.randomize()
    forest_max = forest_container.get_child_count()
    update_forest()

func day_review():
    # update longrun variables
    
    satisfaction -= 0.5 * people_waiting
    
    eco_anger = (
        3 * (small_docks + big_docks)
        + trash
        + 3.6 * (forest_max - forest)
        + 0.6 * max_people_on_ground
    )
    popularity += satisfaction_factor * satisfaction / visit_cost
    popularity = max(popularity, 0)  # cannot be negative
    wealth += profit
    
    if eco_anger >= 100:
        dialog_controller.loose_eco()
    if wealth <= 0:
        dialog_controller.loose_money()
    if wealth >= 1000000:
        dialog_controller.win()
    
    hype *= hype_decrease
    
    day += 1
    
    # reset daily variables
    visit_today = 10 * int((
        popularity  * visit_factor * (1 + sqrt(hype_factor * hype))
        + kids_efficiency(kids_number)
    ) / 10)
    visit_today = max(visit_today, 0)
    people_waiting = visit_today
    satisfaction = 0
    profit = - boats * boat_cost - kids_number * kid_cost

func set_ticket_price(val):
    ticket_price = val
    match val:
        CHEAP:
            visit_cost = cheap_ticket
        MILD:
            visit_cost = mild_ticket
        EXPENSIVE:
            visit_cost = expensive_ticket

func kids_efficiency(kids):
    if kids < 1:
        return 0
    else:
        return sqrt(18.34 * kids - 13)
    
func _process(_delta):
    if (
        people_waiting >= 10
        and free_boat  > 0
        and people_on_ground < capacity
        and boat_driver_enter.is_free
    ):
        people_waiting -= 10
        boat_arrive()
    
    if Input.is_action_just_pressed("pause"):
        pause()
    
    if Input.is_action_just_pressed("shop"):
        shop()
        
    if people_on_ground > max_people_on_ground:
        max_people_on_ground = people_on_ground
        
    hud.update_values(profit, people_waiting, wealth, eco_anger, popularity)

func update_forest():
    forest = forest_container.get_child_count()
    capacity = clean_beach_capacity - 12 * forest

func create_dock():
    var slot = available_dock_slot()
    if slot:
        var dock = SmallDock.instance()
        slot.add_child(dock)
        dock.connect("clicked_when_free", click_controller, "_on_click_on_dock")
        small_docks += 1
    
func upgrade_dock():
    var slot = upgradable_dock()
    if slot:
        # upgrade dock
        small_docks -= 1
        big_docks += 1
    
func upgradable_dock():
    for slot in dock_container.get_children():
        if slot.get_child_count() != 0:
            var dock = slot.get_child(0)
            if dock.is_small():
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
    var flag_strength
    match ticket_price:
        CHEAP:
            flag_strength = 0
        MILD:
            flag_strength = 1
        EXPENSIVE:
            flag_strength = 2
    var new_flag = flag_container.spawn_flag(boat.get_global_position(), flag_color, flag_strength)
    new_flag.connect("clicked", click_controller, "_on_click_on_flag")
    new_flag.connect("time_out", boat, "_on_time_out")
    
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
    boat.connect("leave_on_time_out", flag_container, "_on_boat_leave_on_time_out")

func _on_boat_go_to_dock(_boat):
    boat_driver_enter.reset()

func _on_boat_reached_dock(_boat, _dock):
    profit += visit_cost * 10
    dialog_controller.boat_reached_dock()

func _on_boat_leave_dock_empty(_boat, dock, anchor):
    dock.free_anchor(anchor)

func _on_boat_leave_dock(_boat, dock, anchor, group_score):
    if dock != null:
        people_on_ground -= 10
        dock.free_anchor(anchor)
        dialog_controller.calling_back()  # only for tutorial
    else:
        boat_driver_enter.reset()
    satisfaction += group_score_factor * (group_score - 0.3)

func _on_boat_leave_screen(boat):
    free_boat += 1
    flag_colors[boat.flag_color] = false
    boat.queue_free()
    
func _on_disembark(boat, dock, people):
    people_on_ground += people.quantity
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
        if flag_colors[color] == false:
            flag_colors[color] = true
            return color
    var color = gen_random_color()
    flag_colors[color] = true
    return color

func gen_random_color():
    var col = Color(rng.randf(), rng.randf(), rng.randf())
    while is_in_flags(col):
        col = Color(rng.randf(), rng.randf(), rng.randf())
    return col

func is_in_flags(col):
    for color in flag_colors.keys():
        if col.is_equal_approx(color):
            return true
    return false

func _on_raised_flag(boat, dock, color):
    for people in tourist_container.get_children():
        if people.group_color.is_equal_approx(color):
            people.call_back(boat, dock)

func pause():
    pause_controller.pause(pause_controller.PAUSE)

func shop():
    dash_board.init_values(day, wealth, ticket_price, boats, small_docks, big_docks, capacity, forest)
    pause_controller.pause(pause_controller.SHOP)

func _on_dash_board_close() -> void:
    var values = dash_board.get_values()
    var not_used_boats = boats - free_boat
    
    # wealth tiche_price boat
    wealth = values[0]
    set_ticket_price(values[1])
    boats = values[2]
    free_boat = boats - not_used_boats
    
    # small_docks big_docks forest
    var new_small = values[3]
    var new_big = values[4]
    if new_small + new_big > small_docks + big_docks:
        dialog_controller.build_docks()
        
    while small_docks + big_docks < new_small + new_big:
        create_dock()

    while big_docks < new_big:
        upgrade_dock()
    
    while forest > values[5]:
        cut_trees()
    
    # hired_kids instagram_investment corrupt_investment
    kids_number += values[6]
    
    hype += 4 * values[7]
    eco_anger -= 10 * values[8]
    eco_anger = max(0, eco_anger)
    
    
func cut_trees():
    var trees = null
    var max_y = 0
    for child in forest_container.get_children():
        if child.position.y > max_y:
            trees = child
            max_y = child.position.y
    if trees != null:
        forest -= 1
        trees.queue_free()

func _on_pause_screen_close() -> void:
    pass # Replace with function body.

func _on_dialog_controller_enable_visit() -> void:
    people_waiting = visit_today


func _on_in_shop_button_clicked(event) -> void:
    shop()


func _on_in_pause_button_clicked(event) -> void:
    pause()
