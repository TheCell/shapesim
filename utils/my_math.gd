class_name MyMath


static func samplePosInsideRadius(pos: Vector2, radius: float) -> Vector2:
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	return pos + Vector2(cos(angle), sin(angle)) * r
