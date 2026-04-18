extends Node
class_name D_Stats


# SPEED = HOW FAST THEY MOVE
# LUCK = HOW LUCKY (?)
# PATIENCE = HOW MANY SIGNALS CAN IT HANDLE RAPIDLY
# STABILITY = HOW FAST CAN IT CHANGE EMOTION
# 
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
		
	func change_temp_value(delta : float) -> void:
		change_value(delta)
		temporary_value_delta -= delta
		
	func reset_temp_value() -> void:
		change_value(temporary_value_delta)
		temporary_value_delta = 0.0
		
	func format_as_string() -> String:
		return Game.parse_float(value)

	
class Speed extends Stat:
	func _init() -> void:
		ui_image_path = "wing"
		value = 10.0

class Patience extends Stat:
	func _init() -> void:
		ui_image_path = "wing"
		value = 10.0

class Stability extends Stat:
	func _init() -> void:
		ui_image_path = "wing"
		value = 10.0
