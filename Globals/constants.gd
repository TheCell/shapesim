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
	Civilization.Red:    Color("ff4444"),
	Civilization.Blue:   Color("5599ff"),
	Civilization.Green:  Color("349e34ff"),
	Civilization.Yellow: Color("9c9c33ff"),
	Civilization.Purple: Color("c17fdbff"),
}

const EVENT_COLORS := {
	"death":   Color("#ff4444"),
	"science": Color("#66ccff"),
	"event":   Color("9c9c33ff"),
	"heal":    Color("349e34ff"),
	"push_pull": Color("#5599ff"),
}

const civsToPaletteFilePaths = {
	Civilization.Blue: "res://Sprites/Palettes/aqua.png",
	Civilization.Red: "res://Sprites/Palettes/flamingo.png",
	Civilization.Yellow: "res://Sprites/Palettes/orsage.png",
	Civilization.Green: "res://Sprites/Palettes/moss.png",
	Civilization.Purple: "res://Sprites/Palettes/lightpurple.png",
}


enum CivilizationGoal {
	Chilling,
	War,
	Defense,
	Science,
}

enum CivilizationPersonality {
	Fickle,
	Polarizing,
	Secular,
	Normal,
	Conservative,
	WarAvoidant,
}

const personalityTransitionDict = {
		CivilizationPersonality.Fickle: {
			CivilizationGoal.Chilling: {
				CivilizationGoal.Chilling: 0.2,
				CivilizationGoal.War: 1.1,
				CivilizationGoal.Defense: 0.8,
				CivilizationGoal.Science: 1.2
			},
			CivilizationGoal.War: {
				CivilizationGoal.Chilling: 1.0,
				CivilizationGoal.War: 0.2,
				CivilizationGoal.Defense: 2.4,
				CivilizationGoal.Science: 1.2
			},
			CivilizationGoal.Defense: {
				CivilizationGoal.Chilling: 1.1,
				CivilizationGoal.War: 1.0,
				CivilizationGoal.Defense: 0.2,
				CivilizationGoal.Science: 1.3
			},
			CivilizationGoal.Science: {
				CivilizationGoal.Chilling: 1.2,
				CivilizationGoal.War: 1.1,
				CivilizationGoal.Defense: 0.9,
				CivilizationGoal.Science: 0.3
			}
		},
		CivilizationPersonality.Polarizing: {
			CivilizationGoal.Chilling: {
				CivilizationGoal.Chilling: 1.5,
				CivilizationGoal.War: 1.2,
				CivilizationGoal.Defense: 0.2,
				CivilizationGoal.Science: 0.1
			},
			CivilizationGoal.War: {
				CivilizationGoal.Chilling: 0.4,
				CivilizationGoal.War: 2.0,
				CivilizationGoal.Defense: 0.3,
				CivilizationGoal.Science: 0.1
			},
			CivilizationGoal.Defense: {
				CivilizationGoal.Chilling: 0.8,
				CivilizationGoal.War: 0.9,
				CivilizationGoal.Defense: 0.3,
				CivilizationGoal.Science: 0.2
			},
			CivilizationGoal.Science: {
				CivilizationGoal.Chilling: 0.6,
				CivilizationGoal.War: 3.0,
				CivilizationGoal.Defense: 0.2,
				CivilizationGoal.Science: 1.0
			}
		},
		CivilizationPersonality.Secular: {
			CivilizationGoal.Chilling: {
				CivilizationGoal.Chilling: 1.6,
				CivilizationGoal.War: 0.1,
				CivilizationGoal.Defense: 1.2,
				CivilizationGoal.Science: 0.8
			},
			CivilizationGoal.War: {
				CivilizationGoal.Chilling: 0.2,
				CivilizationGoal.War: 4.0,
				CivilizationGoal.Defense: 0.2,
				CivilizationGoal.Science: 1.0
			},
			CivilizationGoal.Defense: {
				CivilizationGoal.Chilling: 1.1,
				CivilizationGoal.War: 0.1,
				CivilizationGoal.Defense: 2.5,
				CivilizationGoal.Science: 0.6
			},
			CivilizationGoal.Science: {
				CivilizationGoal.Chilling: 1.2,
				CivilizationGoal.War: 0.2,
				CivilizationGoal.Defense: 0.9,
				CivilizationGoal.Science: 1.5
			}
		},
		CivilizationPersonality.Normal: {
			CivilizationGoal.Chilling: {
				CivilizationGoal.Chilling: 1.3,
				CivilizationGoal.War: 0.4,
				CivilizationGoal.Defense: 0.9,
				CivilizationGoal.Science: 0.8
			},
			CivilizationGoal.War: {
				CivilizationGoal.Chilling: 0.6,
				CivilizationGoal.War: 1.4,
				CivilizationGoal.Defense: 1.0,
				CivilizationGoal.Science: 0.4
			},
			CivilizationGoal.Defense: {
				CivilizationGoal.Chilling: 0.9,
				CivilizationGoal.War: 0.8,
				CivilizationGoal.Defense: 1.3,
				CivilizationGoal.Science: 0.7
			},
			CivilizationGoal.Science: {
				CivilizationGoal.Chilling: 0.8,
				CivilizationGoal.War: 1.0,
				CivilizationGoal.Defense: 0.7,
				CivilizationGoal.Science: 1.4
			}
		},
		CivilizationPersonality.Conservative: {
			CivilizationGoal.Chilling: {
				CivilizationGoal.Chilling: 3.0,
				CivilizationGoal.War: 0.1,
				CivilizationGoal.Defense: 1.0,
				CivilizationGoal.Science: 0.3
			},
			CivilizationGoal.War: {
				CivilizationGoal.Chilling: 0.2,
				CivilizationGoal.War: 2.5,
				CivilizationGoal.Defense: 0.5,
				CivilizationGoal.Science: 0.1
			},
			CivilizationGoal.Defense: {
				CivilizationGoal.Chilling: 0.7,
				CivilizationGoal.War: 0.3,
				CivilizationGoal.Defense: 2.2,
				CivilizationGoal.Science: 0.4
			},
			CivilizationGoal.Science: {
				CivilizationGoal.Chilling: 0.8,
				CivilizationGoal.War: 0.2,
				CivilizationGoal.Defense: 1.2,
				CivilizationGoal.Science: 4.0
			}
		},
		CivilizationPersonality.WarAvoidant: {
			CivilizationGoal.Chilling: {
				CivilizationGoal.Chilling: 1.6,
				CivilizationGoal.War: 0.05,
				CivilizationGoal.Defense: 1.2,
				CivilizationGoal.Science: 1.0
			},
			CivilizationGoal.War: {
				CivilizationGoal.Chilling: 1.8,
				CivilizationGoal.War: 0.3,
				CivilizationGoal.Defense: 1.6,
				CivilizationGoal.Science: 1.2
			},
			CivilizationGoal.Defense: {
				CivilizationGoal.Chilling: 1.3,
				CivilizationGoal.War: 0.1,
				CivilizationGoal.Defense: 1.7,
				CivilizationGoal.Science: 0.9
			},
			CivilizationGoal.Science: {
				CivilizationGoal.Chilling: 1.2,
				CivilizationGoal.War: 0.05,
				CivilizationGoal.Defense: 1.1,
				CivilizationGoal.Science: 1.5
			}
		}
	}

