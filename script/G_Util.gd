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
	
	
	
static var line_prefab = preload("res://scenes/line.tscn")
func create_line(point_a: Vector3, point_b: Vector3, texture: Texture2D = null, color: Color = Color.WHITE, width: float = 0.05) -> MeshInstance3D:
	var line_mesh = line_prefab.instantiate()
	var box_mesh = BoxMesh.new()
	
	box_mesh.size = Vector3(width, width, 1.0)
	line_mesh.mesh = box_mesh
	line_mesh.top_level = true
	
	add_child(line_mesh)
	
	var midpoint = point_a.lerp(point_b, 0.5)
	var distance = point_a.distance_to(point_b)
	
	line_mesh.global_position = midpoint
	line_mesh.look_at(point_a, Vector3.UP)
	line_mesh.scale = Vector3(1, 1, distance)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	if texture:
		material.albedo_texture = texture
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		material.uv1_scale = Vector3(1, distance, 1)
	
	line_mesh.material_override = material
	
	return line_mesh

func update_line(line: MeshInstance3D, point_a: Vector3, point_b: Vector3):
	var midpoint = point_a.lerp(point_b, 0.5)
	var direction = point_b - point_a
	var distance = direction.length()
	
	line.global_position = midpoint
	line.look_at(midpoint + direction, Vector3.UP)
	line.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(90))
	line.scale = Vector3(1, 1, distance)
	
	
