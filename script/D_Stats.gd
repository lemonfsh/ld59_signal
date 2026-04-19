extends Node
class_name D_Stats


# SPEED = HOW FAST THEY MOVE
# LUCK = HOW LUCKY (?)
# PATIENCE = ON SIGNAL AFFECTS MOOD
# MOOD = BELOW 0 CHANGE MOOD TO ANGRY, ABOVE 200 CHANGE MOOD TO SAD
# INTELLIGENCE = LOW INT IGNORES SIGNALS SOMETIMES
#

class Stat:
	const BASE_PATH : String = "res://textures/"
	var ui_image_path : String = "null"
	func display_me() -> bool:
		return true
	signal value_changed
	var base_value : float
	var value : float 
	var temporary_value_delta : float = 0.0
			
	func change_value(delta : float) -> void:
		set_value(value + delta)
	func set_value(new_value : float) -> void:
		value = new_value
		value_changed.emit()
		
	#func change_temp_value(delta : float) -> void:
		#change_value(delta)
		#temporary_value_delta -= delta
		#
	#func reset_temp_value() -> void:
		#change_value(temporary_value_delta)
		#temporary_value_delta = 0.0
	
	func activate_me() -> void:
		var me : N_Creature = Game.find_creature_by_stat(self)
		if !me:
			return
		var offset : Vector3 = Vector3(0, 1, 0)
		var load_me = Game.try_get_image(Game.texture_dict, ui_image_path)
		var log : N_Log = Util.log_this("", me.global_position + offset, Color.WHITE, .2, 1, load_me)
		Util.shake(log.sprite)
		
	func format_as_string() -> String:
		return Game.parse_float(value)

	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		return true
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		pass
		
class Health extends Stat:
	func display_me() -> bool:
		return false
	func _init() -> void:
		ui_image_path = "heart"
		value = 3.0
		
class Speed extends Stat:
	func _init() -> void:
		ui_image_path = "wing"
		value = 10.0

class Patience extends Stat:
	func _init() -> void:
		ui_image_path = "patience"
		base_value = 20.0
		value = 10.0
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		me.data.get_stat(Mood).change_value(-(base_value - value))
		return true
		
class Mood extends Stat:
	func _init() -> void:
		ui_image_path = "mood"
		value = 100.0
	func set_value(new_value : float) -> void:
		value = new_value
		if new_value <= 0.0:
			var me : N_Creature = Game.find_creature_by_stat(self)
			if me and me.emotion is N_Creature.Content:
				var chance = Game.rng_game.randf_range(0.0, me.data.get_stat(D_Stats.Patience).base_value)
				if chance > me.data.get_stat(D_Stats.Patience).value:
					me.change_emotion(N_Creature.Angry.new())
				else:
					value = 150
		if new_value >= 200.0:
			var me : N_Creature = Game.find_creature_by_stat(self)
			if me and me.emotion is N_Creature.Content and Game.game_started:
				var chance = Game.rng_game.randf_range(0.0, me.data.get_stat(D_Stats.Patience).base_value)
				if chance > me.data.get_stat(D_Stats.Patience).value:
					me.change_emotion(N_Creature.Sad.new())
				else:
					value = 150
		value_changed.emit()
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		change_value(.18)

class Intelligence extends Stat:
	func _init() -> void:
		ui_image_path = "confused"
		base_value = 100.0
		value = 95.0
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		var rng_value = Game.rng_game.randf_range(0, 100.0)
		if (base_value - value) > rng_value:
			Audio.play_sound(Audio.AudioName.Ignore, 1.0)
			activate_me()
			return false 
		return true
