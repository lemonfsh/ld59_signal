extends N_Abstract
class_name N_Creature

@onready var sprite : Sprite3D = %Sprite
@onready var sprite2 : Sprite3D = %Sprite2

var data : CreatureData 

var gravity_vector : Vector3 = Game.default_gravity_vector:
	set(value):
		gravity_vector = value
		constant_force = gravity_vector * Game.gravity_scale

func _ready() -> void:
	gravity_vector = Game.default_gravity_vector
	
	if !data:
		data = Player.new()
	data.reset_target(self)
	data.name = Game.get_random_creature_name()
	if !emotion:
		emotion = Content.new()
		
	data.on_ready(self)
		
var target_rot : Vector3 = Vector3.ZERO
func _process(delta : float):
	angular_velocity = Vector3.ZERO
	sprite.global_rotation = Game.update_lerp(sprite.global_rotation, target_rot, 3, delta)
	sprite2.global_rotation = sprite.global_rotation
	
func _physics_process(delta : float) -> void:
	target_rot = Game.get_billboard_basis(self).get_euler()
	data.on_physics_proccess(self, delta)
	emotion.on_physics_proccess(self, delta)
	control_item(delta)

var dying : bool = false
func kill_me() -> void:
	if dying:
		return
	Game.creature_died.emit(global_position, self)
	dying = true
	data.on_death(self)
	Particle.spawn_particle(Particle.ParticleType.Die, global_position)
	if item_picked_up:
		item_picked_up.picked_up_by = null
		item_picked_up = null
	queue_free()

@onready var T_on_someone_died = Game.creature_died.connect(on_someone_died)
func on_someone_died(pos : Vector3, creature : N_Creature) -> void:
	data.on_someone_died(self, pos, creature)

@onready var T_on_signal = Game.signal_emitted.connect(on_signal)
func on_signal(pos : Vector3, xsignal : Game.XSignal) -> void:
	data.on_signal(self, pos, xsignal)
	
	
var item_picked_up : N_Item = null
func on_pickup_item(item : N_Item) -> void:
	data.on_pickup_item(self, item)
	
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
		timer = 3.0
	func on_react_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		activate_me(me)
		Audio.play_sound(Audio.AudioName.Angry, 1.0)
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
		timer = 9.0
		
	func on_react_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		activate_me(me)
		Audio.play_sound(Audio.AudioName.Sad, 1.0)
		return true
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		timer -= delta
		if timer <= 0.0:
			me.change_emotion(Content.new())
			me.data.get_stat(D_Stats.Mood).set_value(100.0)
			
	func on_enter_this_emotion(me : N_Creature) -> void:
		activate_me(me)
		Audio.play_sound(Audio.AudioName.Sad, 1.0)
		me.data.get_stat(D_Stats.Speed).change_value(-9)
	func on_exit_this_emotion(me : N_Creature) -> void:
		me.data.get_stat(D_Stats.Speed).change_value(9)
	
	
	
	
	
	
	
	
	
	
	
	
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
		
	var team_color : Color
	
	func on_ready(me : N_Creature) -> void:
		team_color = Color.RED
		randomize_stats(me, 0, .2)
	
	func randomize_stats(me : N_Creature, inc : float, std : float) -> void:
		var poss_spr1 = [
			Game.try_get_image(Game.texture_dict, "torso (1)"),
			Game.try_get_image(Game.texture_dict, "torso (2)"),
			Game.try_get_image(Game.texture_dict, "torso (3)"),
			Game.try_get_image(Game.texture_dict, "torso (4)"),
			Game.try_get_image(Game.texture_dict, "torso (5)"),
			Game.try_get_image(Game.texture_dict, "torso (6)"),
		]
		var poss_spr2 = [
			Game.try_get_image(Game.texture_dict, "eyes (1)"),
			Game.try_get_image(Game.texture_dict, "eyes (2)"),
			Game.try_get_image(Game.texture_dict, "eyes (3)"),
			Game.try_get_image(Game.texture_dict, "eyes (4)"),
			Game.try_get_image(Game.texture_dict, "eyes (5)"),
			Game.try_get_image(Game.texture_dict, "eyes (6)"),
		]
		me.sprite.texture = Game.get_random_element_from_array(poss_spr1, Game.rng_cosmetic)
		me.sprite2.texture = Game.get_random_element_from_array(poss_spr2, Game.rng_cosmetic)
		me.sprite2.modulate = team_color + Color(Game.rng_cosmetic.randfn(0.0, std), Game.rng_cosmetic.randfn(0.0, std), Game.rng_cosmetic.randfn(0.0, std))
		me.sprite.modulate = team_color + Color(Game.rng_cosmetic.randfn(0.0, std), Game.rng_cosmetic.randfn(0.0, std), Game.rng_cosmetic.randfn(0.0, std))
		get_stat(D_Stats.Health).change_value(Game.rng_game.randfn(inc, std))
		get_stat(D_Stats.Speed).change_value(Game.rng_game.randfn(inc, std))
		get_stat(D_Stats.Patience).change_value(Game.rng_game.randfn(inc, std))
		get_stat(D_Stats.Mood).change_value(Game.rng_game.randfn(inc, std))
		get_stat(D_Stats.Intelligence).change_value(Game.rng_game.randfn(inc, std))
	
	func on_someone_died(me : N_Creature, pos : Vector3, creature : N_Creature) -> void:
		for stat : D_Stats.Stat in stats.values():
			stat.on_someone_died(me, pos, creature)
	
	func get_stat(type : Variant) -> D_Stats.Stat:
		var get_from_dict = stats.get(type)
		if get_from_dict:
			return get_from_dict
		return D_Stats.Speed.new()
	
	
	
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		if me.global_position.y <= -100:
			me.kill_me()
		
		
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
		var max_signal_dist = 15.0
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
			
	func attack(me : N_Creature, victim : N_Creature) -> void:
		if victim.data.invincible_timer > 0.0:
			return
		victim.data.invincible_timer = victim.data.invincibility_time_on_attack
		var dir = (victim.global_position - me.global_position).normalized()
		dir.y *= .02
		var power = 40
		
		victim.linear_velocity += dir * power
		me.linear_velocity += -dir * power
		
		Particle.spawn_particle(Particle.ParticleType.Hit, me.global_position)
		Util.shake(me.sprite, .2, invincibility_time_on_attack)
		Util.expand_shrink(me.sprite, 1.0, invincibility_time_on_attack)
		
		
		
		victim.data.damage_me(victim)

	func damage_me(me : N_Creature) -> void:
		Util.shake(me.sprite, .2, invincibility_time_on_attack)
		Util.expand_shrink(me.sprite, 1.0, invincibility_time_on_attack)
		
		Particle.spawn_particle(Particle.ParticleType.Hit, me.global_position)
		
		get_stat(D_Stats.Health).change_value(-1.0)
		if get_stat(D_Stats.Health).value <= 0.0:
			me.kill_me()
		
	
		
	func on_pickup_item(me : N_Creature, item : N_Item) -> void:
		if !me.item_picked_up and !item.picked_up_by:
			me.item_picked_up = item
			me.item_picked_up.picked_up_by = me
			me.item_picked_up.holding.modulate = team_color
			Util.shake(me.item_picked_up.sprite)
			Audio.play_sound(Audio.AudioName.Pickup, 1.0)
		
	func on_death(me : N_Creature) -> void:
		return
			
