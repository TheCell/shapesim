class_name CivilizationStat
extends Resource

@export var buildRangeFromCampfire: float = 150

@export var baseBuildingHealth: int = 100
@export var baseWarriorHealth: int = 100
@export var militaryDamageModifier: float = 1
@export var buildFrequencyModifier: float = 1
@export var militaryActionFrequencyModifier: float = 1
@export var buildingBreakpointsForLevel = [10, 30, 1 << 62]

var totalBuffCount = 0
var lazyBaseStats: Dictionary[String, float] = {}

var stats = [
	"baseBuildingHealth",
	"baseWarriorHealth",
	"militaryDamageModifier",
	"buildFrequencyModifier",
	"militaryActionFrequencyModifier",
]

func buffRandomStat(factor: float, summand: float):
	totalBuffCount += 1
	var stat = stats.pick_random()
	if !lazyBaseStats.has(stat):
		lazyBaseStats[stat] = get(stat)
	set(stat, get(stat) + factor * lazyBaseStats[stat])

# TODO: stupid code
static func getBuildingHealthModifierForLevel(level: int):
	return pow(1.2, level)

static func getWarriorHealthModifierForLevel(level: int):
	return pow(1.1, level)

static func getDamageModifierForLevel(level: int):
	return pow(1.2, level)
	
static func getMilitaryFrequencyModifierForLevel(level: int):
	return pow(1.1, level)
	
static func getDecayCountdown(buildingType: Constants.BuildingType, level: int):
	var base = 20
	var r = base + randf() * base * 0.2 - base * 0.1
	var growthByLevel = 1.3
	return pow(growthByLevel, level) * r

func getBuildingRange(level: int):
	return pow(1.2, level) * buildRangeFromCampfire

func totalDamageModifier(level: int):
	return militaryDamageModifier * getDamageModifierForLevel(level)

func totalMilitarySpeedModifier(level: int):
	return militaryActionFrequencyModifier * getMilitaryFrequencyModifierForLevel(level)

func totalBuildingHealth(level: int):
	return baseBuildingHealth * getBuildingHealthModifierForLevel(level)

func totalWarriorHealth(level: int):
	return baseWarriorHealth * getWarriorHealthModifierForLevel(level)
