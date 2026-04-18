extends Node

@onready var log_prefab : PackedScene = preload("res://scenes/log.tscn")

func log_this(message : String, position : Vector3, color : Color = Color.RED, size : float = 1.0,
	time : float = .5, sprite : Texture2D = null, velocity : Vector2 = Vector2.ZERO) -> N_Log:
	
	var instance : N_Log = log_prefab.instantiate()
	instance.size *= size 
	instance.time = time
	instance.mod_color = color
	instance.texture = sprite
	instance.velocity = vector2_to_plane(velocity)
	add_child(instance)
	instance.global_position = position
	instance.text = message
	return instance
	

func vector2_to_plane(vector2 : Vector2) -> Vector3:
	var z : float = 2.0
	var camera = Game.camera
	var pos_a = (
		camera.project_ray_origin(Vector2.ZERO) 
		+ camera.project_ray_normal(Vector2.ZERO) 
		* z)
	var pos_b = (
		camera.project_ray_origin(-vector2) 
		+ camera.project_ray_normal(-vector2) 
		* z)
	return pos_b - pos_a
	
func shake(target : Sprite3D, intensity : float = 1.0, time : float = .2) -> void:
	var tween = get_tree().create_tween()
	var scale : float = 30 * intensity
	var old_rotation = target.rotation_degrees
	var new_rotation = target.rotation_degrees + Vector3(
		Game.rng_cosmetic.randf_range(-scale, scale),
		Game.rng_cosmetic.randf_range(-scale, scale),
		Game.rng_cosmetic.randf_range(-scale, scale)
		)
	tween.tween_property(target, "rotation_degrees", new_rotation, time).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(target, "rotation_degrees", old_rotation, time).set_trans(Tween.TRANS_BOUNCE)
	
func expand_shrink(target : Sprite3D, intensity : float = 1.0, time : float = .2) -> void:
	var tween = get_tree().create_tween()
	var scale : float = .2 * intensity
	var old_scale = target.scale
	var new_scale = target.scale + Vector3(
		Game.rng_cosmetic.randf_range(-scale, scale),
		Game.rng_cosmetic.randf_range(-scale, scale),
		Game.rng_cosmetic.randf_range(-scale, scale)
		)
	tween.tween_property(target, "scale", new_scale, time).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(target, "scale", old_scale, time).set_trans(Tween.TRANS_BOUNCE)
	
	
func create_timer(time : float) -> Signal:
	var node : Timer = Timer.new()
	add_child(node)
	node.start(time)
	node.timeout.connect(func(): node.queue_free())
	return node.timeout
	
	
	
	
	
	
	
