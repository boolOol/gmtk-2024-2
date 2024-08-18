extends Control

var flat_value:int # get in setup instead
var tenantIncome:int # get in setup instead

var flat_name_label:Label
var flat_value_label:Label
var rent_factor_label:Label
var rent_slider:HSlider
var rent_value_label:Label

var tenant_name_label:Label
var tenant_income_label:Label

var happiness_current:int
var happy_bar:TextureProgressBar
var happy_change_bar:TextureProgressBar

var flat_details_button:Button
var happiness_details_button:Button
var pref_details_button:Button

func _ready() -> void:
	flat_name_label = find_child("FlatName")
	flat_value_label = find_child("FlatValue")
	flat_value_label.get_child(0).mouse_entered.connect(ToggleFlatDetails.bind(true))
	flat_value_label.get_child(0).mouse_exited.connect(ToggleFlatDetails.bind(false))
	rent_factor_label= find_child("RentFactor")
	rent_slider = find_child("RentSlider")
	rent_slider.value_changed.connect(ChangeRentInfo)
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
	
	flat_details_button = find_child("ShowValueDetails")
	flat_details_button.toggled.connect(ToggleFlatDetails)
	happiness_details_button = find_child("ShowHappyDetails")
	happiness_details_button.toggled.connect(ToggleHappinessDetails)
	pref_details_button = find_child("ShowPref")
	pref_details_button.toggled.connect(TogglePreferenceDetails)
	
	SetupFlat(1052, "Floor 57 - Flat 1")
	SetupTenant()
	ShowFutureHappiness(0)

func SetupTenant(): # setup with tenant data
	print("not yet")
	# setup happiness_current
	happiness_current = 100
	happy_bar.value = happiness_current
	happy_change_bar.value = happiness_current
	# setup income
	tenantIncome = 1300
	tenant_income_label.text = "Income: " + str(tenantIncome) + " $ / month"
	# setup happy bars

func SetupFlat(value:int, name:String): # take array of rooms and calculate their total value
	flat_value = value
	flat_name_label.text = name
	flat_value_label.text = "Value:\n" + str(value) + " $ / month"

func ShowFutureHappiness(a:float):
	ShowHappyChange(GetHappinessChange(tenantIncome))
func GetHappinessChange(tenantMoney:int):
	var happyNew:int = 0
	happyNew = (1-(flat_value*rent_slider.value/tenantMoney))*50
	happyNew -= (rent_slider.value-1)*50
	
	if (flat_value*rent_slider.value > tenantMoney): happyNew -= 50
	return happyNew
func ShowHappyChange(change:int):
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

func ChangeRentInfo(a:float):
	rent_factor_label.text = "x " + str(rent_slider.value)
	rent_value_label.text = "Rent:\n" + str(flat_value * rent_slider.value) + " $ / month"

func ToggleFlatDetails(on:bool):
	if on == true: 
		find_child("MarginContainerDetails").visible = true
		find_child("ValueDetails").visible = true
	else: 
		find_child("ValueDetails").visible = false
		if !IsInfoOpen(): find_child("MarginContainerDetails").visible = false
func ToggleHappinessDetails(on:bool):
	if on == true: 
		find_child("MarginContainerDetails").visible = true
		find_child("HappyDetails").visible = true
	else: 
		find_child("HappyDetails").visible = false
		if !IsInfoOpen(): find_child("MarginContainerDetails").visible = false

func TogglePreferenceDetails(on:bool):
	if on == true: 
		find_child("MarginContainerDetails").visible = true
		find_child("RoomPref").visible = true
		find_child("NeighbourPref").visible = true
	else: 
		find_child("RoomPref").visible = false
		find_child("NeighbourPref").visible = false
		if !IsInfoOpen(): find_child("MarginContainerDetails").visible = false

func IsInfoOpen():
	if (find_child("ValueDetails").visible == true): return true
	elif (find_child("HappyDetails").visible == true): return true
	elif (find_child("RoomPref").visible == true): return true
	else: return false
