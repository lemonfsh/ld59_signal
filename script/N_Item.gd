extends RigidBody3D
class_name N_Item

@onready var sprite : Sprite3D = %Sprite
@onready var holding : Sprite3D = %Holding

var data : Item

var picked_up_by : N_Creature

func _ready() -> void:
	if !data:
		data = Wood.new()
		
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

class Item:
	var name : String = "null_item"
	var ui_image_path : String = "null"
	func on_picked_up(by : N_Creature) -> void:
		return
		
		
class Wood extends Item:
	func _init() -> void:
		ui_image_path = "wood"
class Metal extends Item:
	func _init() -> void:
		ui_image_path = "metal"
class Glass extends Item:
	func _init() -> void:
		ui_image_path = "glass"
		
