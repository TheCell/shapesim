class_name GodAbility
extends Node2D

static var this : GodAbility

@export var ability_config_entries: Array[AbilityResource] = []

var abilityConfigs: Dictionary = {} # AbilityType -> AbilityResource

@export var radiusIncrement : float = 0.2
@export var speed: float = 200.0 # pixels per second
@export var activeAbility : Constants.AbilityType = Constants.AbilityType.Speedup
@export var abilityCooldown : float = 5
@export var abilityTimer : Timer
var currentAbilityConfig = AbilityResource

@export var particleSystem : CPUParticles2D

@export var healAmount : float
@export var damageAmount : float
@export var pushForce : float
@export var pullForce : float

@export var pushDuration: float = 0.4

@export var sprite : Sprite2D
@export var spriteWorldSize : float

#SHAPES
enum AbilityShape { CIRCLE, BOX, ROUNDED_BOX, CAPSULE }

@export var shape: AbilityShape = AbilityShape.CIRCLE

# CIRCLE
@export var circle_radius: float = 64.0

# BOX / ROUNDED_BOX (half extents)
@export var box_half_size: Vector2 = Vector2(64, 32)
@export var box_round_radius: float = 8.0

# CAPSULE (segment from -a to +a in local space, plus radius)
@export var capsule_half_segment: Vector2 = Vector2(60, 0) # along local X by default
@export var capsule_radius: float = 16.0


var registered_units: Dictionary = {} # id -> WeakRef

# id -> { "tween": Tween, "was_physics": bool }
var _knockbacks: Dictionary = {}

func _enter_tree():
	this = self
	abilityTimer.wait_time = abilityCooldown

func _input(event):
	
	if event.is_action_pressed("IncrementRadius") :
		update_ability_sizes(1 + radiusIncrement)
	elif event.is_action_pressed("DecrementRadius") :
		update_ability_sizes(1 - radiusIncrement)

func _ready() -> void:
	abilityConfigs.clear()
	
	print("ability_config_entries size = ", ability_config_entries.size())
	
	for i in range(ability_config_entries.size()):
		var e := ability_config_entries[i]
		if e == null:
			push_warning("ability_config_entries[%d] is null" % i)
			continue
		
		print("entry[%d] type=%s abilityType=%s (%d)" % [
			i,
			e.get_class(),
			Constants.AbilityType.keys()[int(e.abilityType)],
			int(e.abilityType)
		])
		
		# Guard against duplicate keys
		if abilityConfigs.has(int(e.abilityType)):
			push_warning("Duplicate abilityType: %s - overwriting previous config" % Constants.AbilityType.keys()[int(e.abilityType)])
		
		abilityConfigs[int(e.abilityType)] = e
		
		set_ability_shape(shape)
	
	
	print("abilityConfigs keys = ", abilityConfigs.keys())
	
	set_active_ability(activeAbility)

func update_ability_sizes(modifier : float) :
	circle_radius *= modifier
	capsule_radius *= modifier
	capsule_half_segment *= modifier
	box_round_radius *= modifier
	box_half_size *= modifier
	
	set_shader_sizes()
	


func _process(_delta: float) -> void:
	Set_Position(get_global_mouse_position())
	
	match activeAbility : 
		Constants.AbilityType:
			pass

func is_inside_ability(pos_global: Vector2) -> bool:
	return sdf_world(pos_global) <= 0.0


func register_unit(node: Node) -> void:
	var id := node.get_instance_id()
	if registered_units.has(id):
		return
	
	registered_units[node.get_instance_id()] = weakref(node)
	
	if node is Unit:
		var warrior : Unit = node
		 
		match activeAbility :
			Constants.AbilityType.Speedup:
				modify_speed_warrior(warrior, 2)
			Constants.AbilityType.Slowdown: 
				modify_speed_warrior(warrior, 0.5)
	elif node is Building:
		var building: Building = node
		match activeAbility:
			Constants.AbilityType.Speedup:
				modify_detirioration_building(building, 2)
			Constants.AbilityType.Slowdown:
				modify_detirioration_building(building, 0.5)
		if node is WarriorHut:
			var hut: WarriorHut = node
			match activeAbility:
				Constants.AbilityType.Speedup:
					modify_warrior_hut_production(hut, 0.5)
				Constants.AbilityType.Slowdown:
					modify_warrior_hut_production(hut, 2)

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
		elif node is Building:
			var building: Building = node
			match activeAbility:
				Constants.AbilityType.Speedup:
					modify_detirioration_building(building, 0.5)
				Constants.AbilityType.Slowdown:
					modify_detirioration_building(building, 2)
			if node is WarriorHut:
				var hut: WarriorHut = node
				match activeAbility:
					Constants.AbilityType.Speedup:
						modify_warrior_hut_production(hut, 2)
					Constants.AbilityType.Slowdown:
						modify_warrior_hut_production(hut, 0.5)

