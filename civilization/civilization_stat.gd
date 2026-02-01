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
	set(stat, get(stat) * factor + summand)

# TODO: stupid code
static func getBuildingHealthModifierForLevel(level: int):
	return pow(1.2, level)

static func getWarriorHealthModifierForLevel(level: int):
	return pow(1.1, level)

static func getDamageModifierForLevel(level: int):
	return pow(1.2, level)
	
static func getMilitaryFrequencyodifierForLevel(level: int):
	return pow(1.1, level)

func getBuildingRange(level: int):
	return pow(1.2, level) * buildRangeFromCampfire

func totalDamageModifier(level: int):
	return militaryDamageModifier * getDamageModifierForLevel(level)

func totalMilitarySpeedModifier(level: int):
	return militaryActionFrequencyModifier * getMilitaryFrequencyodifierForLevel(level)

func totalBuildingHealth(level: int):
	return baseBuildingHealth * getBuildingHealthModifierForLevel(level)

func totalWarriorHealth(level: int):
	return baseWarriorHealth * getWarriorHealthModifierForLevel(level)
