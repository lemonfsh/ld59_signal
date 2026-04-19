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

	
func _physics_process(delta : float) -> void:
	target_rot = Game.get_billboard_basis(self).get_euler()
	for body in get_colliding_bodies():
		if body is N_Creature:
			var dir = (body.global_position - global_position).normalized()
			body.linear_velocity += dir * 50
	
	var dir = (start_pos - global_position)
	linear_velocity = dir * 9.0
	angular_velocity = Game.update_lerp(angular_velocity, Vector3.ZERO, 10, delta)
	




class Building:
	var name : String = "null_item"
	var ui_image_path : String = "null"
	func on_picked_up(by : N_Creature) -> void:
		return
		
