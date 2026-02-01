class_name GroundController
extends TileMapLayer

static var this : GroundController

@export var tileCoords : Array[Vector2i]
@export var cornerBottomRight : Vector2i
@onready var navigationRegion : NavigationRegion2D = $".."

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var depleted_cells: Dictionary = {}        # Vector2i -> true (hashset)
var depleted_cells_array: Array[Vector2i] = []  # positions in order (optional but requested)

func _enter_tree():
	this = self

func _ready():
	rng.randomize()
	
	clear()
	
	for x in range(0, cornerBottomRight.x):
		for y in range(0, cornerBottomRight.y):
			var atlas_coords: Vector2i = tileCoords[tileCoords.size() - 1]
			set_cell(Vector2i(x, y), 0, atlas_coords) # alternative_tile defaults to 0
	
	navigationRegion.bake_navigation_polygon()

# NEW: refill all recorded positions, avoid atlas coords (0,0), then clear the dictionary
func RefillDepletedCells() -> void:
	for cell in depleted_cells.keys():
		var atlas_coords := _pick_random_tile_nonzero()
		if atlas_coords != Vector2i(0, 0):
			set_cell(cell, 0, atlas_coords)
	
	depleted_cells.clear()
	depleted_cells_array.clear()


func ApplyMeteorImpact(impactPositionLocal: Vector2, _radius_unused: float = 0.0) -> void:
	# We now respect GodAbility's SDF shape. Radius parameter is ignored on purpose.
	if GodAbility.this == null:
		return
	
	var ability := GodAbility.this
	
	# Tile size (world units / pixels) — you said 32 px
	var cell_size: Vector2 = Vector2(32, 32)
	
	# Padding so partially overlapping tiles count as "hit".
	# Half-diagonal (~22.6 px) feels best for corners.
	var padding: float = cell_size.length() * 0.5
	
	# Impact center in map space
	var impact_cell: Vector2i = local_to_map(impactPositionLocal)
	
	# Conservative scan radius in world units from the current shape,
	# then convert to cell radius for iteration.
	var scan_extent_world: float = 0.0
	match ability.shape:
		ability.AbilityShape.CIRCLE:
			scan_extent_world = ability.circle_radius
		ability.AbilityShape.BOX:
			scan_extent_world = maxf(ability.box_half_size.x, ability.box_half_size.y)
		ability.AbilityShape.ROUNDED_BOX:
			scan_extent_world = maxf(ability.box_half_size.x, ability.box_half_size.y) + ability.box_round_radius
		ability.AbilityShape.CAPSULE:
			scan_extent_world = ability.capsule_half_segment.length() + ability.capsule_radius
		_:
			scan_extent_world = 0.0
	
	# Add padding to the scan extent so we don't miss edge tiles
	scan_extent_world += padding
	
	var r_cells_x := int(ceili(scan_extent_world / cell_size.x)) + 1
	var r_cells_y := int(ceili(scan_extent_world / cell_size.y)) + 1
	
	for dx in range(-r_cells_x, r_cells_x + 1):
		for dy in range(-r_cells_y, r_cells_y + 1):
			var cell := impact_cell + Vector2i(dx, dy)
			
			# bounds check
			if cell.x < 0 or cell.x >= cornerBottomRight.x:
				continue
			if cell.y < 0 or cell.y >= cornerBottomRight.y:
				continue
			
			# Compute cell center in GLOBAL coords
			var cell_local_center: Vector2 = map_to_local(cell) + cell_size * 0.5
			var cell_global_center: Vector2 = to_global(cell_local_center)
			
			# SDF padded test: inside if distance <= padding
			# (negative is inside, small positive means "near edge", include those tiles too)
			if ability.sdf_world(cell_global_center) > padding:
				continue
			
			# skip empty cells
			var atlas := get_cell_atlas_coords(cell)
			if atlas == Vector2i(-1, -1):
				continue
			
			# decrement atlas x (clamp at 0)
			var new_x: int = max(atlas.x - 1, 0)
			set_cell(cell, 0, Vector2i(new_x, atlas.y))
			
			# record cells that reached x == 0
			if new_x == 0 and not depleted_cells.has(cell):
				depleted_cells[cell] = true
				depleted_cells_array.append(cell)
	
	#var stopwatch = Time.get_ticks_msec()
	if !navigationRegion.is_baking():
		navigationRegion.bake_navigation_polygon()
	#print("Baked in %s ms" % [Time.get_ticks_msec() - stopwatch])



# NEW: helper – pick a random tile that is NOT (0, 0)
func _pick_random_tile_nonzero() -> Vector2i:
	if tileCoords.is_empty():
		return Vector2i(0, 0)
	
	var tries := 0
	while tries < 32:
		var idx := rng.randi_range(0, tileCoords.size() - 1)
		var c: Vector2i = tileCoords[idx]
		if c != Vector2i(0, 0):
			return c
		tries += 1
	
	# fallback: first non-(0,0) if RNG keeps hitting it
	for c in tileCoords:
		if c != Vector2i(0, 0):
			return c
	
	return Vector2i(0, 0)
