extends Control

var flat_value:int # get in setup instead
var flat_name_label:Label
var flat_value_label:Label
var rent_factor_label:Label
var rent_slider:HSlider
var rent_value_label:Label

var rooms_in_flat:Array

var household:Household
var tenant_income:int 
var tenant_name_label:Label
var tenant_income_label:Label

var room_bonus:int = 0
var neighbour_bonus:int = 0

var happiness_current:int
var happy_bar:TextureProgressBar
var happy_change_bar:TextureProgressBar

var flat_value_details:RichTextLabel
var tenant_happiness_detail:RichTextLabel
var tenant_room_pref_details:RichTextLabel
var tenant_neighbour_pref_details:RichTextLabel



var id := -1

func _ready() -> void:
	flat_name_label = find_child("FlatName")
	flat_value_label = find_child("FlatValue")
	flat_value_label.get_child(0).mouse_entered.connect(ToggleFlatDetails.bind(true))
	flat_value_label.get_child(0).mouse_exited.connect(ToggleFlatDetails.bind(false))
	rent_factor_label= find_child("RentFactor")
	rent_slider = find_child("RentSlider")
	rent_slider.value_changed.connect(ChangeRent)
	rent_slider.value_changed.connect(ShowFutureHappiness)
	rent_value_label = find_child("FlatRent")
	
	tenant_name_label = find_child("HouseholdName")
	tenant_name_label.get_child(0).mouse_entered.connect(TogglePreferenceDetails.bind(true))
	tenant_name_label.get_child(0).mouse_exited.connect(TogglePreferenceDetails.bind(false))
	tenant_income_label = find_child("Income")
	
	happy_bar = find_child("HappyBar")
	happy_change_bar = find_child("HappyChangeBar")
	happy_bar.mouse_entered.connect(ToggleHappinessDetails.bind(true))
	happy_bar.mouse_exited.connect(ToggleHappinessDetails.bind(false))
	
	flat_value_details = find_child("ValueDetails")
	tenant_happiness_detail = find_child("HappyDetails")
	tenant_room_pref_details = find_child("RoomPref")
	tenant_neighbour_pref_details= find_child("NeighbourPref")
	
	GameState.state_changed.connect(on_state_changed)

func on_state_changed(a):
	visible = false

func SetupTenant(household:Household): # setup with tenant data
	# setup name
	tenant_name_label.text = household.household_name
	# setup income
	tenant_income = household.rent
	tenant_income_label.text = "Income:\n" + str(tenant_income) + " $ / month"
	# setup happiness_current
	happiness_current = household.happiness
	happy_bar.value = happiness_current
	happy_change_bar.value = happiness_current
	# setup happy bars
	ShowFutureHappiness(0) #number doesnt matter
	# setup rent modifier
	rent_slider.value = household.rentMod
	

func ShowFutureHappiness(a:float):
	ShowHappyBarChange(GetHappinessChange(tenant_income))
	