func get_units_alive() -> Array[Node2D]:
	var result: Array[Node2D] = []
	for id in registered_units.keys():
		var u := registered_units[id].get_ref() as Node2D
		if u:
			result.append(u)
		else:
			registered_units.erase(id) # cleanup freed ones
	
	return result

func set_active_ability(abilityType : Constants.AbilityType) -> void:
	activeAbility = abilityType 
	
	currentAbilityConfig = abilityConfigs[activeAbility]
	particleSystem.color = currentAbilityConfig.abilityColour
	
	if activeAbility == Constants.AbilityType.Speedup or activeAbility == Constants.AbilityType.Slowdown :
		particleSystem.emitting = true
	else :
		particleSystem.emitting = false
	
func set_ability_shape(newAbilityShape : AbilityShape) -> void:
	shape = newAbilityShape

	var mat := sprite.material as ShaderMaterial
	if not mat:
		push_error("Sprite material is not a ShaderMaterial!")
		return
	
	# Set the shape type
	mat.set_shader_parameter("sdf_type", int(shape))
	
	set_shader_sizes()

func set_shader_sizes() :
	
	var mat := sprite.material as ShaderMaterial
	# Set the size based on the shape
	match shape:
		AbilityShape.CIRCLE:
			var size_in_uv = circle_radius / spriteWorldSize
			mat.set_shader_parameter("sdf_size", size_in_uv)
			
		AbilityShape.BOX:
			# Box uses half-size, so we need to convert both dimensions
			var size_in_uv = box_half_size.x / spriteWorldSize
			mat.set_shader_parameter("sdf_size", size_in_uv)
			
		AbilityShape.ROUNDED_BOX:
			var size_in_uv = box_half_size.x / spriteWorldSize
			var round_in_uv = box_round_radius / spriteWorldSize
			mat.set_shader_parameter("sdf_size", size_in_uv)
			mat.set_shader_parameter("shape_param", round_in_uv)
			
		AbilityShape.CAPSULE:
			var size_in_uv = capsule_radius / spriteWorldSize
			var point_a_uv = -capsule_half_segment / spriteWorldSize
			var point_b_uv = capsule_half_segment / spriteWorldSize
			mat.set_shader_parameter("sdf_size", size_in_uv)
			mat.set_shader_parameter("capsule_point_a", point_a_uv)
			mat.set_shader_parameter("capsule_point_b", point_b_uv)



func Set_Position(target: Vector2) -> void:
	var to_target := target - global_position
	if to_target.length() < 0.001:
		return
		
	global_position = target

