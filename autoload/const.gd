extends Node

enum RoomType {
	Kitchen,
	Bathroom,
	Livingroom,
	Bedroom,
	Hallway,
	Storeroom,
	Office,
	Fitnessroom,
	Garage,
	ChildRoom,
	Library,
	GamingRoom,
	PleasureRoom,
}

const EVENT_CHANCE := 0.15

const ROOM_SIZES := {
	RoomType.Kitchen : 2,
	RoomType.Bathroom : 1,
	RoomType.Livingroom : 2,
	RoomType.Bedroom : 2,
	RoomType.Hallway : 1,
	RoomType.Storeroom : 1,
	RoomType.Office : 1,
	RoomType.Fitnessroom : 2,
	RoomType.Garage : 2,
	RoomType.ChildRoom : 1,
	RoomType.Library : 1,
	RoomType.GamingRoom : 1,
	RoomType.PleasureRoom : 1,
}
const ROOM_VALUES := {
	RoomType.Kitchen : 3,
	RoomType.Bathroom : 2,
	RoomType.Livingroom : 4,
	RoomType.Bedroom : 3,
	RoomType.Hallway : 1,
	RoomType.Storeroom : 1,
	RoomType.Office : 2,
	RoomType.Fitnessroom : 6,
	RoomType.Garage : 8,
	RoomType.ChildRoom : 2,
	RoomType.Library : 4,
	RoomType.GamingRoom : 3,
	RoomType.PleasureRoom : 3,
}
const ROOM_NAMES := {
	RoomType.Kitchen : "Kitchen",
	RoomType.Bathroom : "Bathroom",
	RoomType.Livingroom : "Living Room",
	RoomType.Bedroom : "Bedroom",
	RoomType.Hallway : "Hallway",
	RoomType.Storeroom : "Storeroom",
	RoomType.Office : "Office",
	RoomType.Fitnessroom : "Gym",
	RoomType.Garage : "Garage",
	RoomType.ChildRoom : "Child Room",
	RoomType.Library : "Library",
	RoomType.GamingRoom : "Gaming Cave",
	RoomType.PleasureRoom : "Pleasure Room",
}

const ROOM_PRICE_FACTOR := 200
const ROOM_RENT_FACTOR := 100
func get_price(room_type:int):
	return ROOM_VALUES.get(room_type) * ROOM_PRICE_FACTOR
func get_rent(room_type:int):
	return ROOM_VALUES.get(room_type) * ROOM_RENT_FACTOR

enum HouseholdArchetype {
	StudentFlatShare,
	Apprentice,
	OrdinaryFamily,
	SingleParent,
	YoungCouple,
	Workaholic,
	Polycule,
	ElderlyCouple,
	BigFamily,
	Widow,
	CEO,
	InfluencerCouple,
	Kevin,
	DrugDealer,
	MarathonCouple,
}

const HOUSEHOLD_NAMES := {
	HouseholdArchetype.StudentFlatShare : "Student Flat Share",
	HouseholdArchetype.Apprentice : "Apprentice",
	HouseholdArchetype.OrdinaryFamily : "Ordinary Family",
	HouseholdArchetype.SingleParent : "Single Parent",
	HouseholdArchetype.YoungCouple : "Young Couple",
	HouseholdArchetype.Workaholic : "Workaholic",
	HouseholdArchetype.Polycule : "Polycule",
	HouseholdArchetype.ElderlyCouple : "Elderly Couple",
	HouseholdArchetype.BigFamily : "Big Family",
	HouseholdArchetype.Widow : "Widow",
	HouseholdArchetype.CEO : "CEO",
	HouseholdArchetype.InfluencerCouple : "Influencer Couple",
	HouseholdArchetype.Kevin : "Kevin",
	HouseholdArchetype.DrugDealer : "Drug Dealer",
	HouseholdArchetype.MarathonCouple : "Marathon Couple",
}
#const HouseholdArchetype {
	#StudentFlatShare,
	#Apprentice,
	#OrdinaryFamily,
	#SingleParent,
	#YoungCouple,
	#Workaholic,
	#Polycule,
	#ElderlyCouple,
	#BigFamily,
	#Widow,
	#CEO,
	#InfluencerCouple,
	#Kevin,
	#DrugDealer,
	#MarathonCouple,
#}

const REVEAL_FADE_TIME := 1.0

const MAX_WIDTH := 10
const WIDTH_COORD_LIMIT := Vector2(-10, 10)
const FLOOR_UNIT_WIDTH := 32
const FLOOR_UNIT_HEIGHT := 32
const BUILDING_ORIGIN_POS := Vector2(0, -FLOOR_UNIT_HEIGHT)
const BUILDING_ORIGIN_COORD := Vector2.ZERO

const ROOM_UNIT_PRICE := 50

const NEIGHBOR_OFFSETS := [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT,
]

const ZOOM_MIN := 0.25
const ZOOM_MAX := 8.0
const ZOOM_STEP := 0.025
const CAMERA_MOVE_STEP := 300


const PRICE_PER_HEIGHT := {
	0: 150,
	1: 350,
	2: 500,
	3: 750,
	4: 1000,
	5: 1250,
}
