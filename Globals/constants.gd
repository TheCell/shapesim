class_name Constants

enum Civilization {
	Red,
	Blue,
	Green,
	Yellow,
	Purple
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

const spriteFolder = "res://Sprites/"

static func getWarriorTexture(civStyle: CivilizationStyle, level: int) -> Texture2D:
	return load(spriteFolder.path_join(CivilizationStyle.find_key(civStyle)).path_join("Warrior").path_join("%s.tres" % [level]))

static func getBuildingTexture(civStyle: CivilizationStyle, buildingType: BuildingType, level: int) -> Texture2D:
	return load(spriteFolder.path_join(
			CivilizationStyle.find_key(civStyle)
		).path_join(
			BuildingType.find_key(buildingType)
		).path_join("%s.tres" % [level])
	)
