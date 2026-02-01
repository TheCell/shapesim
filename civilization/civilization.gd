class_name Civilization
extends Node2D

const DEBUG = true
var debugLabel: Label

var faction: Constants.Civilization
const chillingDoNothingChance = 0.2

@export var buildingToScene: Dictionary[Constants.BuildingType, PackedScene] = {
	Constants.BuildingType.Campfire: null,
	Constants.BuildingType.Science: null,
	Constants.BuildingType.WatchTower: null,
	Constants.BuildingType.WarriorHut: null,
}

@export var style: Constants.CivilizationStyle
@export var personality: Constants.CivilizationPersonality

@export var hostility: float = 1.0 # Ranges [0, 1]. How likely this civ is to attack others.
@export var reactivity: float = 1.0 # Ranges [0, 1]. How likely this civ is to get mad at other civs when the others kill this civ's buildings or troops

@export var buildingPlaceCooldown: float = 3
var untilBuildingPlaced: float = 3
@export var currentGoal: Constants.CivilizationGoal = Constants.CivilizationGoal.Chilling
@export var reevaluateGoalCooldown: float = 5
var untilReevaluateGoal: float = 5

@export var redirectWarriorCooldown: float = 2
@export var redirectWarriorRandomness: float = 0.2
var untilWarriorsRedirect: float = 4

var stats: CivilizationStat = CivilizationStat.new()
var level = 0

var activeBuildings: Array = []
var campfire: Campfire

# the specific hostility values against a particular foreign civ.
@export var otherCivToHostilityValue: Dictionary = {
	Constants.Civilization.Red: 0.5,
	Constants.Civilization.Blue: 0.5,
	Constants.Civilization.Green: 0.5,
	Constants.Civilization.Yellow: 0.5,
	Constants.Civilization.Purple: 0.5,
}

func _ready() -> void:
	personality = Constants.CivilizationPersonality.values().pick_random()
	untilBuildingPlaced = buildingPlaceCooldown
	untilReevaluateGoal = reevaluateGoalCooldown
	makeCampfire()
	if DEBUG:
		var l = Label.new()
		l.z_index = 10
		debugLabel = l
		debugLabel.add_theme_font_size_override("font_size", 12)
		add_child(l)
		
	
func getRandomIncreasableStat():
	return ["health", ""].pick_random()

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
		untilBuildingPlaced += max(buildingPlaceCooldown / stats.buildFrequencyModifier, 1)
	untilWarriorsRedirect -= delta
	if untilWarriorsRedirect <= 0:
		untilWarriorsRedirect = redirectWarriorCooldown * (1 + redirectWarriorRandomness * randf() - redirectWarriorRandomness / 2)
		chooseWarriorTargets()
	untilReevaluateGoal -= delta
	if untilReevaluateGoal <= 0:
		reevaluateCivilizationGoals()
		untilReevaluateGoal = reevaluateGoalCooldown
	showDebugInfo()

func showDebugInfo():
	if debugLabel:
		var s = ["#BUILDINGS = " + str(len(activeBuildings)), "PERSONALITY = " + Constants.CivilizationPersonality.find_key(personality), "GOAL = " + Constants.CivilizationGoal.find_key(currentGoal),]
		if is_instance_valid(campfire):
			s.append("campfire health = " + str(campfire.health))
		for stat in stats.stats:
			s.append("{} = {}".format([stat, stats.get(stat)], "{}"))
		debugLabel.text = "\n".join(s)

func chooseWarriorTargets():
	var myWarriors = World.this.factionToUnits[faction]
	
	var warriorGroupSize = max(int(ceil(sqrt(len(myWarriors)))), 1)
	
	# NOTE: warriorGroups variable should only be used in this method, because warriors may be killed between frames.
	var warriorGroups: Array = []
	formWarriorGroups(myWarriors, warriorGroupSize, warriorGroups)
	var sentOutGroups = int(len(warriorGroups) * hostility)
	for i in sentOutGroups:
		var civTarget = World.this.getRandomWeightedCivilizationTarget(faction, otherCivToHostilityValue)
		if civTarget == -1:
			continue
		for w in warriorGroups[i]:
			var warrior: Unit = w as Unit
			warrior.target = World.this.civilizations[civTarget].campfire.global_position # TODO: will become invalid when campfire gone.
	

	for j in range(sentOutGroups, len(warriorGroups)):
		# other warrior groups stay home, partrolling toward a random destination.
		var patrolPos = MyMath.samplePosInsideRadius(campfire.global_position, stats.getBuildingRange(level))
		for w in warriorGroups[j]:
			w.target = patrolPos


