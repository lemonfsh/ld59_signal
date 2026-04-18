extends RigidBody3D
class_name N_Creature

@onready var sprite : Sprite3D = %Sprite

var data : CreatureData 

var gravity_vector : Vector3 = Game.default_gravity_vector:
	set(value):
		gravity_vector = value
		constant_force = gravity_vector * Game.gravity_scale

func _ready() -> void:
	if !data:
		data = CreatureData.new()
		
	
func _physics_process(delta: float) -> void:
	data.on_physics_proccess(self, delta)
	
@onready var T_on_signal = Game.signal_emitted.connect(on_signal)
func on_signal(pos : Vector3, xsignal : Game.XSignal) -> void:
	data.on_signal(self, pos, xsignal)
	
	
class CreatureData:
	var name : String = "null_name"
	
	var stats : Dictionary[Variant, D_Stats.Stat] = {
		D_Stats.Speed : 				D_Stats.Speed.new(),
		D_Stats.Patience : 				D_Stats.Patience.new(),
		D_Stats.Stability : 			D_Stats.Stability.new(),
	}
	
	func _init() -> void:
		pass
	
	
	func get_stat(type : Variant) -> D_Stats.Stat:
		var get_from_dict = stats.get(type)
		if get_from_dict:
			return get_from_dict
		return D_Stats.Speed.new()
	
	
	
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		movement(me, delta)
	
	var target : Vector3 = Vector3.ZERO
	func movement(me : N_Creature, delta : float):
		var dir : Vector3 = (target - me.global_position).normalized()
		
		var speed = get_stat(D_Stats.Speed).value
		var target_velocity = Vector3(dir.x * speed, dir.y * speed, dir.z * speed)
		
		var set_linear_velocity : Vector3 = Vector3.ZERO
		var lerp_factor : float = .2
		set_linear_velocity = lerp(me.linear_velocity, target_velocity, lerp_factor)
		me.linear_velocity = set_linear_velocity
	
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> void:
		var distance = me.global_position.distance_to(pos)
		if distance < 20.0:
			target = pos
