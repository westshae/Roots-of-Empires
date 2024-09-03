extends Node2D

# Declare the child nodes
@onready var polygon2d: Polygon2D = $Polygon2D
@onready var collision_polygon2d: CollisionPolygon2D = $CollisionPolygon2D

func _ready():
	# Copy the shape of Polygon2D to CollisionPolygon2D
	update_collision_shape()

func update_collision_shape():
	# Get the polygon points from Polygon2D
	var points: PackedVector2Array = polygon2d.polygon
	
	# Assign the points to the CollisionPolygon2D
	collision_polygon2d.polygon = points