static func random_enum_except(e, excluded_value: int) -> int:
	var values = []
	for v in e.values():
		if v != excluded_value:
			values.append(v)
	return values.pick_random()

static func performGoalTransition(civilization: Civilization) -> int:
	var personality = civilization.personality
	var currentGoal = civilization.currentGoal
	var transitionDict = personalityTransitionDict[personality][currentGoal]
	var s = 0
	for goal in transitionDict.keys():
		s += transitionDict[goal]
	var r = randf() * s
	var newGoal = -1
	for goal in transitionDict.keys():
		var currentWeight = transitionDict[goal]
		if r < currentWeight:
			newGoal = goal
			break
		r -= currentWeight
		
	
	const genocideChance = 0.2
	var genocideTarget = -1
	
	if newGoal != currentGoal:
		var tryingToGenocide = randf() < genocideChance
		if newGoal == CivilizationGoal.War:
			civilization.hostility = clamp(civilization.hostility * 1.1, 0, 1)
			if tryingToGenocide:
				genocideTarget = random_enum_except(Civilization, civilization.faction)
				civilization.otherCivToHostilityValue[genocideTarget] = 1.0
				for civ in civilization.otherCivToHostilityValue:
					if civ == genocideTarget:
						civilization.otherCivToHostilityValue[civ] = 1.0
					else:
						civilization.otherCivToHostilityValue[civ] = 0.0
		elif newGoal == CivilizationGoal.Defense || newGoal == CivilizationGoal.Chilling:
			civilization.hostility = clamp(civilization.hostility / 1.1, 0, 1)

		if !tryingToGenocide:
			var newDist = mellow_distribution(civilization.otherCivToHostilityValue)
			civilization.otherCivToHostilityValue = newDist
	
	civilization.currentGoal = newGoal
	#print("civ {} (personality {}) from goal {} to goal {}".format([Constants.Civilization.find_key(civilization.faction), Constants.CivilizationPersonality.find_key(civilization.personality), Constants.CivilizationGoal.find_key(currentGoal), Constants.CivilizationGoal.find_key(newGoal)], "{}"))
	return genocideTarget

