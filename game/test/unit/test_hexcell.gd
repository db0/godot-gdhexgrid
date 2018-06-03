extends "res://addons/gut/test.gd"

class TestConversions:
	extends "res://addons/gut/test.gd"
	
	var HexCell = load("res://HexCell.gd")
	var cell
	
	func setup():
		cell = HexCell.new()
		
	
	func test_axial_to_cube():
		assert_eq(cell.axial_to_cube_coords(Vector2(2, 1)), Vector3(2, 1, -3))
		assert_eq(cell.axial_to_cube_coords(Vector2(-1, -1)), Vector3(-1, -1, 2))
		
	func test_rounding():
		assert_eq(cell.round_coords(Vector3(0.1, 0.5, -0.6)), Vector3(0, 1, -1))
		assert_eq(cell.round_coords(Vector3(-0.4, -1.3, 1.7)), Vector3(-1, -1, 2))
		
		assert_eq(cell.round_coords(Vector2(-0.1, 0.6)), Vector3(0, 1, -1))
		assert_eq(cell.round_coords(Vector2(4.2, -5.5)), Vector3(4, -5, 1))
		
	
class TestCoords:
	extends "res://addons/gut/test.gd"
	
	var HexCell = load("res://HexCell.gd")
	var cell
	
	func setup():
		cell = HexCell.new()
		
	
	func test_from_cubic_positive():
		cell.cube_coords = Vector3(2, 1, -3)
		assert_eq(cell.cube_coords, Vector3(2, 1, -3))
		assert_eq(cell.axial_coords, Vector2(2, 1))
		assert_eq(cell.offset_coords, Vector2(2, 2))
	func test_from_cubic_negative():
		cell.cube_coords = Vector3(-1, -1, 2)
		assert_eq(cell.cube_coords, Vector3(-1, -1, 2))
		assert_eq(cell.axial_coords, Vector2(-1, -1))
		assert_eq(cell.offset_coords, Vector2(-1, -2))
	func test_from_cubic_invalid():
		cell.cube_coords = Vector3(1, 2, 3)
		assert_eq(cell.cube_coords, Vector3(0, 0, 0))
		
	func test_from_axial_positive():
		cell.axial_coords = Vector2(2, 1)
		assert_eq(cell.cube_coords, Vector3(2, 1, -3))
		assert_eq(cell.axial_coords, Vector2(2, 1))
		assert_eq(cell.offset_coords, Vector2(2, 2))
	func test_from_axial_negative():
		cell.axial_coords = Vector2(-1, -1)
		assert_eq(cell.cube_coords, Vector3(-1, -1, 2))
		assert_eq(cell.axial_coords, Vector2(-1, -1))
		assert_eq(cell.offset_coords, Vector2(-1, -2))
		
	func test_from_offset_positive():
		cell.offset_coords = Vector2(2, 2)
		assert_eq(cell.cube_coords, Vector3(2, 1, -3))
		assert_eq(cell.axial_coords, Vector2(2, 1))
		assert_eq(cell.offset_coords, Vector2(2, 2))
	func test_from_offset_negative():
		cell.offset_coords = Vector2(-1, -2)
		assert_eq(cell.cube_coords, Vector3(-1, -1, 2))
		assert_eq(cell.axial_coords, Vector2(-1, -1))
		assert_eq(cell.offset_coords, Vector2(-1, -2))
		
	
class TestAdjacent:
	extends "res://addons/gut/test.gd"
	
	var HexCell = load("res://HexCell.gd")
	var cell
	
	func setup():
		cell = HexCell.new(Vector2(1, 2))
	
	func test_adjacent():
		var foo = cell.get_adjacent(HexCell.DIR_N)
		assert_eq(foo.axial_coords, Vector2(1, 3))
		foo = cell.get_adjacent(HexCell.DIR_NE)
		assert_eq(foo.axial_coords, Vector2(2, 2))
		foo = cell.get_adjacent(HexCell.DIR_SE)
		assert_eq(foo.axial_coords, Vector2(2, 1))
		foo = cell.get_adjacent(HexCell.DIR_S)
		assert_eq(foo.axial_coords, Vector2(1, 1))
		foo = cell.get_adjacent(HexCell.DIR_SW)
		assert_eq(foo.axial_coords, Vector2(0, 2))
		foo = cell.get_adjacent(HexCell.DIR_NW)
		assert_eq(foo.axial_coords, Vector2(0, 3))
	func test_not_really_adjacent():
		var foo = cell.get_adjacent(Vector3(-3, -3, 6))
		assert_eq(foo.axial_coords, Vector2(-2, -1))
	func test_adjacent_axial():
		var foo = cell.get_adjacent(Vector2(1, 1))
		assert_eq(foo.axial_coords, Vector2(2, 3))
		
	func test_all_adjacent():
		var coords = []
		for foo in cell.get_all_adjacent():
			coords.append(foo.axial_coords)
		assert_has(coords, Vector2(1, 3))
		assert_has(coords, Vector2(2, 2))
		assert_has(coords, Vector2(2, 1))
		assert_has(coords, Vector2(1, 1))
		assert_has(coords, Vector2(0, 2))
		assert_has(coords, Vector2(0, 3))
		
	
class TestBetweenTwo:
	extends "res://addons/gut/test.gd"
	
	var HexCell = load("res://HexCell.gd")
	var cell
	
	func setup():
		cell = HexCell.new(Vector2(1, 2))
	
	func test_distance():
		assert_eq(cell.distance_to(Vector2(0, 0)), 3)
		assert_eq(cell.distance_to(Vector2(3, 4)), 4)
		assert_eq(cell.distance_to(Vector2(-1, -1)), 5)
		
	func test_line_straight():
		# Straight line, nice and simple
		var expected = [
			Vector2(1, 2),
			Vector2(2, 2),
			Vector2(3, 2),
			Vector2(4, 2),
			Vector2(5, 2),
		]
		var path = cell.line_to(Vector2(5, 2))
		assert_eq(path.size(), expected.size())
		for idx in range(expected.size()):
			assert_eq(path[idx].axial_coords, expected[idx])
		
	func test_line_angled():
		# It's gone all wibbly-wobbly
		var expected = [
			Vector2(1, 2),
			Vector2(2, 2),
			Vector2(2, 3),
			Vector2(3, 3),
			Vector2(4, 3),
			Vector2(4, 4),
			Vector2(5, 4),
		]
		var path = cell.line_to(Vector2(5, 4))
		assert_eq(path.size(), expected.size())
		for idx in range(expected.size()):
			assert_eq(path[idx].axial_coords, expected[idx])
		
	func test_line_edge():
		# Living on the edge between two hexes
		var expected = [
			Vector2(1, 2),
			Vector2(1, 3),
			Vector2(2, 3),
			Vector2(2, 4),
			Vector2(3, 4),
		]
		var path = cell.line_to(Vector2(3, 4))
		assert_eq(path.size(), expected.size())
		for idx in range(expected.size()):
			assert_eq(path[idx].axial_coords, expected[idx])
	
