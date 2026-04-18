extends Node3D


var rng_game : RandomNumberGenerator = RandomNumberGenerator.new()
var rng_cosmetic : RandomNumberGenerator = RandomNumberGenerator.new()

var texture_dict : Dictionary[String, Texture2D]

func _ready() -> void:
	texture_dict = load_textures_in_folder("res://textures/")
	for i in range(100):
		spawn_creature(Vector3(rng_game.randf_range(-4, 4), 5, rng_game.randf_range(-4, 4)))
	
var creature_prefab : PackedScene = preload("res://scenes/creature.tscn")
func spawn_creature(pos : Vector3) -> N_Creature:
	var instance : N_Creature = creature_prefab.instantiate()
	add_child(instance)
	instance.global_position = pos
	return instance
	
	







class State:
	var name : String = "none"
	func on_change_state(next_state : State) -> State:
		return next_state
	func on_physics_process(delta: float) -> void:
		return
	
class Neutral extends State:
	func _init() -> void:
		name = "Neutral"


class XSignal:
	var name : String = "null_signal"
	
class Converge extends XSignal:
	pass
class Diverge extends XSignal:
	pass
	
	
signal signal_emitted(pos : Vector3, xsignal : XSignal)

var gravity_scale : float = 9.81

var default_gravity_vector : Vector3 = Vector3(0, -1, 0)

var cursor_pos : Vector3

func create_instance(script_path: String, classname: String) -> Object:
	var script = load(script_path)
	if not script:
		return null
	var cls = script.get(classname)
	if not cls:
		return null
	return cls.new()

func camera_raycast(length : float) -> Dictionary:
	if !camera:
		return {}
	var center = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(center)
	var end = origin + camera.project_ray_normal(center) * length
	var query = PhysicsRayQueryParameters3D.create(origin, end, 0b0100)
	query.collide_with_areas = true
	var result = camera.get_world_3d().direct_space_state.intersect_ray(query)
	return result

func parse_float(value : float, precision : float = .1) -> String:
	return str(snappedf(value, precision))
	
func load_textures_in_folder(path: String) -> Dictionary[String, Texture2D]:
	var directory = DirAccess.open(path)
	var textures: Dictionary[String, Texture2D] = {}
	
	if directory:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		
		while file_name != "":
			if !directory.current_is_dir():
				if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
					var texture_path = path + file_name
					var texture = load(texture_path)
					if texture is Texture2D:
						var key = file_name.get_basename()
						textures[key] = texture
					
			file_name = directory.get_next()
		directory.list_dir_end()
	else:
		push_error("An error occurred when trying to access path: " + path)
		
	return textures
	
func try_get_image(dict : Dictionary, key : String) -> Texture2D:
	if dict.has(key):
		var get_this_image = dict.get(key)
		if get_this_image:
			return get_this_image
	return NULL_IMAGE
	
const NULL_IMAGE : Texture2D = preload("res://textures/texture2-1.png")

var camera : Camera3D :
	get:
		return get_viewport().get_camera_3d()
		
func get_random_element_from_array(arr: Array, rng : RandomNumberGenerator):
	var rand_index = rng.randi_range(0, arr.size() - 1)
	return arr[rand_index]

func update_lerp(a, b, t : float, delta : float):
	return b + (a - b) * exp(delta * -t)
	
func get_billboard_basis(node : Node3D) -> Basis:
	if !camera:
		return Basis.IDENTITY
	var direction_to_camera = (camera.global_transform.origin - node.global_position).normalized()
	var look_basis = Basis.looking_at(-direction_to_camera, camera.global_transform.basis.y)
	return look_basis

func find_creature_by_data(data : N_Creature.CreatureData) -> N_Creature:
	var creatures : Array[N_Creature] = get_creatures_by_emotion(null)
	for creature : N_Creature in creatures:
		if creature.data == data:
			return creature
	return null
	
func find_creature_by_stat(stat : D_Stats.Stat) -> N_Creature:
	var creatures : Array[N_Creature] = get_creatures_by_emotion(null)
	for creature : N_Creature in creatures:
		for c_stat in creature.data.stats.values():
			if c_stat == stat:
				return creature
	return null
	
## NULL emotion == all creatures
func get_creatures_by_emotion(emotion : Variant) -> Array[N_Creature]:
	var return_me : Array[N_Creature] = []
	var creatures = Game.get_tree().get_nodes_in_group("creatures")
	for cr in creatures:
		if cr is not N_Creature:
			continue
		var creature = cr as N_Creature
		if !emotion:
			return_me.append(creature)
			continue
		if !is_instance_of(creature.emotion, emotion):
			continue
		return_me.append(creature)
	return return_me
