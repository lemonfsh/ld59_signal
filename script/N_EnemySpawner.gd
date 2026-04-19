extends Node


@onready var points : Array[Node3D] = [%Point1, %Point2, %Point3]


func _ready() -> void:
	for i in range(10):
		spawn_enemy_at_rand_point()

func spawn_enemy_at_rand_point() -> void:
	var point : Node3D = Game.get_random_element_from_array(points, Game.rng_game)
	var creature = Game.spawn_creature(point.global_position)
	creature.data = N_Creature.Enemy.new()
