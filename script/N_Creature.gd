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
	if !emotion:
		emotion = Content.new()
		
var target_rot : Vector3 = Vector3.ZERO
func _process(delta : float):
	sprite.global_rotation = Game.update_lerp(sprite.global_rotation, target_rot, 3, delta)
	
func _physics_process(delta : float) -> void:
	target_rot = Game.get_billboard_basis(self).get_euler()
	data.on_physics_proccess(self, delta)
	emotion.on_physics_proccess(self, delta)
	
@onready var T_on_signal = Game.signal_emitted.connect(on_signal)
func on_signal(pos : Vector3, xsignal : Game.XSignal) -> void:
	data.on_signal(self, pos, xsignal)
	
	
	
	
	
	
	
	
var emotion : Emotion

func change_emotion(next : Emotion) -> void:
	emotion.on_exit_this_emotion(self)
	emotion = next
	emotion.on_enter_this_emotion(self)
	
class Emotion:
	var name : String = "null_emotion"
	var ui_image_path : String = "null"
	func on_react_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		return true
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		return
	func activate_me(me : N_Creature) -> void:
		var offset : Vector3 = Vector3(0, 1, 0)
		var load_me = Game.try_get_image(Game.texture_dict, ui_image_path)
		var log : N_Log = Util.log_this("", me.global_position + offset, Color.WHITE, .2, .5, load_me)
		Util.shake(log.sprite)
	func on_exit_this_emotion(me : N_Creature) -> void:
		return
	func on_enter_this_emotion(me : N_Creature) -> void:
		return
class Content extends Emotion:
	func _init() -> void:
		name = "Content"
	
class Angry extends Emotion:
	var timer : float
	func _init() -> void:
		name = "Angry"
		ui_image_path = "angry"
		timer = 5.0
	func on_react_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		activate_me(me)
		me.data.reset_target(me)
		return false
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		timer -= delta
		if timer <= 0.0:
			me.change_emotion(Content.new())
			me.data.get_stat(D_Stats.Mood).change_value(100.0)
	
class Sad extends Emotion:
	var timer : float
	func _init() -> void:
		name = "Sad"
		ui_image_path = "sad"
		timer = 5.0
	func on_react_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		activate_me(me)
		return true
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		timer -= delta
		if timer <= 0.0:
			me.change_emotion(Content.new())
			me.data.get_stat(D_Stats.Mood).change_value(100.0)
			
	func on_exit_this_emotion(me : N_Creature) -> void:
		me.data.get_stat(D_Stats.Speed).change_value(-5)
	func on_enter_this_emotion(me : N_Creature) -> void:
		me.data.get_stat(D_Stats.Speed).change_value(5)
	
	
	
	
	
	
	
	
	
	
	
class CreatureData:
	var name : String = "null_name"
	
	var stats : Dictionary[Variant, D_Stats.Stat] = {
		D_Stats.Speed : 				D_Stats.Speed.new(),
		D_Stats.Patience : 				D_Stats.Patience.new(),
		D_Stats.Mood : 					D_Stats.Mood.new(),
		D_Stats.Intelligence : 			D_Stats.Intelligence.new(),
	}
	
	func _init() -> void:
		pass
	
	
	func get_stat(type : Variant) -> D_Stats.Stat:
		var get_from_dict = stats.get(type)
		if get_from_dict:
			return get_from_dict
		return D_Stats.Speed.new()
	
	
	
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		for stat : D_Stats.Stat in stats.values():
			stat.on_physics_proccess(me, delta)
		movement(me, delta)
	
	func reset_target(me : N_Creature) -> void:
		target = me.global_position
	
	var target : Vector3 = Vector3.ZERO
	func movement(me : N_Creature, delta : float):
		var dir : Vector3 = (target - me.global_position).normalized()
		
		var speed = get_stat(D_Stats.Speed).value
		var target_velocity = Vector3(dir.x * speed, dir.y * speed, dir.z * speed)
		
		var set_linear_velocity : Vector3 = Vector3.ZERO
		var lerp_factor : float = .2
		set_linear_velocity = lerp(me.linear_velocity, target_velocity, lerp_factor)
		me.linear_velocity = set_linear_velocity
		
		var distance_to_target = me.global_position.distance_to(target)
		if distance_to_target <= 1.0:
			reset_target(me)
	
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> void:
		var distance = me.global_position.distance_to(pos)
		var max_signal_dist = 10.0
		if distance > max_signal_dist:
			return
			
		var can_pass : bool = true
		for stat : D_Stats.Stat in stats.values():
			can_pass = stat.on_signal(me, pos, xsignal)
			if !can_pass:
				return
		if !me.emotion.on_react_signal(me, pos, xsignal):
			return
		
		if xsignal is Game.Converge:
			target = pos
		if xsignal is Game.Diverge:
			var dir = -(pos - me.global_position).normalized()
			dir *= (max_signal_dist - distance)
			dir.y = -0.1
			target = me.global_position + dir
