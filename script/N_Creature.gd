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
	data.reset_target(self)
	data.name = Game.get_random_creature_name()
	if !emotion:
		emotion = Content.new()
		
var target_rot : Vector3 = Vector3.ZERO
func _process(delta : float):
	angular_velocity = Vector3.ZERO
	sprite.global_rotation = Game.update_lerp(sprite.global_rotation, target_rot, 3, delta)
	
func _physics_process(delta : float) -> void:
	target_rot = Game.get_billboard_basis(self).get_euler()
	data.on_physics_proccess(self, delta)
	emotion.on_physics_proccess(self, delta)
	control_item(delta)

func kill_me() -> void:
	Particle.spawn_particle(Particle.ParticleType.Die, global_position)
	queue_free()

@onready var T_on_signal = Game.signal_emitted.connect(on_signal)
func on_signal(pos : Vector3, xsignal : Game.XSignal) -> void:
	data.on_signal(self, pos, xsignal)
	
	
var item_picked_up : N_Item = null
func on_pickup_item(item : N_Item) -> void:
	if !item_picked_up and !item.picked_up_by:
		item_picked_up = item
		item_picked_up.picked_up_by = self
		Util.shake(item_picked_up.sprite)
	
func control_item(delta : float) -> void:
	if !item_picked_up:
		return
	var target_item_pos = global_position + Vector3(0, 3, 0)
	var dir = (target_item_pos - item_picked_up.global_position)
	item_picked_up.linear_velocity = dir * 9.0
	item_picked_up.angular_velocity = Game.update_lerp(item_picked_up.angular_velocity, Vector3.ZERO, 10, delta)
	
	
	
	
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
			me.data.get_stat(D_Stats.Mood).set_value(100.0)
	
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
			me.data.get_stat(D_Stats.Mood).set_value(100.0)
			
	func on_enter_this_emotion(me : N_Creature) -> void:
		activate_me(me)
		me.data.get_stat(D_Stats.Speed).change_value(-7)
	func on_exit_this_emotion(me : N_Creature) -> void:
		me.data.get_stat(D_Stats.Speed).change_value(7)
	
	
	
	
	
	
	
	
	
	
	
	
class CreatureData:
	var name : String = "null_name"
	
	var stats : Dictionary[Variant, D_Stats.Stat] = {
		D_Stats.Health : 				D_Stats.Health.new(),
		D_Stats.Speed : 				D_Stats.Speed.new(),
		D_Stats.Patience : 				D_Stats.Patience.new(),
		D_Stats.Mood : 					D_Stats.Mood.new(),
		D_Stats.Intelligence : 			D_Stats.Intelligence.new(),
	}
	
	var team : int = 0
	
	func _init() -> void:
		pass
	
	
	func get_stat(type : Variant) -> D_Stats.Stat:
		var get_from_dict = stats.get(type)
		if get_from_dict:
			return get_from_dict
		return D_Stats.Speed.new()
	
	
	
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		invincible_timer -= delta
		invincible_timer = max(-.01, invincible_timer)
		
		for stat : D_Stats.Stat in stats.values():
			stat.on_physics_proccess(me, delta)
		movement(me, delta)
		
		lose_target_timer -= delta
		if lose_target_timer <= 0:
			reset_target(me)
	
	func reset_target(me : N_Creature) -> void:
		target = me.global_position
	
	var lose_target_timer : float = -1.0
	var target : Vector3 = Vector3.ZERO : 
		set(value):
			target = value
			lose_target_timer = 3.0
			
	func movement(me : N_Creature, delta : float):
		
		var dir : Vector3 = (target - me.global_position).normalized()
		
		var speed = get_stat(D_Stats.Speed).value
		var target_velocity = Vector3(dir.x * speed, dir.y * speed, dir.z * speed)
		
		var distance_to_target = me.global_position.distance_to(target)
		if distance_to_target <= 2.0:
			target_velocity = Vector3.ZERO
			
		var set_linear_velocity : Vector3 = Vector3.ZERO
		var lerp_factor : float = .2
		set_linear_velocity = lerp(me.linear_velocity, target_velocity, lerp_factor)
		me.linear_velocity = set_linear_velocity
		
		
	## X > 0 == INVINCIBLE
	var invincible_timer : float = -1.0
	var invincibility_time_on_attack : float = 0.05
	
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> void:
		var distance = me.global_position.distance_to(pos)
		var max_signal_dist = 10.0
		if distance > max_signal_dist:
			return
			
		var can_pass : bool = true
		for stat : D_Stats.Stat in stats.values():
			if !stat.on_signal(me, pos, xsignal):
				can_pass = false
		if !me.emotion.on_react_signal(me, pos, xsignal):
			can_pass = false
			
		if !can_pass:
			return
			
		if xsignal is Game.Converge:
			target = pos
		if xsignal is Game.Diverge:
			var dir = -(pos - me.global_position).normalized()
			dir *= (max_signal_dist - distance)
			dir.y = -0.1
			target = me.global_position + dir
			
			
			
			
			
class Player extends CreatureData:
	pass
class Enemy extends CreatureData:
	func _init() -> void:
		team = 1
	
	func reset_target(me : N_Creature) -> void:
		return
		
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> void:
		return
		
	
	var target_creature : N_Creature = null
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		find_target(me)
		movement(me, delta)
		check_attack(me)
		
	func check_attack(me : N_Creature) -> void:
		if !target_creature:
			return
		var distance = me.global_position.distance_to(target_creature.global_position)
		if distance <= 2.0:
			attack(me, target_creature)
			

	func attack(me : N_Creature, victim : N_Creature) -> void:
		
		if victim.data.invincible_timer > 0.0:
			return
		victim.data.invincible_timer = victim.data.invincibility_time_on_attack
		var dir = (victim.global_position - me.global_position).normalized()
		dir.y *= .02
		var power = 20
		print("attacked ")
		victim.linear_velocity += dir * power
		me.linear_velocity += -dir * power
		Util.shake(me.sprite, .2, invincibility_time_on_attack)
		Util.expand_shrink(me.sprite, 1.0, invincibility_time_on_attack)
		
		victim.data.get_stat(D_Stats.Health).change_value(-1.0)
		if victim.data.get_stat(D_Stats.Health).value <= 0.0:
			victim.kill_me() 


	func find_target(me : N_Creature):
		var lowest_dist : float = 9999999999.9
		var closest_target : N_Creature = null
		for e : N_Creature in Game.get_creatures_by_emotion(null):
			var dist = e.global_position.distance_to(me.global_position)
			if dist >= lowest_dist:
				continue
			if e == me:
				continue
			if e.data.team == team:
				continue
			lowest_dist = dist
			closest_target = e
			
		if closest_target:
			target_creature = closest_target
			target = closest_target.global_position
			
