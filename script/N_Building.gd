extends RigidBody3D
class_name N_Building

@onready var sprite : Sprite3D = %Sprite

var data : Building

var start_pos : Vector3

var made_from : Array[N_Item.Item] = []

func _ready() -> void:
	if !data:
		data = Building.new()
	start_pos = global_position
		
var target_rot : Vector3 = Vector3.ZERO

func _process(delta : float):
	sprite.global_rotation = Game.update_lerp(sprite.global_rotation, target_rot, 3, delta)


var attack_timer : float = 5.0
func _physics_process(delta : float) -> void:
	target_rot = Game.get_billboard_basis(self).get_euler()
	for body in get_colliding_bodies():
		if body is N_Creature:
			var dir = (body.global_position - global_position).normalized()
			body.linear_velocity += dir * 50
			
	var dir = (start_pos - global_position)
	linear_velocity = dir * 9.0
	angular_velocity = Game.update_lerp(angular_velocity, Vector3.ZERO, 10, delta)
	
	attack_timer -= delta
	if attack_timer <= 0:
		attack_timer = 5.0
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
	Util.shake(sprite)
	Util.expand_shrink(sprite, .2, .2)
	return



class Building:
	var name : String = "null_item"
	var ui_image_path : String = "null"
	func on_picked_up(by : N_Creature) -> void:
		return
	
		
		
