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

const NEIGHBOR_OFFSETS := [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT,
]

const ZOOM_MIN := 0.25
const ZOOM_MAX := 4.0
const ZOOM_STEP := 0.025
const CAMERA_MOVE_STEP := 300
