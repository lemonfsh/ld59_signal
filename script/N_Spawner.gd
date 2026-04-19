extends Node3D






var owned_items : Array[N_Item] = []

func _ready() -> void:
	var va : float = 3.0
	var item_pos = Vector3(Game.rng_game.randf_range(-va, va), 0, Game.rng_game.randf_range(-va, va)) 
	var item = Game.spawn_item(global_position + item_pos)
	
