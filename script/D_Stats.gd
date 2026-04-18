extends Node
class_name D_Stats


# SPEED = HOW FAST THEY MOVE
# LUCK = HOW LUCKY (?)
# PATIENCE = ON SIGNAL OR OTHER AFFECTS MOOD
# MOOD = BELOW 0 CHANGE MOOD TO SOMETHING
# INTELLIGENCE = LOW INT IGNORES SIGNALS SOMETIMES
#
# SIGNAL = POINT TO AREA, THEN TELL THEM WHAT TO DO

class Stat:
	const BASE_PATH : String = "res://textures/"
	var ui_image_path : String = "null"
	func display_me() -> bool:
		return true
	signal value_changed
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
		
	func format_as_string() -> String:
		return Game.parse_float(value)

	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		return true
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		pass
class Speed extends Stat:
	func _init() -> void:
		ui_image_path = "wing"
		value = 10.0

class Patience extends Stat:
	var base_mood_subtract = 20.0
	func _init() -> void:
		ui_image_path = "wing"
		value = 10.0
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		me.data.get_stat(Mood).change_value(-(base_mood_subtract - value))
		print("mood changed ", me.data.get_stat(Mood).value)
		return true
		
class Mood extends Stat:
	func _init() -> void:
		ui_image_path = "wing"
		value = 100.0
	func set_value(new_value : float) -> void:
		value = new_value
		if new_value <= 0.0:
			var me : N_Creature = Game.find_creature_by_stat(self)
			if me:
				me.change_emotion(N_Creature.Angry.new())
		value_changed.emit()
	func on_physics_proccess(me : N_Creature, delta : float) -> void:
		value += .2

class Intelligence extends Stat:
	var max_int_sub := 100.0
	func _init() -> void:
		ui_image_path = "wing"
		value = 99.0
	func on_signal(me : N_Creature, pos : Vector3, xsignal : Game.XSignal) -> bool:
		var rng_value = Game.rng_game.randf_range(0, 100.0)
		if (max_int_sub - value) > rng_value:
			print("didnt listen")
			return false 
		return true