func apply_timed_ability():
	var units : Array[Node2D] = get_units_alive()
	var activatedAbility : bool = false
	
	if activeAbility == Constants.AbilityType.Meteorite:
		activatedAbility = true
		GroundController.this.ApplyMeteorImpact(global_position)
		for unit in units:
			if GroundController.this and GroundController.this.is_world_pos_void(unit.global_position):
				unit.queue_free()
				continue
			
			if unit is Unit:
				var warrior : Unit = unit
				hurt_warrior(warrior, max(damageAmount, warrior.health_bar.max_value / 3))
			elif unit is Building:
				var building : Building = unit
				hurt_building(building, max(damageAmount, building.health_bar.max_value / 3))
	elif activeAbility == Constants.AbilityType.Heal:
		activatedAbility = true
		var warrior_count := 0
		var building_count := 0
		for unit in units:
			if unit is Unit:
				var warrior : Unit = unit
				heal_warrior(warrior, healAmount)
				warrior_count += 1
			if unit is Building:
				var building : Building = unit
				heal_building(building, healAmount)
				building_count += 1
				
		Eventbus.this.warriors_healed.emit(warrior_count)
		Eventbus.this.buildings_healed.emit(building_count)
		
	elif activeAbility == Constants.AbilityType.Push:
		activatedAbility = true
		var warrior_count := 0
		var building_count := 0
		for unit in units:
			if unit is Unit:
				var warrior: Unit = unit
				var dir := warrior.global_position - global_position
				_apply_push_pull(warrior, dir, pushForce)
				warrior_count += 1
			elif unit is Building:
				var building: Building = unit
				var dir := building.global_position - global_position
				_apply_push_pull_building(building, dir, pushForce)
				building_count += 1
				
		Eventbus.this.warriors_pushed.emit(warrior_count)
		Eventbus.this.buildings_pushed.emit(building_count)
		
	elif activeAbility == Constants.AbilityType.Pull:
		activatedAbility = true
		var warrior_count := 0
		var building_count := 0
		for unit in units:
			if unit is Unit:
				var warrior: Unit = unit
				var dir := global_position - warrior.global_position
				_apply_push_pull(warrior, dir, pullForce)
				warrior_count += 1
			elif unit is Building:
				var building: Building = unit
				var dir := global_position - building.global_position
				_apply_push_pull_building(building, dir, pullForce)
				building_count += 1
				
		Eventbus.this.warriors_pulled.emit(warrior_count)
		Eventbus.this.buildings_pulled.emit(building_count)
		
	elif activeAbility == Constants.AbilityType.Duplicate:
		activatedAbility = true
		var warrior_count := 0
		var building_count := 0
		for unit in units:
				if unit is Unit:
					var warrior : Unit = unit
					WarriorHut.spawn_warrior(unit.global_position, unit.civilization, unit.civilizationStyle)
					warrior_count += 1
				elif unit is Building && !(unit is Campfire):
					var building: Building = unit
					building_count += 1
					if building.civilization:
						building.civilization.place(load(building.scene_file_path), building.global_position + Vector2(randf() - 0.5, randf() - 0.5))
					
		Eventbus.this.warriors_duplicated.emit(warrior_count)
		Eventbus.this.buildings_duplicated.emit(building_count)
	
	if activatedAbility :
		particleSystem.emitting = true
		
		await get_tree().create_timer(0.5).timeout
		
		particleSystem.emitting = false
	
	pass

func modify_speed_warrior(unit : Unit, mult : float):
	unit.speed = unit.speed * mult

func modify_warrior_hut_production(hut: WarriorHut, mult: float) -> void:
	hut.warriorSpawnCooldown = hut.warriorSpawnCooldown * mult

func modify_detirioration_building(building: Building, mult: float) -> void:
	building.multiplier = mult

func hurt_warrior(unit: Unit, amount : float):
	unit.hurt(self, amount)

func heal_warrior(unit: Unit, amount : float):
	unit.heal(amount)

func apply_force_to_warrior(unit: Unit, force : Vector2):
	unit.velocity = force

func hurt_building(building: Building, amount : float):
	building.hurt(amount);

func heal_building(building : Building, amount : float):
	building.heal(amount)

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

#ABILITY SHAPES

func sdf_world(pos_global: Vector2) -> float:
	# Convert world point to ability-local space.
	# This makes shapes rotate with your Node2D automatically.
	var p_local: Vector2 = global_transform.affine_inverse() * pos_global
	return sdf_local(p_local)

func sdf_local(p: Vector2) -> float:
	match shape:
		AbilityShape.CIRCLE:
			return sdf_circle(p, circle_radius)
		AbilityShape.BOX:
			return sdf_box(p, box_half_size)
		AbilityShape.ROUNDED_BOX:
			return sdf_rounded_box(p, box_half_size, box_round_radius)
		AbilityShape.CAPSULE:
			# capsule segment endpoints in local space
			var a := -capsule_half_segment
			var b :=  capsule_half_segment
			return sdf_capsule(p, a, b, capsule_radius)
		_ :
			return INF

#SDF CALCULATION METHODS

static func sdf_circle(p: Vector2, r: float) -> float:
	return p.length() - r

static func sdf_box(p: Vector2, b: Vector2) -> float:
	# Axis-aligned box centered at origin, with half-size b.
	var q := Vector2(absf(p.x), absf(p.y)) - b
	var outside := Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length()
	var inside := minf(maxf(q.x, q.y), 0.0)
	return outside + inside

static func sdf_rounded_box(p: Vector2, b: Vector2, r: float) -> float:
	# Rounded corners: box half-size b, corner radius r.
	var q := Vector2(absf(p.x), absf(p.y)) - (b - Vector2(r, r))
	var outside := Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length()
	var inside := minf(maxf(q.x, q.y), 0.0)
	return outside + inside - r

static func sdf_capsule(p: Vector2, a: Vector2, b: Vector2, r: float) -> float:
	# Distance to segment AB minus radius.
	var pa := p - a
	var ba := b - a
	var h : float = clamp(pa.dot(ba) / ba.dot(ba), 0.0, 1.0)
	return (pa - ba * h).length() - r