func GetHappinessChange(tenantMoney:int):
	tenant_happiness_detail.text = "Happiness\n"
	var happyChange:int = 0
	# Happiness from leftover money
	var money_left = (1-(flat_value*rent_slider.value/tenantMoney))*50
	if (money_left > 0): tenant_happiness_detail.text += "[color=lawngreen]+" + str(int(money_left)) + " for leftover money[/color]\n"
	elif(money_left < 0): tenant_happiness_detail.text += "[color=orangered]" + str(int(money_left)) + " for missing money[/color]\n"
	# Happiness from relative price of flat
	var value_for_money = -(rent_slider.value-1)*50
	if (value_for_money > 0): tenant_happiness_detail.text += "[color=lawngreen]+" + str(int(value_for_money)) + " for underpriced rent[/color]\n"
	elif(value_for_money < 0): tenant_happiness_detail.text += "[color=orangered]" + str(int(value_for_money)) + " for overpriced rent[/color]\n"
	# Happiness if unaffordable
	var unaffordable = 0
	if (flat_value*rent_slider.value > tenantMoney): unaffordable -= 50
	if (unaffordable < 0): tenant_happiness_detail.text += "[color=orangered]" + str(int(unaffordable)) + " for unaffordability[/color]\n"
	# Happiness from rooms
	var r_bonus = room_bonus
	if (r_bonus > 0): tenant_happiness_detail.text += "[color=lawngreen]+" + str(int(r_bonus)) + " for liked rooms[/color]\n"
	if (r_bonus < 0): tenant_happiness_detail.text += "[color=orangered]" + str(int(r_bonus)) + " for disliked rooms[/color]\n"
	# Happiness from neighbours
	var n_bonus = neighbour_bonus
	if (n_bonus > 0): tenant_happiness_detail.text += "[color=lawngreen]+" + str(int(n_bonus)) + " for liked neighbours[/color]\n"
	if (n_bonus < 0): tenant_happiness_detail.text += "[color=orangered]" + str(int(n_bonus)) + " for disliked neighbours[/color]\n"
	# QoL: Sort the boni in descending order and display it that way
	happyChange += money_left
	happyChange += value_for_money
	happyChange += unaffordable
	happyChange += r_bonus
	happyChange += n_bonus
	household.happiness_change = happyChange
	return happyChange
	
func ShowHappyBarChange(change:int):
	var happy_value:Label = find_child("HappyValue")
	if (change > 0):
		happy_change_bar.texture_progress = load("res://sprites/ui/Bars/Cartoon RPG UI_Progress Bar - Mana.png")
		happy_bar.value = happiness_current
		happy_change_bar.value = happiness_current + change
		happy_value.text = str(happiness_current) + " (+" + str(change) + ")" 
	elif (change <= 0):
		happy_change_bar.texture_progress = load("res://sprites/ui/Bars/Cartoon RPG UI_Progress Bar - Life.png")
		happy_change_bar.value = happiness_current
		happy_bar.value = happiness_current + change
		happy_value.text = str(happiness_current) + " (" + str(change) + ")"

func ChangeRent(a:float):
	if (household != null):
		household.rentToPay = flat_value * rent_slider.value
		rent_factor_label.text = "x " + str(rent_slider.value)
		rent_value_label.text = "Rent:\n" + str(household.rentToPay) + " $ / month"
		household.rentMod = rent_slider.value
		ShowFutureHappiness(0) # number doesnt matter

func ToggleFlatDetails(on:bool):
	if on == true: 
		find_child("MarginContainerDetails").visible = true
		flat_value_details.visible = true
	else: 
		flat_value_details.visible = false
		if !IsInfoOpen(): find_child("MarginContainerDetails").visible = false
func ToggleHappinessDetails(on:bool):
	if on == true: 
		find_child("MarginContainerDetails").visible = true
		tenant_happiness_detail.visible = true
	else: 
		tenant_happiness_detail.visible = false
		if !IsInfoOpen(): find_child("MarginContainerDetails").visible = false
func TogglePreferenceDetails(on:bool):
	if on == true: 
		find_child("MarginContainerDetails").visible = true
		tenant_room_pref_details.visible = true
		tenant_neighbour_pref_details.visible = true
	else: 
		tenant_room_pref_details.visible = false
		tenant_neighbour_pref_details.visible = false
		if !IsInfoOpen(): find_child("MarginContainerDetails").visible = false
func IsInfoOpen():
	if (find_child("ValueDetails").visible == true): return true
	elif (find_child("HappyDetails").visible == true): return true
	elif (find_child("RoomPref").visible == true): return true
	else: return false
func HideHouseholdInfo():
	find_child("Household").visible = false
	find_child("RentSlider").visible= false
	find_child("RentFactor").visible= false
	find_child("FlatRent").visible= false
func ShowHouseholdInfo():
	find_child("Household").visible = true
	find_child("RentSlider").visible= true
	find_child("RentFactor").visible= true
	find_child("FlatRent").visible= true


func set_occupied(value:bool):
	pass

