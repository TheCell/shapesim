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
	"heal":    Color("#55ff55"),
	"push_pull": Color("#5599ff"),
}

const paletteFilePaths = [
	"res://Sprites/Palettes/aqua.png",
	"res://Sprites/Palettes/flamingo.png",
	"res://Sprites/Palettes/orsage.png",
	"res://Sprites/Palettes/moss.png",
	"res://Sprites/Palettes/lightpurple.png",
]


enum CivilizationGoal {
	Chilling,
	War,
	Defense,
	Science,
}

enum BuildingType {
	None = -1,
	Campfire = 0,
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
	Meteorite,
	Push,
	Pull,
	Duplicate
}

const spriteFolder = "res://Sprites/"

static func getWarriorTexture(civStyle: CivilizationStyle, level: int) -> Texture2D:
	var path = spriteFolder.path_join(CivilizationStyle.find_key(civStyle)).path_join("Warriors").path_join("%s.tres" % [level])
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

# News types and texts
enum NewsType {
	War,
	CivFight,
	CivLevel,
	Push,
	Pull,
	Duplicate,
	Heal
}

const UNIT_DIED := {
	"headlines": [
		"War is war",
		"Nothing new in the west"
	],
	"descriptions": [
		"{COUNT} warriors {DEATH} for a better future.",
		"{COUNT} warriors {DEATH} in a battle.",
	]
}

const UNIT_DIED_IN_CLASH := {
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

const GOD_PUSH := {
	"headlines": [
		"Divine Force Scatters the Battlefield",
		"God's Hand Pushes Back the Masses"
	],
	"descriptions": [
		"{COUNT} units and structures were {DISPLACED} by an invisible force.",
		"Witnesses report {COUNT} entities suddenly {DISPLACED} across the map by divine intervention."
	]
}

const GOD_PULL := {
	"headlines": [
		"Mysterious Attraction Draws Units Together",
		"God's Grasp Pulls Forces Inward"
	],
	"descriptions": [
		"{COUNT} units and buildings were {PULLED} toward a central point against their will.",
		"An inexplicable force {PULLED} {COUNT} entities together in an instant."
	]
}

const GOD_DUPLICATE := {
	"headlines": [
		"Reality Fractures—Duplicates Appear",
		"Miracle or Madness? Entities Doubled"
	],
	"descriptions": [
		"{COUNT} warriors and buildings were {DUPLICATED} in an unprecedented divine act.",
		"Observers question reality itself as {COUNT} entities spontaneously {DUPLICATED}."
	]
}

const GOD_HEAL := {
	"headlines": [
		"Divine Light Restores the Wounded",
		"Miraculous Recovery Sweeps the Land"
	],
	"descriptions": [
		"{COUNT} units and structures were {HEALED} by divine grace.",
		"A healing radiance touched {COUNT} entities, {HEALED} them to full strength."
	]
}

const GENERIC_NEWS := {
	"headlines": [
		"Another Quiet Tick Passes",
		"Tensions Remain Unresolved",
		"Life Continues on the Grid",
		"Scouts Report Nothing Unusual",
		"Borders Hold—for Now",
		"The World Keeps Spinning",
		"Calm Before Something Worse",
		"Activity Observed, Meaning Unclear",
		"Strategists Remain Vigilant",
		"No Major Developments Reported"
	],
	"descriptions": [
		"Units repositioned and supplies were gathered, but no decisive actions were taken. Observers describe the situation as \"temporarily stable.\"",
		"Despite underlying hostility, no significant clashes occurred during this period. Leaders appear to be waiting for an opening.",
		"Buildings deteriorated slightly, warriors marched their usual routes, and the land changed as it always does. Nothing remarkable happened.",
		"Scouting parties returned with reports of normal movement patterns and unchanged borders. Analysts advise continued monitoring.",
		"Minor maneuvers were detected near several hubs, though none resulted in open conflict. Tension remains high.",
		"The passage of time brought small changes across the map, none of which altered the balance of power in a meaningful way.",
		"No breakthroughs, no disasters, and no divine interference were recorded this cycle. The world endures.",
		"Environmental effects continued to shape the terrain while civilizations quietly adjusted their priorities.",
		"Commanders reviewed reports and maintained defensive postures. For now, restraint appears to be the dominant strategy.",
		"All systems continue to operate within expected parameters. The next development remains unpredictable."
	]
}