func formWarriorGroups(warriors: Array, groupSize: int, groups: Array) -> Array:
	var currentGroup: Array = []

	for warrior in warriors:
		if warrior.target != Vector2.INF:
			continue

		currentGroup.append(warrior)

		if len(currentGroup) >= groupSize:
			groups.append(currentGroup)
			currentGroup = []

	# Add leftover warriors as a smaller final group
	if len(currentGroup) > 0:
		groups.append(currentGroup)

	return groups


func reevaluateCivilizationGoals():
	Constants.performGoalTransition(self)

func sampleCivilizationGoal():
	return Constants.CivilizationGoal.values().pick_random()

func placeRandomBuilding():
	var chosenBuilding = Constants.BuildingType.None
	
	match currentGoal:
		Constants.CivilizationGoal.Chilling:
			if randf() >= chillingDoNothingChance:
				chosenBuilding = Constants.randomPlacableBuilding()
		Constants.CivilizationGoal.War:
			chosenBuilding = Constants.BuildingType.WarriorHut
		Constants.CivilizationGoal.Defense:
			chosenBuilding = Constants.BuildingType.WatchTower if randf() < 0.7 else Constants.BuildingType.WarriorHut
		Constants.CivilizationGoal.Science:
			chosenBuilding = Constants.BuildingType.Science if randf() < 0.7 else Constants.randomPlacableBuilding()

	if chosenBuilding != Constants.BuildingType.None:
		place(buildingToScene[chosenBuilding])

func place(buildingScene: PackedScene, optional_pos: Vector2 = samplePosForBuilding()):
	var building = buildingScene.instantiate() as Building
	building.global_position = optional_pos
	building.civilization = self
	building.deteriorationCountdown = CivilizationStat.getDecayCountdown(building.buildingType, level)
	building.faction = faction
	building.civilizationStyle = style
	building.health = stats.baseBuildingHealth * CivilizationStat.getBuildingHealthModifierForLevel(level)
	if building is WatchTower:
		(building as WatchTower).shotCooldown /= stats.totalMilitarySpeedModifier(level)
		(building as WatchTower).lastAvailableMilitaryModifier = stats.totalDamageModifier(level)
	elif building is WarriorHut:
		(building as WarriorHut).warriorSpawnCooldown /= stats.totalMilitarySpeedModifier(level)
		(building as WarriorHut).lastAvailableMilitaryModifier = stats.totalDamageModifier(level)
		(building as WarriorHut).lastAvailableWarriorHealth = stats.totalWarriorHealth(level)
	activeBuildings.append(building)
	recalculateLevel()
	World.this.add_child(building)

func samplePosForBuilding():
	return MyMath.samplePosInsideRadius(campfire.global_position, stats.getBuildingRange(level))
	
func buffRandomStat(factor: float, summand: float):
	stats.buffRandomStat(factor, summand)
	for building in activeBuildings: # let's just always update the damage stat
		if building is WarriorHut || building is WatchTower:
			building.lastAvailableMilitaryModifier = stats.totalDamageModifier(level)
		if building is WarriorHut:
			building.lastAvailableWarriorHealth = stats.totalWarriorHealth(level)


func recalculateLevel():
	var buildings = len(activeBuildings)
	var i = 0
	while buildings >= stats.buildingBreakpointsForLevel[i] && i < len(stats.buildingBreakpointsForLevel):
		i += 1
	for building in activeBuildings:
		if building is WarriorHut:
			(building as WarriorHut).lastAvailableMilitaryModifier = stats.totalDamageModifier(level)
			(building as WarriorHut).lastAvailableWarriorHealth = stats.totalWarriorHealth(level)
		elif building is WatchTower:
			(building as WatchTower).lastAvailableMilitaryModifier = stats.totalDamageModifier(level)
	return i

func removeBuilding(b: Building):
	activeBuildings.erase(b)
	recalculateLevel()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		World.this.civilizations.erase(faction)