class Player extends CreatureData:
	func on_ready(me : N_Creature) -> void:
		team = 0
		team_color = Game.player_color
		randomize_stats(me, 0, .2)
		
class Enemy extends CreatureData:
	
		
	func on_ready(me : N_Creature) -> void:
		team = 1
		team_color = Color.RED
		get_stat(D_Stats.Speed).set_value(3.0)
		randomize_stats(me, 0, .2)
	
	func reset_target(me : N_Creature) -> void:
		return
		
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> void:
		return
		
	
	var target_creature_or_building : N_Abstract = null
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		if me.global_position.y <= -100:
			me.kill_me()
		find_target(me)
		
		#if target_creature_or_building:
			#DebugDraw3D.draw_sphere(target_creature_or_building.global_position, 2.0, Color.GREEN, delta)
			#DebugDraw3D.draw_arrow(me.global_position, target_creature_or_building.global_position, Color.GREEN, 4.0, true, delta)
		check_attack(me)
		
		if target_creature_or_building:
			var raycast = Game.from_raycast_all(me.global_position, target_creature_or_building.global_position, 9999.9)
			if raycast.get("collider") != target_creature_or_building:
				target_creature_or_building = null
				target = Vector3(0, 4, 0)
		movement(me, delta)
		
	func check_attack(me : N_Creature) -> void:
		if !target_creature_or_building:
			return
		var distance = me.global_position.distance_to(target_creature_or_building.global_position)
		
		if target_creature_or_building is N_Creature:
			if distance <= 2.0:
				Audio.play_sound(Audio.AudioName.Hit, 1.0)
				attack(me, target_creature_or_building)
		if target_creature_or_building is N_Building:
			if distance <= 4.0:
				Audio.play_sound(Audio.AudioName.Hit, 1.0)
				attack_building(me, target_creature_or_building)
			

	


	func find_target(me : N_Creature):
		var lowest_dist : float = 9999999999.9
		var closest_target : N_Abstract = null
		var creatures := Game.get_creatures_by_emotion(null)
		var buildings := Game.get_buildings()
		var pot_targets : Array[N_Abstract] = []
		pot_targets.append_array(creatures)
		pot_targets.append_array(buildings)
			
		for e : N_Abstract in pot_targets:
			var dist = e.global_position.distance_to(me.global_position)
			if e is N_Building:
				dist *= 1.5
			if dist >= lowest_dist:
				continue
			if e == me:
				continue
			if e is N_Creature:
				if e.data.team == team:
					continue
			
			lowest_dist = dist
			closest_target = e
			
		if closest_target:
			target_creature_or_building = closest_target
			target = closest_target.global_position
		else:
			target = me.global_position
		
	func on_pickup_item(me : N_Creature, item : N_Item) -> void:
		return
		
	func on_death(me : N_Creature) -> void:
		var rngvalue = Game.rng_game.randf_range(0.0, 1.0)
		if rngvalue < .8:
			Game.spawn_item(me.global_position)
		
	func attack_building(me : N_Creature, victim : N_Building) -> void:
		
		var dir = (victim.global_position - me.global_position).normalized()
		dir.y *= .02
		var power = 40
		
		victim.linear_velocity += dir * power
		me.linear_velocity += -dir * power
		
		Particle.spawn_particle(Particle.ParticleType.Hit, me.global_position)
		Util.shake(me.sprite, .2, invincibility_time_on_attack)
		Util.expand_shrink(me.sprite, 1.0, invincibility_time_on_attack)
		
		
		
		Util.shake(victim.sprite, .2, invincibility_time_on_attack)
		Util.expand_shrink(victim.sprite, 1.0, invincibility_time_on_attack)
		
		Particle.spawn_particle(Particle.ParticleType.Hit, victim.global_position)
		
		victim.health.change_value(-1.0)
		#print(victim.health.value)
		if victim.health.value <= 0.0:
			victim.kill_me()
		
