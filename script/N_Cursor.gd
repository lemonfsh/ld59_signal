extends Node3D
class_name N_Cursor
@warning_ignore_start("unused_parameter")
@warning_ignore_start("unused_variable")
@onready var sprite : Sprite3D = %Sprite



var sprites = [
	preload("res://textures/cursor1.png"),
	preload("res://textures/cursor2.png"),
	preload("res://textures/cursor3.png")
]
enum CursorType {
	Normal,
	Hovering,
	Holding,
}

var type : CursorType = CursorType.Normal

var mouse_delta := Vector2.ZERO
var prev_mouse_pos := Vector2.ZERO
var tilt := Vector2(0, 0)


func _ready() -> void:
	sprite.offset = Vector2(sprite.texture.get_size().x / 2, -sprite.texture.get_size().y / 2)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		type = CursorType.Holding
		var raycast = Game.camera_raycast(999.9)
		var collider = raycast.get("collider") as Node
		if collider:
			Game.inspect_enabled = false
			var pos = raycast.get("position")
			pos.y = 4.0
			Game.signal_emitted.emit(pos, Game.Converge.new())
			Audio.play_sound(Audio.AudioName.Converge, .1)
			Particle.spawn_particle(Particle.ParticleType.Converge, pos)
	if event.is_action_released("leftclick"):
		type = CursorType.Normal
		
	if event.is_action_pressed("rightclick"):
		type = CursorType.Holding
		var raycast = Game.camera_raycast(999.9)
		var collider = raycast.get("collider") as Node
		if collider:
			Game.inspect_enabled = false
			var pos = raycast.get("position")
			pos.y = 4.0
			Game.signal_emitted.emit(pos, Game.Diverge.new())
			Audio.play_sound(Audio.AudioName.Diverge, .1)
			Particle.spawn_particle(Particle.ParticleType.Diverge, pos)
	if event.is_action_released("rightclick"):
		type = CursorType.Normal
	
func _process(delta: float) -> void:
	cursor_animation(delta)
	
func _physics_process(delta : float) -> void:
	calculate_cursor_anim_vars(delta)
	Game.cursor_pos = global_position

	
func calculate_cursor_anim_vars(delta : float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_delta = mouse_pos - prev_mouse_pos
	prev_mouse_pos = mouse_pos
	
	tilt += mouse_delta * .003
	tilt = Game.update_lerp(tilt, Vector2(0, 0), 4, delta)
	
var selection_distance = 4.0

func cursor_animation(delta : float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = Game.camera
	
	
	
	var target_pos = (
		camera.project_ray_origin(mouse_pos) 
		+ camera.project_ray_normal(mouse_pos) 
		* selection_distance)
	global_position = target_pos
	
	
	
	
	var camera_basis = camera.global_transform.basis
	var camera_right = camera_basis.x
	var camera_up = camera_basis.y
	
	var direction_to_camera = (camera.global_transform.origin - global_position).normalized()
	
	var look_basis = Basis.looking_at(-direction_to_camera, camera_up)
	
	var cam_right = camera.global_transform.basis.x
	var cam_up = camera.global_transform.basis.y
	
	var pitch = tilt.y   
	var roll  = tilt.x   
	
	var final_dir = direction_to_camera.rotated(cam_right, pitch).normalized()
	
	var z = final_dir
	var desired_up = cam_up - cam_up.project(z)
	var x = desired_up.cross(z).normalized()
	var y = z.cross(x)
	var base_basis = Basis(x, y, z)
	
	var roll_rotation = Basis().rotated(Vector3(0, 0, 1), roll)
	var final_basis = base_basis * roll_rotation
	sprite.transform.basis = final_basis
	sprite.texture = sprites[type]













	
