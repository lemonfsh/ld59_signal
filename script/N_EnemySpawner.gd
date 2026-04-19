extends Node


@onready var points : Array[Node3D] = [%Point1, %Point2, %Point3]


func _ready() -> void:
	Game.start_day.connect(do_day)

func spawn_enemy_at_rand_point() -> N_Creature:
	var point : Node3D = Game.get_random_element_from_array(points, Game.rng_game)
	return Game.spawn_creature(point.global_position, N_Creature.Enemy.new())

func do_day() -> void:
	var num_enemies = min(int(Game.days_scaling) + 5, 20)
	#print(num_enemies)
	for i in range(int(Game.days_scaling) + 5):
		var cr : N_Creature = spawn_enemy_at_rand_point()
		cr.data.randomize_stats(cr, Game.days_scaling - .5, .3)
	
	var repopulate : float = .05
	var player_cr = Game.get_creatures_by_team(0)
	var amount_to_repop = int(float(player_cr.size()) * repopulate)
	
	if amount_to_repop > 0:
		Util.log_this("Glorbles repopulated: " + str(amount_to_repop), Vector3(0, 20, 0), Color.WHITE, 1.0, 3.0, Game.try_get_image(Game.texture_dict, "heart"))
		for i in range(amount_to_repop):
			Game.spawn_creature(Vector3(0, 4, 0), N_Creature.Player.new())
	else:
		Util.log_this("Glorbles didnt repopulated", Vector3(0, 20, 0), Color.WHITE, 1.0, 3.0, Game.try_get_image(Game.texture_dict, "mood"))
	
	pass
