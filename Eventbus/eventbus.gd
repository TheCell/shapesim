extends Node

enum Civilization {
	Red,
	Blue,
	Green,
	Yellow,
	Purple
}

signal attack_focus(civilization: Civilization)
signal unit_died_for_civ(civilization: Civilization)
signal civ_reached_level(level: int)
