class_name GodAbility
extends Node2D

static var this : GodAbility

@export var radius: float = 2.0
@export var speed: float = 200.0 # pixels per second
@export var activeAbility : Constants.AbilityType = Constants.AbilityType.Speedup
@export var abilityCooldown : float = 5
@export var abilityTimer : Timer

@export var healAmount : float
@export var damageAmount : float
@export var pushForce : float
@export var pullForce : float

@export var pushDuration: float = 0.4

var registered_units: Dictionary = {} # id -> WeakRef

# id -> { "tween": Tween, "was_physics": bool }
var _knockbacks: Dictionary = {}

func _enter_tree():
	this = self
	abilityTimer.wait_time = abilityCooldown

func _process(_delta: float) -> void:
	Set_Position(get_global_mouse_position())
	
	match activeAbility : 
		Constants.AbilityType:
			pass

func is_inside_ability(pos: Vector2) -> bool:
	return global_position.distance_to(pos) < radius

func register_unit(node: Node) -> void:
	var id := node.get_instance_id()
	if registered_units.has(id):
		print("somehow unit tried to re-register even though already present????")
		return
	
	registered_units[node.get_instance_id()] = weakref(node)
	
	if node is Unit:
		var warrior : Unit = node
		 
		match activeAbility :
			Constants.AbilityType.Speedup:
				modify_speed_warrior(warrior, 2)
			Constants.AbilityType.Slowdown: 
				modify_speed_warrior(warrior, 0.5)

func deregister_unit(node: Node) -> void:
	
	var id := node.get_instance_id()
	if registered_units.has(id):
		registered_units.erase(id)
		
		if node is Unit:
			var warrior : Unit = node
			match activeAbility :
				Constants.AbilityType.Speedup:
					modify_speed_warrior(warrior, 0.5)
				Constants.AbilityType.Slowdown: 
					modify_speed_warrior(warrior, 2)

func get_units_alive() -> Array[Node2D]:
	var result: Array[Node2D] = []
	for id in registered_units.keys():
		var u := registered_units[id].get_ref() as Node2D
		if u:
			result.append(u)
		else:
			registered_units.erase(id) # cleanup freed ones
	
	return result

func Set_Position(target: Vector2) -> void:
	var to_target := target - global_position
	if to_target.length() < 0.001:
		return
		
	global_position = target

func apply_timed_ability():
	print("timed ability %d" % activeAbility)
	
	
	var units : Array[Node2D] = get_units_alive()
	
	if activeAbility == Constants.AbilityType.Meteorite:
		for unit in units:
			if unit is Unit:
				var warrior : Unit = unit
				hurt_warrior(warrior, damageAmount)
				
				print("hurt warrior %s" + unit.name)
			if unit is Building:
				var building : Building = unit
				hurt_building(building, damageAmount)
				
				print("hurt building %s" + unit.name)
	elif activeAbility == Constants.AbilityType.Heal:
		for unit in units:
			if unit is Unit:
				var warrior : Unit = unit
				heal_warrior(warrior, healAmount)
				
				print("healed warrior %s" % unit.name)
			if unit is Building:
				var building : Building = unit
				heal_building(building, healAmount)
				
				print("healed building %s" % unit.name)
	elif activeAbility == Constants.AbilityType.Push:
		for unit in units:
			if unit is Unit:
				var warrior: Unit = unit
				var dir := warrior.global_position - global_position
				_apply_push_pull(warrior, dir, pushForce)
				
				print("pushed warrior %s" % unit.name)
			elif unit is Building:
				var building: Building = unit
				var dir := building.global_position - global_position
				_apply_push_pull_building(building, dir, pushForce)
				
				print("pushed building %s" % unit.name)
	elif activeAbility == Constants.AbilityType.Pull:
		for unit in units:
			if unit is Unit:
				var warrior: Unit = unit
				var dir := global_position - warrior.global_position
				_apply_push_pull(warrior, dir, pullForce)
				
				print("pulled warrior %s" % unit.name)
			elif unit is Building:
				var building: Building = unit
				var dir := global_position - building.global_position
				_apply_push_pull_building(building, dir, pullForce)
				
				print("pulled building %s" % unit.name)
	elif activeAbility == Constants.AbilityType.Duplicate:
		for unit in units:
				if unit is Unit:
					var warrior : Unit = unit
					WarriorHut.spawn_warrior(unit.global_position, unit.civilization, unit.civilizationStyle)
					print("duplicated enemy %s" % unit.name)
				if unit is Building:
					print("HOW DO I SPAWN A BUILDING SO IT DOES ITS SHIIII")
	
	
	
	pass

