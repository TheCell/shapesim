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
			var idx := rng.randi_range(0, tileCoords.size() - 1)
			var atlas_coords: Vector2i = _pick_random_tile_nonzero()
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


func ApplyMeteorImpact(impactPositionLocal: Vector2i, radius: float) -> void:
	radius = radius / 32
	var r := int(ceil(radius))
	var r2 := radius * radius
	
	var impactPosition : Vector2i = local_to_map(impactPositionLocal)
	
	for dx in range(-r, r + 1):
		for dy in range(-r, r + 1):
			var cell := impactPosition + Vector2i(dx, dy)
			
			# bounds check (your bounds are end-exclusive in _ready(), keep consistent)
			if cell.x < 0 or cell.x >= cornerBottomRight.x:
				continue
			if cell.y < 0 or cell.y >= cornerBottomRight.y:
				continue
			
			# circle check
			var d2 := float(dx * dx + dy * dy)
			if d2 > r2:
				continue
			
			# skip empty cells
			var atlas := get_cell_atlas_coords(cell)
			if atlas == Vector2i(-1, -1):
				continue
			
			# decrement atlas x (clamp at 0)
			var new_x : int = max(atlas.x - 1, 0)
			var new_atlas := Vector2i(new_x, atlas.y)
			set_cell(cell, 0, new_atlas)
			
			# record cells that reached x == 0
			if new_x == 0 and not depleted_cells.has(cell):
				depleted_cells[cell] = true
				depleted_cells_array.append(cell)
	
	var stopwatch = Time.get_ticks_msec()
	if !navigationRegion.is_baking():
		navigationRegion.bake_navigation_polygon()
	print("Baked in %s ms" % [Time.get_ticks_msec() - stopwatch])

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



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
