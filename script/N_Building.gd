extends N_Abstract
class_name N_Building

@onready var sprite : Sprite3D = %Sprite

var data : Building

var start_pos : Vector3

var made_from : Array[N_Item.Item] = []

var health : D_Stats.Health = D_Stats.Health.new()

func kill_me() -> void:
	Particle.spawn_particle(Particle.ParticleType.Die, global_position)
	on_death_made_from()
	queue_free()
	
func _ready() -> void:
	if !data:
		data = Building.new()
	start_pos = global_position
	health.set_value(10.0)
	process_made_from()
		
	var rand_sprites = [
		Game.try_get_image(Game.texture_dict, "BUILD1"),
		Game.try_get_image(Game.texture_dict, "BUILD2"),
		Game.try_get_image(Game.texture_dict, "BUILD3"),
		Game.try_get_image(Game.texture_dict, "BUILD4"),
	]
	sprite.texture = Game.get_random_element_from_array(rand_sprites, Game.rng_cosmetic)
		
func process_made_from() -> void:
			
	for cr in Game.get_creatures_by_team(0):
		for item in made_from:
			item.increase_stat(cr)

func get_desc() -> String:
	var counts : Dictionary = {
		N_Item.Wood : 0,
		N_Item.Stone : 0,
		N_Item.Metal : 0,
	}
	
	for item in made_from:
		if item is N_Item.Wood:
			counts[N_Item.Wood] += 1
		if item is N_Item.Stone:
			counts[N_Item.Stone] += 1
		if item is N_Item.Metal:
			counts[N_Item.Metal] += 1
	
	var str = ""
	str += "Contains: " + str(counts[N_Item.Wood]) + " wood\nfor +" + str(counts[N_Item.Wood] * 1.0) +" intelligence\n\n"
	str += "Contains: " + str(counts[N_Item.Stone]) + " stone\nfor +" + str(counts[N_Item.Stone] * .5) +" patience\n\n"
	str += "Contains: " + str(counts[N_Item.Metal]) + " metal\nfor +" + str(counts[N_Item.Metal] * .5) +" speed\n"
	return str

func on_death_made_from() -> void:
	for cr in Game.get_creatures_by_team(0):
		for item in made_from:
			item.decrease_stat(cr)
		
		
var target_rot : Vector3 = Vector3.ZERO

func _process(delta : float):
	sprite.global_rotation = Game.update_lerp(sprite.global_rotation, target_rot, 3, delta)

var time_per_attack : float = 1.0
var attack_timer : float = 1.5
func _physics_process(delta : float) -> void:
	target_rot = Game.get_billboard_basis(self).get_euler()
	for body in get_colliding_bodies():
		if body is N_Creature:
			var dir = (body.global_position - global_position).normalized()
			dir.y = 0
			body.linear_velocity += dir * 50
			
	var dir = (start_pos - global_position)
	linear_velocity = dir * 9.0
	angular_velocity = Game.update_lerp(angular_velocity, Vector3.ZERO, 10, delta)
	
	attack_timer -= delta
	if attack_timer <= 0:
		attack_timer = time_per_attack
		attack()
		
func attack() -> void:
	var creatures : Array[N_Creature] = Game.get_creatures_by_emotion(null)
	var enemy_creatures : Array[N_Creature]
	for creature in creatures:
		if creature.data.team == 1:
			enemy_creatures.append(creature)
		
	if enemy_creatures.size() <= 0:
		return
	var rand_chosen_cr : N_Creature = Game.get_random_element_from_array(enemy_creatures, Game.rng_game)
	rand_chosen_cr.data.damage_me(rand_chosen_cr)
	
	var offset : Vector3 = Vector3(0, 4, 0)
	var particle : N_Particle = Particle.spawn_particle(Particle.ParticleType.BuildingAttacked, global_position + offset)
	particle.look_at(rand_chosen_cr.global_position)
	particle.rotate_y(90)
	
	Particle.spawn_particle(Particle.ParticleType.BuildingAttacked, rand_chosen_cr.global_position + offset)
	
	Audio.play_sound(Audio.AudioName.Buildattack, 1.0)
	
	Util.shake(sprite)
	Util.expand_shrink(sprite, .2, .2)
	return



class Building:
	var name : String = "null_item"
	var ui_image_path : String = "null"
	func on_picked_up(by : N_Creature) -> void:
		return
	
		
		
