extends RigidBody3D
class_name N_Item

@onready var sprite : Sprite3D = %Sprite
@onready var holding : Sprite3D = %Holding

var data : Item

var picked_up_by : N_Creature

func _ready() -> void:
	if !data:
		data = Game.get_random_element_from_array([Wood.new(), Stone.new(), Metal.new()], Game.rng_game)
	constant_force = Vector3(0, -9.8, 0)
	sprite.texture = Game.try_get_image(Game.texture_dict, data.ui_image_path)
		
var target_rot : Vector3 = Vector3.ZERO
func _process(delta : float):
	sprite.global_rotation = Game.update_lerp(sprite.global_rotation, target_rot, 3, delta)
	holding.global_rotation = sprite.global_rotation
	
func _physics_process(delta : float) -> void:
	holding.visible = false
	if picked_up_by:
		holding.visible = true
	target_rot = Game.get_billboard_basis(self).get_euler()
	#linear_velocity = Vector3.ZERO
	for body in get_colliding_bodies():
		if body is N_Creature:
			body.on_pickup_item(self)


func kill_me() -> void:
	Particle.spawn_particle(Particle.ParticleType.Die, global_position)
	queue_free()

@abstract class Item:
	var stat_value : float = 1.0
	var stat : Variant = D_Stats.Health
	var desc : String = "Nullasd"
	var name : String = "null_item"
	var ui_image_path : String = "null"
	func increase_stat(cr : N_Creature) -> void:
		cr.data.get_stat(stat).change_value(stat_value)
	func decrease_stat(cr : N_Creature) -> void:
		cr.data.get_stat(stat).change_value(-stat_value)
		
class Wood extends Item:
	func _init() -> void:
		name = "Wood"
		ui_image_path = "wood"
		desc = "Increases intelligence of your creatures\nby 1.0 when built"
		stat = D_Stats.Intelligence
		stat_value = 1.0
class Metal extends Item:
	func _init() -> void:
		name = "Metal"
		desc = "Increases speed of your creatures\nby .5 when built"
		ui_image_path = "metal"
		stat = D_Stats.Speed
		stat_value = .5
class Stone extends Item:
	func _init() -> void:
		name = "Stone"
		ui_image_path = "stone"
		desc = "Increases patience of your creatures\nby .5 when built"
		stat = D_Stats.Patience
		stat_value = .5
		