static func mellow_distribution(
	dict: Dictionary,       # Key -> float (assumed >= 0)
	alpha: float = 0.7,     # < 1 flattens, > 1 sharpens
	flatSum: float = 0.1
) -> Dictionary:
	
	var result = {}

	var sum = 0	
	for k in dict.keys():
		var v = dict[k]
		v = pow(v, alpha) + flatSum
		sum += v
		result[k] = v

	for k in dict.keys():
		result[k] /= sum

	return result

	

enum BuildingType {
	None = -1,
	Campfire = 0,
	Science,
	WatchTower,
	WarriorHut,
}

static var lazyActualBuildingTypes: Array
static func randomPlacableBuilding() -> BuildingType:
	if !lazyActualBuildingTypes:
		lazyActualBuildingTypes = BuildingType.values()
		lazyActualBuildingTypes.erase(BuildingType.None)
		lazyActualBuildingTypes.erase(BuildingType.Campfire)
	return lazyActualBuildingTypes.pick_random()

enum CivilizationStyle {
	Slime,
	Mushroom,
	Frog
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
	if !ResourceLoader.exists(path):
		return load("res://defaultWarriorIcon.png")
	return ResourceLoader.load(path)

static func getBuildingTexture(civStyle: CivilizationStyle, buildingType: BuildingType, level: int) -> Texture2D:
	var path = spriteFolder.path_join(
			CivilizationStyle.find_key(civStyle)
		).path_join(
			BuildingType.find_key(buildingType)
		).path_join("%s.tres" % [level])
	if !ResourceLoader.exists(path):
		return load("res://icon.png")
	return ResourceLoader.load(path)

# News types and texts
enum NewsType {
	War,
	CivFight,
	CivLevel,
	CivLevelDown,
	BuildingDestroyed,
	BuildingDecayed,
	StrategyChange,
	WarDeclaration,
	ScienceBreakthrough,
	Push,
	Pull,
	Duplicate,
	Heal
}

const UNIT_DIED := {
	"headlines": [
		"War is war",
		"Nothing new in the west",
		"Casualties Mount in Latest Engagement",
		"Another Day, Another Battle",
		"Warriors Fail to Return Home",
		"Recruitment Offices Report Increased Demand",
		"Battlefield Cleanup Crews Overwhelmed",
		"The Price of Conflict Rises",
		"Losses Accelerate Across All Fronts",
		"Warriors Make Ultimate Sacrifice"
	],
	"descriptions": [
		"{COUNT} warriors {DEATH} for a better future.",
		"{COUNT} warriors {DEATH} in a battle.",
		"{COUNT} fighters {DEATH} before achieving their objectives.",
		"Military analysts confirm {COUNT} casualties from recent skirmishes.",
		"Families mourn as {COUNT} warriors {DEATH} in the endless conflict.",
		"The steppe claims {COUNT} more souls in today's fighting.",
		"{COUNT} warriors won't be coming home—ever.",
		"Tactical reports confirm {COUNT} combatants {DEATH} in coordinated strikes.",
		"Another {COUNT} lives lost to the unending campaign.",
		"Medics unable to save {COUNT} warriors who {DEATH} on the battlefield."
	]
}

const UNIT_DIED_IN_CLASH := {
	"headlines": [
		"Blood on the Steppe",
		"Skirmish Turns Deadly",
		"Clash Leaves Bodies in Its Wake",
		"Direct Engagement Proves Costly",
		"Battle Lines Drawn in Blood",
		"Opposing Forces Collide",
		"Combat Intensifies Between Rivals",
		"Territorial Dispute Turns Violent",
		"No Quarter Given in Latest Fight",
		"Warriors Fall in Fierce Encounter"
	],
	"descriptions": [
		"{COUNT} warriors {DEATH} as {CIV_A} attacked {CIV_B}.",
		"{CIV_B} suffered heavy losses after an encounter with {CIV_A}.",
		"A brutal clash between {CIV_A} and {CIV_B} claimed {COUNT} lives.",
		"{CIV_A} forces engaged {CIV_B} troops, resulting in {COUNT} fatalities.",
		"The confrontation saw {COUNT} warriors from both sides {DEATH}.",
		"{CIV_B} defenders couldn't hold against {CIV_A}'s assault—{COUNT} {DEATH}.",
		"Witnesses report {COUNT} casualties as {CIV_A} clashed with {CIV_B}.",
		"Strategic engagement between {CIV_A} and {CIV_B} left {COUNT} dead.",
		"{COUNT} warriors {DEATH} in the savage fighting between {CIV_A} and {CIV_B}.",
		"Border skirmish between {CIV_A} and {CIV_B} escalated—{COUNT} {DEATH}."
	]
}

const CIV_LEVEL := {
	"headlines": [
		"{CIV} Reaches New Heights",
		"{CIV} Ascends to Power",
		"Breakthrough for {CIV}",
		"{CIV} Achieves Unprecedented Growth",
		"Power Surge: {CIV} Advances",
		"{CIV} Civilization Enters New Era",
		"Rising Star: {CIV} Levels Up",
		"{CIV} Dominance Increases",
		"Milestone Reached by {CIV}",
		"{CIV} Strengthens Their Position"
	],
	"descriptions": [
		"{CIV} reached level {LEVEL}, worrying nearby civilizations.",
		"{CIV} civilization advanced to level {LEVEL} amid great celebration.",
		"Level {LEVEL} achieved by {CIV}—rivals take notice.",
		"Strategic analysts report {CIV} has ascended to level {LEVEL}.",
		"{CIV} progression to level {LEVEL} marks a turning point in regional power.",
		"Celebrations erupt as {CIV} reaches the prestigious level {LEVEL}.",
		"Neighboring factions grow nervous as {CIV} hits level {LEVEL}.",
		"{CIV} has consolidated power and achieved level {LEVEL} status.",
		"The balance shifts as {CIV} climbs to level {LEVEL}.",
		"Impressive development sees {CIV} reach level {LEVEL} ahead of projections."
	]
}

const CIV_LEVEL_DOWN := {
	"headlines": [
		"{CIV} Suffers Setback",
		"Decline Hits {CIV}",
		"{CIV} Falls from Grace",
		"Weakening Observed in {CIV}",
		"{CIV} Loses Ground",
		"Regression Strikes {CIV}",
		"{CIV} Power Diminishes",
		"Downward Spiral for {CIV}",
		"{CIV} Experiences Collapse",
		"Deterioration Affects {CIV}"
	],
	"descriptions": [
		"{CIV} civilization declined to level {LEVEL} after recent losses.",
		"A crushing blow drops {CIV} to level {LEVEL}.",
		"{CIV} descends to level {LEVEL}—neighbors sense weakness.",
		"Devastating setbacks have reduced {CIV} to level {LEVEL}.",
		"Analysts confirm {CIV} has regressed to level {LEVEL}.",
		"Structural failures force {CIV} down to level {LEVEL}.",
		"{CIV} unable to maintain previous gains, falls to level {LEVEL}.",
		"Opportunistic rivals circle as {CIV} drops to level {LEVEL}.",
		"A series of disasters leaves {CIV} at level {LEVEL}.",
		"Strategic reversals cause {CIV} to descend to level {LEVEL}."
	]
}

const BUILDING_DESTROYED := {
	"headlines": [
		"Infrastructure Under Assault",
		"Buildings Razed in Conflict",
		"Destruction Sweeps the Land",
		"Architecture Meets Artillery",
		"Structures Fall to Enemy Action",
		"Hostile Forces Target Buildings",
		"Construction Undone by Combat",
		"Targeted Demolition Campaign",
		"Buildings Crumble Under Attack",
		"Strategic Assets Eliminated"
	],
	"descriptions": [
		"{COUNT} buildings were destroyed in recent conflicts.",
		"Rubble marks where {COUNT} structures once stood.",
		"Attackers demolished {COUNT} buildings, leaving devastation in their wake.",
		"{COUNT} buildings reduced to ruins amid ongoing hostilities.",
		"Enemy forces systematically destroyed {COUNT} structures.",
		"Coordinated strikes eliminated {COUNT} buildings from the landscape.",
		"Assault teams reported {COUNT} buildings successfully razed.",
		"The toll of war: {COUNT} buildings obliterated.",
		"Infrastructure damage severe—{COUNT} buildings lost to enemy action.",
		"Strategic bombing campaigns resulted in {COUNT} destroyed structures."
	]
}

const BUILDING_DECAYED := {
	"headlines": [
		"Infrastructure Crumbles",
		"Decay Claims Its Victims",
		"Neglect Takes Its Toll",
		"Buildings Fall to Time",
		"Maintenance Failures Pile Up",
		"Age and Wear Win Battle",
		"Structural Integrity Compromised",
		"Rot and Ruin Spread",
		"Buildings Succumb to Entropy",
		"Abandoned Structures Collapse"
	],
	"descriptions": [
		"{COUNT} buildings collapsed due to poor maintenance.",
		"Time and neglect claimed {COUNT} structures across the land.",
		"{COUNT} buildings deteriorated beyond repair.",
		"Structural decay led to the loss of {COUNT} buildings.",
		"Lack of upkeep resulted in {COUNT} structural failures.",
		"{COUNT} buildings gave way after years of deterioration.",
		"Environmental damage and age destroyed {COUNT} buildings.",
		"Inspection reports came too late—{COUNT} buildings already collapsed.",
		"The price of neglect: {COUNT} buildings lost to decay.",
		"Foundation failures and rot claimed {COUNT} structures this cycle."
	]
}

const STRATEGY_CHANGE := {
	"headlines": [
		"{CIV} Shifts Strategy",
		"Policy Change for {CIV}",
		"{CIV} Adopts New Approach",
		"Strategic Pivot by {CIV}",
		"{CIV} Reverses Course",
		"New Direction for {CIV}",
		"{CIV} Redefines Priorities",
		"Unexpected Turn from {CIV}",
		"{CIV} Abandons Old Doctrine",
		"Radical Shift in {CIV} Policy"
	],
	"descriptions": [
		"{CIV} abandoned {OLD_STRATEGY} in favor of {NEW_STRATEGY}.",
		"Surprising shift: {CIV} switches from {OLD_STRATEGY} to {NEW_STRATEGY}.",
		"{CIV} leadership announces transition to {NEW_STRATEGY} policy.",
		"Analysts stunned as {CIV} pivots from {OLD_STRATEGY} to {NEW_STRATEGY}.",
		"{CIV} has officially moved away from {OLD_STRATEGY} toward {NEW_STRATEGY}.",
		"Strategic councils confirm {CIV} transition from {OLD_STRATEGY} to {NEW_STRATEGY}.",
		"Observers note {CIV}'s dramatic shift from {OLD_STRATEGY} to {NEW_STRATEGY}.",
		"{CIV} rejects {OLD_STRATEGY} doctrine, embraces {NEW_STRATEGY} instead.",
		"Policy overhaul sees {CIV} drop {OLD_STRATEGY} for {NEW_STRATEGY}.",
		"Breaking with tradition, {CIV} moves from {OLD_STRATEGY} to {NEW_STRATEGY}."
	]
}

const WAR_DECLARATION := {
	"headlines": [
		"{CIV_A} Declares War on {CIV_B}",
		"Hostilities Begin",
		"{CIV_A} Targets {CIV_B}",
		"War Drums Sound",
		"Open Conflict Erupts",
		"{CIV_A} Mobilizes Against {CIV_B}",
		"Peace Shatters: {CIV_A} vs {CIV_B}",
		"War Declared Between Rivals",
		"{CIV_A} Vows {CIV_B} Destruction",
		"Total War Announced"
	],
	"descriptions": [
		"{CIV_A} officially declared war against {CIV_B}.",
		"All-out conflict as {CIV_A} commits to destroying {CIV_B}.",
		"{CIV_A} leadership vows to eliminate {CIV_B} threat.",
		"Diplomatic relations collapse as {CIV_A} moves against {CIV_B}.",
		"In a stunning announcement, {CIV_A} declared open war on {CIV_B}.",
		"{CIV_A} has committed all resources to the destruction of {CIV_B}.",
		"No turning back: {CIV_A} formally begins hostilities with {CIV_B}.",
		"Strategic command confirms {CIV_A} is now at war with {CIV_B}.",
		"Escalation complete as {CIV_A} declares intent to annihilate {CIV_B}.",
		"Treaties abandoned—{CIV_A} initiates total war against {CIV_B}."
	]
}

const SCIENCE_BREAKTHROUGH := {
	"headlines": [
		"Scientific Progress Reported",
		"Research Yields Results",
		"Knowledge Advances",
		"Innovation Accelerates",
		"Breakthrough Discoveries Made",
		"Technology Leaps Forward",
		"Research Teams Report Success",
		"Scientific Revolution Underway",
		"Knowledge Base Expands",
		"Innovation Wave Continues"
	],
	"descriptions": [
		"{COUNT} major research breakthroughs were achieved.",
		"Scientists celebrate {COUNT} significant discoveries.",
		"{COUNT} technological advances shift the balance of power.",
		"Laboratories produce {COUNT} groundbreaking innovations.",
		"Research institutions report {COUNT} successful experiments.",
		"{COUNT} critical discoveries emerged from ongoing studies.",
		"Technical specialists achieved {COUNT} important milestones.",
		"Knowledge expanded dramatically with {COUNT} new breakthroughs.",
		"Academic communities announce {COUNT} revolutionary findings.",
		"{COUNT} innovations promise to reshape civilization development."
	]
}

const GOD_PUSH := {
	"headlines": [
		"Divine Force Scatters the Battlefield",
		"God's Hand Pushes Back the Masses",
		"Invisible Shove Disrupts Combat",
		"'Did You Feel That?' Ask Confused Warriors",
		"Units Experience Sudden Relocation",
		"Physics Optional, Apparently",
		"God Plays Billiards with Mortals",
		"Mysterious Force Scatters Armies",
		"Divine Disruption Reported",
		"Supernatural Push Detected"
	],
	"descriptions": [
		"{COUNT} units and structures were {DISPLACED} by an invisible force.",
		"Witnesses report {COUNT} entities suddenly {DISPLACED} across the map by divine intervention.",
		"{COUNT} warriors and buildings experienced involuntary relocation.",
		"A mysterious force {DISPLACED} {COUNT} entities in what can only be described as 'divine pest control.'",
		"Strategic positions mean nothing when {COUNT} units get {DISPLACED} by godly whim.",
		"{COUNT} entities learned that free will has its limits.",
		"Personal space violated for {COUNT} units as an invisible hand {DISPLACED} them elsewhere.",
		"Tactical formations shattered as {COUNT} entities were {DISPLACED} by unseen power.",
		"Reality bent as {COUNT} units and buildings were {DISPLACED} without warning.",
		"Command and control lost when {COUNT} entities were {DISPLACED} by divine force."
	]
}

const GOD_PULL := {
	"headlines": [
		"Mysterious Attraction Draws Units Together",
		"God's Grasp Pulls Forces Inward",
		"Unexpected Group Hug Disrupts Warfare",
		"Gravity? No, Something Worse",
		"Divine Vacuum Claims {COUNT} Victims",
		"Entities Experience Involuntary Convergence",
		"'Why Are We All Here?' Wonder Confused Units",
		"Supernatural Magnetism Detected",
		"Divine Attraction Pulls Masses",
		"Forced Convergence Event"
	],
	"descriptions": [
		"{COUNT} units and buildings were {PULLED} toward a central point against their will.",
		"An inexplicable force {PULLED} {COUNT} entities together in an instant.",
		"{COUNT} warriors and structures found themselves suddenly very close to each other.",
		"Personal boundaries mean nothing as {COUNT} entities were {PULLED} into an unwanted gathering.",
		"Strategic dispersion failed when {COUNT} units were {PULLED} together like magnets.",
		"Social distancing impossible after {COUNT} entities were {PULLED} to the same spot.",
		"{COUNT} units experienced what scholars call 'divine clustering.'",
		"Irresistible force {PULLED} {COUNT} entities to a single location.",
		"Physics defied as {COUNT} units and buildings were {PULLED} into tight formation.",
		"Battlefield geometry collapsed when {COUNT} entities were {PULLED} together."
	]
}

const GOD_DUPLICATE := {
	"headlines": [
		"Reality Fractures—Duplicates Appear",
		"Miracle or Madness? Entities Doubled",
		"'I'm Seeing Double' Reports Entire Army",
		"Cloning Technology Obsolete After Divine Act",
		"Identity Crisis Sweeps Battlefield",
		"Philosophers Question Nature of Self",
		"Two for the Price of One (No Refunds)",
		"Divine Replication Event",
		"Instant Doubling Phenomenon",
		"Copies Appear From Nowhere"
	],
	"descriptions": [
		"{COUNT} warriors and buildings were {DUPLICATED} in an unprecedented divine act.",
		"Observers question reality itself as {COUNT} entities spontaneously {DUPLICATED}.",
		"An impossible miracle {DUPLICATED} {COUNT} units, doubling their numbers instantly.",
		"{COUNT} entities met their exact copies and immediately felt awkward about it.",
		"Census takers baffled as {COUNT} units were suddenly {DUPLICATED}.",
		"The concept of 'unique individual' becomes meaningless for {COUNT} {DUPLICATED} entities.",
		"{COUNT} warriors now have trust issues after being {DUPLICATED} without consent.",
		"Supernatural cloning event {DUPLICATED} {COUNT} entities perfectly.",
		"Witnesses stunned as {COUNT} units and structures were {DUPLICATED} instantly.",
		"Existential dread spreads after {COUNT} entities were {DUPLICATED} by divine power."
	]
}

const GOD_HEAL := {
	"headlines": [
		"Divine Light Restores the Wounded",
		"Miraculous Recovery Sweeps the Land",
		"Medical Professionals Suddenly Unemployed",
		"'I Feel Great!' Shout Previously Dying Warriors",
		"Wounds Vanish in Inexplicable Event",
		"Health Insurance Companies Hate This One Trick",
		"Instant Recovery Baffles Military Medics",
		"Divine Restoration Event",
		"Supernatural Healing Reported",
		"Miracle Cure Sweeps Battlefield"
	],
	"descriptions": [
		"{COUNT} units and structures were {HEALED} by divine grace.",
		"A healing radiance touched {COUNT} entities, {HEALED} them to full strength.",
		"{COUNT} wounded warriors were {HEALED} in what can only be called a miracle.",
		"Injuries vanished from {COUNT} units as they were {HEALED} by an unknown power.",
		"{COUNT} entities experienced instant recovery after being {HEALED} by divine light.",
		"Battlefield triage became unnecessary when {COUNT} units were suddenly {HEALED}.",
		"Death itself stepped back as {COUNT} damaged entities were {HEALED} to perfection.",
		"Impossible restoration as {COUNT} units were {HEALED} beyond medical explanation.",
		"Divine intervention {HEALED} {COUNT} entities in the blink of an eye.",
		"Observers report {COUNT} damaged entities were {HEALED} by supernatural means."
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
		"No Major Developments Reported",
		"Civilization Continues to Civilize",
		"Weather: Still Exists",
		"Breaking: Absolutely Nothing Breaks",
		"Existential Dread Remains Constant",
		"War Delayed Due to Scheduling Conflicts",
		"Peace Accidentally Breaks Out",
		"Universe Fails to End, Surprisingly",
		"Local Grass Continues Growing",
		"Steppe Remains Steppy",
		"Time Passes, As Expected",
		"Silence Deafening on All Fronts",
		"Waiting Game Intensifies",
		"Status Quo Maintains Status",
		"Prediction: More of the Same",
		"Absolutely No One Surprised",
		"Boredom Reaches Critical Levels",
		"Plot Thickens (Just Kidding)",
		"Warriors Perfect Standing Still Technique",
		"Diplomatic Relations: Still Awkward",
		"Nothing to See Here, Move Along",
		"Tick Counter Increments Successfully",
		"Reality Check: Everything Normal",
		"Gods Suspected of Napping",
		"Routine Maintenance of Existence",
		"Civilization Collectively Shrugs",
		"News Ticker Runs Out of Ideas",
		"Another Day, Another Tick",
		"Analysts Analyze Nothing in Particular",
		"Strategic Inaction Proves Effective",
		"Peace Treaty Not Needed, Nothing Happening",
		"Watchtowers Report Watching Continues",
		"Military Drills Postponed Indefinitely",
		"Leaders Agree to Disagree Later",
		"Science Buildings Produce Mild Progress",
		"Warriors Practice Patience",
		"Campfires Burn Without Incident",
		"Map Boundaries Remain Where They Were",
		"Pixels Render Flawlessly",
		"Simulation Running Nominally",
		"Background Processes Continue Processing",
		"No Updates Available at This Time"
	],
	"descriptions": [
		"Units repositioned and supplies were gathered, but no decisive actions were taken.",
		"Despite underlying hostility, no significant clashes occurred during this period.",
		"Buildings deteriorated slightly, warriors marched their usual routes, and the land changed as it always does.",
		"Scouting parties returned with reports of normal movement patterns and unchanged borders.",
		"Minor maneuvers were detected near several hubs, though none resulted in open conflict.",
		"The passage of time brought small changes across the map, none of which altered the balance of power.",
		"No breakthroughs, no disasters, and no divine interference were recorded this cycle.",
		"Environmental effects continued to shape the terrain while civilizations quietly adjusted their priorities.",
		"Commanders reviewed reports and maintained defensive postures as restraint appears to be the dominant strategy.",
		"All systems continue to operate within expected parameters and the next development remains unpredictable.",
		"Warriors wandered aimlessly while leaders contemplated the meaning of existence.",
		"Absolutely nothing happened, which is somehow both boring and terrifying.",
		"The gods appear to be on lunch break as normalcy persists.",
		"Units stood around wondering when the next catastrophe would strike.",
		"Civilization proves it can function without constant violence—who knew?",
		"An eerie calm settles over the land, making everyone deeply uncomfortable.",
		"Historians will probably skip this tick entirely when writing the chronicles.",
		"Grass grew at its usual rate while warriors questioned their life choices.",
		"The steppe remained hostile to life, but nobody was around to care today.",
		"Clocks ticked, hearts beat, and absolutely nothing of consequence occurred.",
		"Military bands played soothing music in the absence of battle.",
		"Civilizations stared at each other awkwardly across their borders.",
		"Everything remained exactly as it was, which is either good or ominous.",
		"Seers predict tomorrow will look suspiciously like today.",
		"Even the most optimistic war hawks found nothing to complain about.",
		"Warriors reported feeling 'kinda useless' during the extended peace.",
		"Dramatic music started playing but then stopped when nothing happened.",
		"Units mastered the ancient art of doing absolutely nothing productive.",
		"Ambassadors exchanged pleasantries that meant nothing to anyone.",
		"Observers noted that observing nothing is still technically observing.",
		"The game engine confirmed all loops are looping correctly.",
		"Physics simulations ran without producing any interesting physics.",
		"Divine entities showed no interest in mortal affairs this tick.",
		"Standard operations continued without deviation or excitement.",
		"Citizens collectively wondered if maybe war wasn't so bad after all.",
		"Journalists struggled to make 'nothing happened' sound interesting.",
		"The sun rose, the sun set, and nobody cared about either.",
		"Statistical analysis revealed that boredom is trending upward.",
		"Military strategists strategized about eventually strategizing.",
		"Lawyers drafted a peace treaty nobody asked for.",
		"Guards atop watchtowers fought to stay awake during their shifts.",
		"Training exercises were deemed 'too exciting' and promptly canceled.",
		"All parties agreed that agreement is currently impossible.",
		"Scientists discovered that time passes at approximately one second per second.",
		"Patience proved to be not just a virtue but a requirement.",
		"Fires crackled peacefully while warriors roasted metaphorical marshmallows.",
		"Cartographers confirmed the map still has the same number of tiles.",
		"Every single pixel maintained its assigned color value.",
		"The simulation's frame rate remained stable at acceptable levels.",
		"Background tasks completed their tasks in the background.",
		"The void between news cycles grew uncomfortably long."
	]
}