func modify_speed_warrior(unit : Unit, mult : float):
	unit.speed = unit.speed * mult

func hurt_warrior(unit: Unit, amount : float):
	unit.hurt(self, amount)

func heal_warrior(unit: Unit, amount : float):
	unit.health += amount

func apply_force_to_warrior(unit: Unit, force : Vector2):
	unit.velocity = force

func hurt_building(building: Building, amount : float):
	building.hurt(amount);

func heal_building(building : Building, amount : float):
	building.health += amount

func _apply_push_pull(warrior: Unit, dir: Vector2, force: float) -> void:
	if not is_instance_valid(warrior):
		return
	
	if dir.length_squared() < 0.0001:
		return
	
	var id := warrior.get_instance_id()
	
	# If this unit is already being pushed/pulled, stop the old tween first.
	if _knockbacks.has(id):
		var old : Dictionary = _knockbacks[id]
		var old_tween: Tween = old.get("tween")
		if old_tween:
			old_tween.kill()
		_restore_after_knockback(id) # restores physics processing
		
	var was_physics := warrior.is_physics_processing()
	warrior.set_physics_process(false) # stop Unit from overwriting velocity / moving via nav
	warrior.velocity = Vector2.ZERO

	# Interpret "force" as pixels/second and convert to displacement over duration.
	var displacement := dir.normalized() * force * pushDuration
	var start_pos := warrior.global_position
	var end_pos := start_pos + displacement
	
	var tween := get_tree().create_tween()
	_knockbacks[id] = { "tween": tween, "kind": "unit", "was_physics": was_physics, "ref": weakref(warrior) }
	
	# Push feels better easing out; pull feels better easing in (optional).
	var ease_type := Tween.EASE_OUT
	var trans_type := Tween.TRANS_SINE
	if activeAbility == Constants.AbilityType.Pull:
		ease_type = Tween.EASE_IN
		
	tween.tween_property(warrior, "global_position", end_pos, pushDuration)\
		.set_trans(trans_type)\
		.set_ease(ease_type)
		
	tween.finished.connect(func():
		_restore_after_knockback(id)
	)

func _apply_push_pull_building(building: Building, dir: Vector2, force: float) -> void:
	if not is_instance_valid(building):
		return
	if dir.length_squared() < 0.0001:
		return
	
	var id := building.get_instance_id()
	
	# If already being pushed/pulled, stop old tween first.
	if _knockbacks.has(id):
		var old: Dictionary = _knockbacks[id]
		var old_tween: Tween = old.get("tween")
		if old_tween:
			old_tween.kill()
		_restore_after_knockback(id)
		
	var was_process := building.is_processing()
	building.set_process(false) # stops overlap repulsion from fighting the tween
	building.overlapVelocityPush = Vector2.ZERO
	
	# Interpret "force" as pixels/second -> displacement over duration
	var displacement := dir.normalized() * force * pushDuration
	var end_pos := building.global_position + displacement
	
	var tween := get_tree().create_tween()
	_knockbacks[id] = { "tween": tween, "kind": "building", "was_process": was_process, "ref": weakref(building) }
	
	var ease_type := Tween.EASE_OUT
	var trans_type := Tween.TRANS_SINE
	if activeAbility == Constants.AbilityType.Pull:
		ease_type = Tween.EASE_IN
	
	tween.tween_property(building, "global_position", end_pos, pushDuration)\
		.set_trans(trans_type)\
		.set_ease(ease_type)
	
	tween.finished.connect(func():
		_restore_after_knockback(id)
	)


func _restore_after_knockback(id: int) -> void:
	if not _knockbacks.has(id):
		return
	
	var data: Dictionary = _knockbacks[id]
	_knockbacks.erase(id)
	
	var wr: WeakRef = data.get("ref")
	var obj :Object = (wr.get_ref() if wr else null)
	if not obj or not is_instance_valid(obj):
		return
	
	var kind: String = data.get("kind", "")
	
	if kind == "unit":
		var was_physics: bool = data.get("was_physics", true)
		(obj as Unit).set_physics_process(was_physics)
	elif kind == "building":
		var was_process: bool = data.get("was_process", true)
		(obj as Building).set_process(was_process)
