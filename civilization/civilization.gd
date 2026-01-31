class_name Civilization
extends Node2D


const chillingDoNothingChance = 0.2

@export var buildingToScene: Dictionary[Constants.BuildingType, PackedScene] = {
	Constants.BuildingType.Campfire: null,
	Constants.BuildingType.Science: null,
	Constants.BuildingType.WatchTower: null,
	Constants.BuildingType.WarriorHut: null,
}

@export var civilizationStyle: Constants.CivilizationStyle
@export var unitScene: PackedScene

@export var hostility = 1.0 # Ranges [0, 1]. How likely this civ is to attack others.
@export var reactivity = 1.0 # Ranges [0, 1]. How likely this civ is to get mad at other civs when the others kill this civ's buildings or troops
@export var level: int = 0

@export var buildingPlaceCooldown: float = 3
var untilBuildingPlaced: float = 3
@export var currentCivilizationGoal: Constants.CivilizationGoal = Constants.CivilizationGoal.Chilling
@export var reevaluateCivilizationGoalCooldown: float = 20
var untilReevaluateCivilizationGoal: float = 5

var activeBuildings: Array = []
var campfire: Campfire

# the specific hostility values against a particular foreign civ.
var otherCivToHostilityValue: Dictionary[Constants.Civilization, float] = {
	Constants.Civilization.Red: 0.5,
	Constants.Civilization.Blue: 0.5,
	Constants.Civilization.Green: 0.5
}


func _ready() -> void:
	untilBuildingPlaced = buildingPlaceCooldown
	untilReevaluateCivilizationGoal = reevaluateCivilizationGoalCooldown
	makeCampfire()

func makeCampfire():
	campfire = buildingToScene[Constants.BuildingType.Campfire].instantiate() as Campfire
	campfire.destroyed.connect(queue_free)
	campfire.global_position = global_position
	campfire.civilization = self
	activeBuildings.append(campfire)
	World.this.add_child(campfire)

func _process(delta: float) -> void:
	untilBuildingPlaced -= delta
	while untilBuildingPlaced <= 0:
		placeRandomBuilding()
		untilBuildingPlaced += buildingPlaceCooldown
		
func reevaluateCivilizationGoals():
	currentCivilizationGoal = sampleCivilizationGoal()

func sampleCivilizationGoal():
	return Constants.CivilizationGoal.values().pick_random()

func placeRandomBuilding():
	var chosenBuilding = Constants.BuildingType.None
	
	match currentCivilizationGoal:
		Constants.CivilizationGoal.Chilling:
			if randf() >= chillingDoNothingChance:
				chosenBuilding = Constants.BuildingType.values().pick_random()
		Constants.CivilizationGoal.War:
			chosenBuilding = Constants.BuildingType.WarriorHut
		Constants.CivilizationGoal.Defense:
			chosenBuilding = Constants.BuildingType.WatchTower
		Constants.CivilizationGoal.Science:
			chosenBuilding = Constants.BuildingType.Science

	if chosenBuilding != Constants.BuildingType.None:
		place(buildingToScene[chosenBuilding])

func place(buildingScene: PackedScene):
	var building = buildingScene.instantiate() as Building
	building.global_position = samplePosForBuilding()
	building.civilization = self
	activeBuildings.append(building)
	World.this.add_child(building)

func samplePosForBuilding():
	return MyMath.samplePosInsideRadius(campfire.global_position, 100)
