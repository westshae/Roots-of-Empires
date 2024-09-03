extends Node

@onready var map_display: TextureRect = $MapDisplay

var data
var width
var height

func _ready():
	var image_paths = ["res://MapData/Land.png", "res://MapData/Hills.png", "res://MapData/Mountains.png"]  # Correct file paths
	var sizing_image = load_image(image_paths[0])
	width = sizing_image.get_width()
	height = sizing_image.get_height()
	data = data_extract_from_image_layers(image_paths)

	create_province_map_data_wide()
	paint_provinces()


func create_province_map_data_wide():
	var rng = RandomNumberGenerator.new()
	var positions = []
	
	print("Start")
	var province_count = 0
	while province_count < 1000:
		var random_x: int = rng.randi_range(0, width-1)
		var random_y: int = rng.randi_range(0, height-1)
		if within_bounds(random_x, random_y) && get_data(random_x, random_y)["Land"]:
			set_data(random_x, random_y, "province_id", province_count)
			positions.push_back(Vector2(random_x, random_y))
			province_count += 1
	
	print("Provinces made")
	var total_expanded = 0
	var index = 0
	print(width * height)
	while(index < positions.size()):
		total_expanded += 1
		if total_expanded % 10000 == 0:
			print(total_expanded)
			print(positions.size() - index)
		var position = positions[index]
		index += 1
		var neighbours = get_neighbours(position.x, position.y)
		for neighbour in neighbours:
			var similarity = calculate_similarity(position.x, position.y, neighbour.x, neighbour.y)
			if similarity != 0:
				var cell = get_data(position.x, position.y)
				set_data(neighbour.x, neighbour.y,"province_id", cell["province_id"])
				positions.push_back(neighbour)
	print("Provinces completed")
func get_neighbours(x, y):
	var neighbours = [
		Vector2(x+1, y),
		Vector2(x-1, y),
		Vector2(x, y+1),
		Vector2(x, y-1)
	]
	return neighbours

func calculate_similarity(main_x, main_y, next_x, next_y):
	var score = 0
	if !within_bounds(next_x, next_y):
		return 0
	
	var next_cell = get_data(next_x, next_y)
	var main_cell = get_data(main_x, main_y)
	if !next_cell["Land"]:
		return 0
	#if next_cell["province_id"]:
		#return 0
	if next_cell.has("province_id"):
		return 0

	score += int(next_cell["Hills"] && main_cell["Hills"])
	score += int(!next_cell["Hills"] && !main_cell["Hills"])
	score += int(next_cell["Mountains"] && main_cell["Mountains"])
	score += int(!next_cell["Mountains"] && !main_cell["Mountains"])

	return score
	
func set_data(x:int, y:int, key:String, value):
	if within_bounds(x, y):
		data[y][x][key] = value

func get_data(x:int, y:int):
	if within_bounds(x, y):
		return data[y][x]

func paint_provinces():
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	for y in range(height):
		for x in range(width):
			if data[y][x].has("province_id"):
				var id = data[y][x]["province_id"] + 1
				var rng = RandomNumberGenerator.new()
				rng.seed = id

				var color = Color(rng.randf_range(0.1, 1), rng.randf_range(0.1, 1), rng.randf_range(0.1, 1))
				image.set_pixel(x, y, color)
			else:
				image.set_pixel(x,y, Color(0,0,1))
	var texture = ImageTexture.create_from_image(image)
	map_display.texture = texture
	
func within_bounds(x:int, y:int):
	return x >= 0 and x < width and y >= 0 and y < height

func paint_visible_map_features(image:Image):
	for y in range(height):
		for x in range(width):
			var color = Color(0, 0, 0)  # Default to black (not set)
			if data.has(y) and data[y].has(x):
				var cell = data[y][x]
				#print(cell)
				if cell["Land"]:
					if cell["Hills"]:
						if cell["Mountains"]:
							color = Color(1, 0.7, 0) # Orange
						else:
							color = Color(1, 1, 0)# Yellow
					else:
						color = Color(0, 1, 0)  # Green
				else:
					color = Color(0, 0, 1)  # Blue
			image.set_pixel(x, y, color)
	var texture = ImageTexture.create_from_image(image)
	map_display.texture = texture

func data_extract_from_image_layers(img_paths):
	var data = {}
	for image_path in img_paths:
		var image = load_image(image_path)
		if image == null:
			print("Failed to load image: " + image_path)
			return  # Exit if an image failed to load
		var filename = get_filename_without_extension(image_path)
		
		print("Loaded image: " + filename + " with dimensions: " + str(image.get_width()) + "x" + str(image.get_height()))
		
		for y in range(height):
			if not data.has(y):
				data[y] = {}
			for x in range(width):
				if not data[y].has(x):
					data[y][x] = {}
				
				var pixel = image.get_pixel(x, y)
				data[y][x][filename] = is_black(pixel)
	return data

func load_image(path: String) -> Image:
	var image = Image.new()
	var error = image.load(path)
	if error != OK:
		print("Error opening file: " + path)
		return null  # Return null if there's an error
	return image

func get_filename_without_extension(path: String) -> String:
	var filename = path.get_file()
	return filename.left(filename.rfind("."))

func is_black(color: Color) -> bool:
	return color.r == 0 and color.g == 0 and color.b == 0 and color.a != 0
