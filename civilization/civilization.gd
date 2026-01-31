class_name Civilization
extends Node2D

var faction: Constants.Civilization
const chillingDoNothingChance = 0.2

@export var buildingToScene: Dictionary[Constants.BuildingType, PackedScene] = {
	Constants.BuildingType.Campfire: null,
	Constants.BuildingType.Science: null,
	Constants.BuildingType.WatchTower: null,
	Constants.BuildingType.WarriorHut: null,
}

@export var style: Constants.CivilizationStyle
@export var unitScene: PackedScene

@export var hostility = 1.0 # Ranges [0, 1]. How likely this civ is to attack others.
@export var reactivity = 1.0 # Ranges [0, 1]. How likely this civ is to get mad at other civs when the others kill this civ's buildings or troops
@export var level: int = 0
@export var buildingBreakpointsForLevel = [5, 10, 15]

@export var buildingPlaceCooldown: float = 3
var untilBuildingPlaced: float = 3
@export var currentGoal: Constants.CivilizationGoal = Constants.CivilizationGoal.Chilling
@export var reevaluateGoalCooldown: float = 20
var untilReevaluateGoal: float = 5

@export var redirectWarriorCooldown: float = 4
@export var redirectWarriorRandomness: float = 0.2
var untilWarriorsRedirect: float = 4

var activeBuildings: Array = []
var campfire: Campfire

# the specific hostility values against a particular foreign civ.
@export var otherCivToHostilityValue: Dictionary[Constants.Civilization, float] = {
	Constants.Civilization.Red: 0.5,
	Constants.Civilization.Blue: 0.5,
	Constants.Civilization.Green: 0.5,
	Constants.Civilization.Yellow: 0.5,
	Constants.Civilization.Purple: 0,
}


func _ready() -> void:
	untilBuildingPlaced = buildingPlaceCooldown
	untilReevaluateGoal = reevaluateGoalCooldown
	makeCampfire()

func makeCampfire():
	campfire = buildingToScene[Constants.BuildingType.Campfire].instantiate() as Campfire
	campfire.destroyed.connect(queue_free)
	campfire.global_position = global_position
	campfire.civilization = self
	campfire.faction = faction
	activeBuildings.append(campfire)
	World.this.add_child(campfire)

func _process(delta: float) -> void:
	untilBuildingPlaced -= delta
	while untilBuildingPlaced <= 0:
		placeRandomBuilding()
		untilBuildingPlaced += buildingPlaceCooldown
	untilWarriorsRedirect -= delta
	if untilWarriorsRedirect <= 0:
		untilWarriorsRedirect = redirectWarriorCooldown * (1 + redirectWarriorRandomness * randf() - redirectWarriorRandomness / 2)
		chooseWarriorTargets()

func chooseWarriorTargets():
	var myWarriors = World.this.factionToUnits[faction]
	
	var warriorGroupSize = max(int(ceil(sqrt(len(myWarriors)))), 1)
	
	# NOTE: warriorGroups variable should only be used in this method, because warriors may be killed between frames.
	var warriorGroups = formWarriorGroups(myWarriors, warriorGroupSize)
	var sentOutGroups = int(len(warriorGroups) * hostility)
	for i in sentOutGroups:
		var civTarget = World.this.getRandomWeightedCivilizationTarget(faction, otherCivToHostilityValue)
		if civTarget == -1:
			continue
		for w in warriorGroups[i]:
			var warrior: Unit = w as Unit
			warrior.target = World.this.civilizations[civTarget].campfire.global_position # TODO: will become invalid when campfire gone.
	
	

func formWarriorGroups(warriors: Array, groupSize: int) -> Array:
	var groups: Array = []
	for i in (len(warriors) / groupSize):
		groups.append([])
		for j in groupSize:
			var warriorIndex = groupSize * i + j
			if warriorIndex >= len(warriors):
				break
			groups[i].append(warriors[j])
	return groups

func reevaluateCivilizationGoals():
	currentGoal = sampleCivilizationGoal()

func sampleCivilizationGoal():
	return Constants.CivilizationGoal.values().pick_random()

func placeRandomBuilding():
	var chosenBuilding = Constants.BuildingType.None
	
	match currentGoal:
		Constants.CivilizationGoal.Chilling:
			if randf() >= chillingDoNothingChance:
				chosenBuilding = Constants.BuildingType.Campfire # TODO ugly
				while chosenBuilding == Constants.BuildingType.Campfire:
					chosenBuilding = Constants.BuildingType.values().pick_random()
		Constants.CivilizationGoal.War:
			chosenBuilding = Constants.BuildingType.WarriorHut
		Constants.CivilizationGoal.Defense:
			chosenBuilding = Constants.BuildingType.WatchTower if randf() < 0.5 else Constants.BuildingType.WarriorHut
		Constants.CivilizationGoal.Science:
			chosenBuilding = Constants.BuildingType.Science

	if chosenBuilding != Constants.BuildingType.None:
		place(buildingToScene[chosenBuilding])

func place(buildingScene: PackedScene):
	var building = buildingScene.instantiate() as Building
	building.global_position = samplePosForBuilding()
	building.civilization = self
	building.faction = faction
	building.civilizationStyle = style
	activeBuildings.append(building)
	World.this.add_child(building)

func samplePosForBuilding():
	return MyMath.samplePosInsideRadius(campfire.global_position, 100)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		World.this.civilizations.erase(faction)
