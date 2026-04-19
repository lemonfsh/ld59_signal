extends Label3D
class_name N_Log

@onready var sprite : Sprite3D = %Sprite
var mod_color : Color
var time : float = .4
var texture : Texture2D = null
var velocity : Vector3 = Vector3.ZERO
var size : float = .002
func _ready() -> void:
	pixel_size = size
	sprite.pixel_size = size
	sprite.global_rotation = Game.get_billboard_basis(sprite).get_euler()
	fade_anim()

func fade_anim() -> void:
	if !mod_color:
		mod_color = Color.WHITE
	modulate = mod_color
	if texture:
		sprite.texture = texture
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(mod_color.r, mod_color.g, mod_color.b, 0), time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color(mod_color.r, mod_color.g, mod_color.b, 0), time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "outline_modulate", Color(0, 0, 0, 0), time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	await tween.finished
	queue_free()
	
func _physics_process(delta: float) -> void:
	do_velocity(delta)
	
func do_velocity(delta : float) -> void:
	global_position += velocity
