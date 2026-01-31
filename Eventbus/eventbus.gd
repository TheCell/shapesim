class_name Eventbus
extends Node

static var this: Eventbus

func _ready():
	this = self


signal attack_focus(attacker_civ: Constants.Civilization, target_civ: Constants.Civilization, was_god_intervention: bool)
signal unit_died(attacker_civ: Constants.Civilization, attacked_civ: Constants.Civilization, was_god_intervention: bool)
signal civ_reached_level(civ: Constants.Civilization, level: int)
