class_name Civilization
extends Node2D


enum CivilizationGoal {
	Chilling,
	War,
	Defense,
	Science,
}

enum BuildingType {
	None = -1,
	Campfire,
	Science,
	WatchTower,
	WarriorHut,
}

const chillingDoNothingChance = 0.2

@export var buildingToScene: Dictionary[BuildingType, PackedScene] = {
	BuildingType.Campfire: null,
	BuildingType.Science: null,
	BuildingType.WatchTower: null,
	BuildingType.WarriorHut: null,
}

@export var unitScene: PackedScene

@export var hostility = 1.0 # Ranges [0, 1]. How likely this civ is to attack others.
@export var reactivity = 1.0 # Ranges [0, 1]. How likely this civ is to get mad at other civs when the others kill this civ's buildings or troops
# the specific hostility values against a particular civ.
var hostilityAgainstCiv: Dictionary[int, float] = {
	0: 0.5,
	1: 0.5,
	2: 0.5
}

@export var civilizationLevel: int = 0

@export var buildingPlaceCooldown: float = 3
var untilBuildingPlaced: float = 3
@export var currentCivilizationGoal: CivilizationGoal = CivilizationGoal.Chilling
@export var reevaluateCivilizationGoalCooldown: float = 20
var untilReevaluateCivilizationGoal = 5

var activeBuildings: Array = []
var campfire: Campfire


func _ready() -> void:
	untilBuildingPlaced = buildingPlaceCooldown
	untilReevaluateCivilizationGoal = reevaluateCivilizationGoalCooldown
	makeCampfire()

func makeCampfire():
	campfire = buildingToScene[BuildingType.Campfire].instantiate() as Campfire
	campfire.destroyed.connect(queue_free)
	campfire.global_position = global_position
	activeBuildings.append(campfire)
	World.this.add_child(campfire)

func _process(delta: float) -> void:
	untilBuildingPlaced -= delta
	while untilBuildingPlaced <= 0:
		placeBuilding()
		untilBuildingPlaced += buildingPlaceCooldown
		
func reevaluateCivilizationGoals():
	currentCivilizationGoal = sampleCivilizationGoal()

func sampleCivilizationGoal():
	return CivilizationGoal.values().pick_random()

func placeBuilding():
	var chosenBuilding = BuildingType.None
	
	match currentCivilizationGoal:
		CivilizationGoal.Chilling:
			if randf() >= chillingDoNothingChance:
				chosenBuilding = BuildingType.values().pick_random()
		CivilizationGoal.War:
			chosenBuilding = BuildingType.WarriorHut
		CivilizationGoal.Defense:
			chosenBuilding = BuildingType.WatchTower
		CivilizationGoal.Science:
			chosenBuilding = BuildingType.Science

	if chosenBuilding != BuildingType.None:
		placeCloseby(buildingToScene[chosenBuilding])

func placeCloseby(buildingScene: PackedScene):
	var building = buildingScene.instantiate() as Building
	building.global_position = samplePosForBuilding()
	building.civilization = self
	activeBuildings.append(building)
	World.this.add_child(building)

func samplePosForBuilding():
	return MyMath.samplePosInsideRadius(campfire.global_position, 100)
