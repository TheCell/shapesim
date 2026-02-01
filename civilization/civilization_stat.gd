class_name CivilizationStat
extends Resource

@export var buildRangeFromCampfire: float = 200

@export var baseBuildingHealth: int = 100
@export var baseWarriorHealth: int = 100
@export var militaryDamageModifier: float = 1
@export var buildFrequencyModifier: float = 1
@export var militaryActionFrequencyModifier: float = 1
@export var buildingBreakpointsForLevel = [6, 16, 30, 1 << 62]


var stats = [
	"baseBuildingHealth",
	"baseWarriorHealth",
	"militaryDamageModifier",
	"buildFrequencyModifier",
	"militaryActionFrequencyModifier",
]

func buffRandomStat(factor: float, summand: float):
	var stat = stats.pick_random()
	factor = 1.1
	set(stat, get(stat) * factor + summand)

# TODO: stupid code
static func getBuildingHealthModifierForLevel(level: int):
	return 1.2 * level

static func getWarriorHealthModifierForLevel(level: int):
	return 1.1 * level

static func getDamageModifierForLevel(level: int):
	return 1.2 * level
	
static func getMilitaryFrequencyodifierForLevel(level: int):
	return 1.1 * level
	
static func getDecayCountdown(buildingType: Constants.BuildingType, level: int):
	var base = 10
	var r = base + randf() * base * 0.2 - base * 0.1
	var growthByLevel = 1.3
	return pow(growthByLevel, level) * r

func getBuildingRange(level: int):
	return 1.2 * level * buildRangeFromCampfire

func totalDamageModifier(level: int):
	return militaryDamageModifier * getDamageModifierForLevel(level)

func totalMilitarySpeedModifier(level: int):
	return militaryActionFrequencyModifier * getMilitaryFrequencyodifierForLevel(level)

func totalBuildingHealth(level: int):
	return baseBuildingHealth * getBuildingHealthModifierForLevel(level)

func totalWarriorHealth(level: int):
	return baseWarriorHealth * getWarriorHealthModifierForLevel(level)
