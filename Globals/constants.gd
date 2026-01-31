class_name Constants

enum Civilization {
	Red,
	Blue,
	Green,
	Yellow,
	Purple
}

const CIV_NAMES := {
	Civilization.Red: "Red",
	Civilization.Blue: "Blue",
	Civilization.Green: "Green",
	Civilization.Yellow: "Yellow",
	Civilization.Purple: "Purple",
}

const CIV_COLORS := {
	Civilization.Red:    Color("#ff5555"),
	Civilization.Blue:   Color("#5599ff"),
	Civilization.Green:  Color("#55ff99"),
	Civilization.Yellow: Color("#ffff55"),
	Civilization.Purple: Color("#ff66ff"),
}

const EVENT_COLORS := {
	"death":   Color("#ff4444"),
	"science": Color("#66ccff"),
	"event":   Color("#ffff55"),
}

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

enum CivilizationStyle {
	Slime,
	Mushroom,
	FishPeople
}

enum AbilityType{
	Speedup,
	Slowdown,
	Heal,
	Meteorite
}

const spriteFolder = "res://Sprites/"

static func getWarriorTexture(civStyle: CivilizationStyle, level: int) -> Texture2D:
	var path = spriteFolder.path_join(CivilizationStyle.find_key(civStyle)).path_join("Warrior").path_join("%s.tres" % [level])
	if !FileAccess.file_exists(path):
		return load("res://defaultWarriorIcon.png")
	return load(path)

static func getBuildingTexture(civStyle: CivilizationStyle, buildingType: BuildingType, level: int) -> Texture2D:
	var path = spriteFolder.path_join(
			CivilizationStyle.find_key(civStyle)
		).path_join(
			BuildingType.find_key(buildingType)
		).path_join("%s.tres" % [level])
	if !FileAccess.file_exists(path):
		return load("res://icon.png")
	return load(path)

# News texts
const UNIT_DIED := {
	"headlines": [
		"Blood on the Steppe",
		"Skirmish Turns Deadly",
	],
	"descriptions": [
		"{COUNT} warriors {DEATH} as {CIV_A} attacked {CIV_B}.",
        "{CIV_B} suffered heavy losses after an encounter with {CIV_A}."
	]
}

const CIV_LEVEL := {
	"headlines": [
		"{CIV} Reaches New Heights",
	],
	"descriptions": [
        "{CIV} reached level {LEVEL}, worrying nearby civilizations."
	]
}
