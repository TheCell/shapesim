class_name Eventbus
extends Node

static var this: Eventbus

func _ready():
	this = self

@warning_ignore_start("unused_signal")

signal attack_focus(attacker_civ: Constants.Civilization, target_civ: Constants.Civilization, was_god_intervention: bool)
signal unit_died(attacker_civ: Constants.Civilization, attacked_civ: Constants.Civilization, was_god_intervention: bool)
signal died(unit: Unit)

# might be interesting to aggregate -> "Civ Red lost 20 buildings in a catastrophic war"
signal building_destroyed(attack_civ: Constants.Civilization, attacked_civ: Constants.Civilization, was_god_intervention: bool)
signal building_decayed(civ: Constants.Civilization, buildingType: Constants.BuildingType) # might be interesting to aggregate -> "Civ Blue's infrastructure collapsed overnight"

signal civ_descended_level(civ: Constants.Civilization, level: int)
signal civ_reached_level(civ: Constants.Civilization, level: int)
signal civ_sends_troops(fromCiv: Constants.Civilization, toCiv: Constants.Civilization, troopAmount: int)

signal civ_changes_strategy(
	civ: Constants.Civilization,
	oldStrategy: Constants.CivilizationGoal,
	newStrategy: Constants.CivilizationGoal,
	isSurprising: bool # true if this was an unlikely change (e.g. a Chilling nation changes its style to Science)
)

# A civ decides to fully attack another civ. This does not mean the attacking civ is necessarily sending out troops.
# It just means that *if* the civ sends out troops, it will send them to solely to the receiver.
signal civ_goes_to_war(
	attackingCiv: Constants.Civilization,
	receivingCiv: Constants.Civilization,
)

signal civ_total_troops_equal(civ: Constants.Civilization, amountOfTroops: int)
signal civ_total_buildings_equal(civ: Constants.Civilization, amountOfBuildings: int)


# will be emitted quite frequently (each science building does this every few seconds -> multiple times per second total)
signal civ_science_upgrade(civ: Constants.Civilization, totalStatLevels: int, stats: CivilizationStat)

signal warriors_pushed(count: int)
signal buildings_pushed(count: int)
signal warriors_pulled(count: int)
signal buildings_pulled(count: int)
signal warriors_duplicated(count: int)
signal buildings_duplicated(count: int)
signal warriors_healed(count: int)
signal buildings_healed(count: int)