func set_flat_index(index:Vector2):
	find_child("FlatName").text = str(
		"Floor ", index.y, " - ",
		"Flat ", index.x
	)

func set_id(id:int):
	self.id = id
	set_occupied(id != -1)
	var hh : Household = GameState.building.get_household_from_id(id)
	prints("hot id ", id, " hh is ", hh)
	if hh:
		household = hh
		SetupTenant(household)
		ShowHouseholdInfo()
	else:
		HideHouseholdInfo()

# physically present
func handle_room_types_of_flat(rooms:Array):
	# FILL FLAT ROOM TOOLTIP
	var flatValueText:String
	var flatValueInt:int = 0
	for room in rooms:
		rooms_in_flat.append(room)
		flatValueInt += CONST.get_rent(room)
		flatValueText += "+ " + str(CONST.get_rent(room)) + " $ " + str(CONST.ROOM_NAMES.get(room)) + "\n"
	flat_value_details.text = flatValueText
	flat_value = flatValueInt
	flat_value_label.text = "Value:\n" + str(flat_value) + " $ / month"
	ChangeRent(0) # nr doensnt matter

func handle_neighbor_archetypes(neighbors:Array):
	# const.household
	pass

var present_happy_rooms := []
var present_sad_rooms := []
var present_happy_neighbors := []
var present_sad_neighbors := []
var pref_happy_rooms := []
var pref_sad_rooms := []
var pref_happy_neighbors := []
var pref_sad_neighbors := []

func set_happiness_affectors(
	happy_room_presences : Array,
	sad_room_presences : Array,
	happy_neighbor_presences : Array,
	sad_neighbor_presences : Array,
):
	room_bonus = 0
	neighbour_bonus = 0
	# CALCULATE HAPPINESS MODIFIERS
	for room in happy_room_presences:
		room_bonus += 3
	for room in sad_room_presences:
		room_bonus -= 3
	for n in happy_neighbor_presences:
		neighbour_bonus += 5
	for n in sad_neighbor_presences:
		neighbour_bonus -= 5
	
	present_happy_rooms = happy_room_presences
	present_sad_rooms = sad_room_presences
	present_happy_neighbors = happy_neighbor_presences
	present_sad_neighbors = sad_neighbor_presences
	
	update_pref_tooltip()

# theoretical preferences
func set_happiness_preferences(
	happy_rooms : Array,
	sad_rooms : Array,
	happy_neighbors : Array,
	sad_neighbors : Array
):
	
	pref_happy_rooms = happy_rooms
	pref_sad_rooms = sad_rooms
	pref_happy_neighbors = happy_neighbors
	pref_sad_neighbors = sad_neighbors
	
	update_pref_tooltip()

func update_pref_tooltip():
	# FILL PREFERENCES TOOLTIPS
	var room_prefs:String = "Room Preferences\n"
	for room in pref_happy_rooms:
		room_prefs += str("[color=lawngreen]+ ", CONST.ROOM_NAMES.get(room), " (", present_happy_rooms.count(room), ")[/color]\n")
	for room in pref_sad_rooms:
		room_prefs += str("[color=orangered]- ", CONST.ROOM_NAMES.get(room), " (", present_sad_rooms.count(room), ")[/color]\n")
	tenant_room_pref_details.text = room_prefs
	
	var neighbour_prefs:String = "Neighbour Preferences\n"
	for tenant in pref_happy_neighbors:
		neighbour_prefs += str("[color=lawngreen]+ ", CONST.HOUSEHOLD_NAMES.get(tenant), " (", present_happy_neighbors.count(tenant), ")[/color]\n")
	for tenant in pref_sad_neighbors:
		neighbour_prefs += str("[color=orangered]- ", CONST.HOUSEHOLD_NAMES.get(tenant), " (", present_sad_neighbors.count(tenant), ")[/color]\n")
	tenant_neighbour_pref_details.text = neighbour_prefs


func _on_evict_button_pressed() -> void:
	GameState.building.evict(id)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			visible = false
