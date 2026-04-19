extends Camera3D

@onready var inspect : Node3D = %Inspect
var inspect_offset : Vector3 = Vector3(-6, 0, 0)
var inspect_base_pos : Vector3
var inspect_target_pos : Vector3

@onready var main_label : Label3D = %MainLabel
@onready var sub_label : Label3D = %SubLabel
@onready var sub_label2 : Label3D = %SubLabel2
@onready var sub_label3 : Label3D = %SubLabel3
@onready var sub_cam : Camera3D = %SubViewCamera

@onready var daytimer : Sprite3D = %DayTimer
@onready var playerinfo : Node3D = %PlayerInfo
@onready var outline_shader_prefab : Shader = preload("res://script/outline.gdshader")

var inspect_ui_stats : Array[Node3D] = []


func _ready() -> void:
	inspect_base_pos = inspect.position
	allocate_ui_stats()
	
	
func allocate_ui_stats() -> void:
	var maxr = 5
	var ui_stat_size : float = .6
	var ui_stat_increment : float = .4
		
	for i in range(maxr):
		var instance = Game.ui_stat_prefab.instantiate()
		inspect.add_child(instance)
		var offset : Vector3 = Vector3(0.3, 1.2, 0)
		instance.position += (Vector3(0, -ui_stat_increment, 0) * i) + offset
		instance.scale = Vector3.ONE * ui_stat_size
		inspect_ui_stats.append(instance)
		var tooltipsprite : Sprite3D = instance.get_child(1)
		var shader_mat = ShaderMaterial.new()
		shader_mat.shader = outline_shader_prefab
		tooltipsprite.material_override = shader_mat
		
		
		
func _physics_process(delta: float) -> void:
	inspect_target_pos = inspect_base_pos if !Game.inspect_enabled else inspect_base_pos + inspect_offset
	set_subview_cam()
	set_day_timer()
	
	sub_label2.text = "Day: " + str(Game.day) +  "\nGlorbles left: " + str(Game.get_creatures_by_team(0).size())
	sub_label3.text = "\n\bBuilding Status:\n " + Game.building_status
func _process(delta: float) -> void:
	inspect.position = Game.update_lerp(inspect.position, inspect_target_pos, 10, delta)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect"):
		var hover_over = Game.camera_raycast_all(99)
		var collider = hover_over.get("collider")
		if !collider:
			Game.inspect_enabled = false
			return
		
		if collider as N_Creature:
			inspect_creature(collider)
			return
		if collider as N_Item:
			inspect_item(collider)
			return
		if collider as N_Building:
			inspect_building(collider)
			return
		return
		


func set_day_timer() -> void:
	var shader = daytimer.material_override as ShaderMaterial
	shader.set_shader_parameter("value", Game.day_progress)

var target_cam_pos : Sprite3D

func set_subview_cam() -> void:
	var offset : Vector3 = Vector3(0, 1, 0)
	if !target_cam_pos:
		return
	#print(target_cam_pos.global_transform.basis.z)
	#var dir = target_cam_pos.global_transform.basis.z
	sub_cam.global_position = target_cam_pos.global_position + offset
	#sub_cam.quaternion = target_cam_pos.quaternion



func inspect_creature(creature : N_Creature) -> void:
	Game.inspect_enabled = true
	main_label.text = "name: " + creature.data.name.substr(1)
	sub_label.text = "emotion: " + creature.emotion.name
	target_cam_pos = creature.sprite
	
	for stat in inspect_ui_stats:
		stat.visible = false
		
	var stats = creature.data.stats.values()
	for i in range(stats.size()):
		configure_ui_stat(inspect_ui_stats[i], stats[i])
		
	return
	
func inspect_item(item : N_Item) -> void:
	Game.inspect_enabled = true
	main_label.text = item.data.name
	sub_label.text = item.data.desc
	target_cam_pos = item.sprite
	for stat in inspect_ui_stats:
		stat.visible = false
	return
	
func inspect_building(building : N_Building) -> void:
	Game.inspect_enabled = true
	main_label.text = "Building"
	sub_label.text = building.get_desc()
	target_cam_pos = building.sprite
	for stat in inspect_ui_stats:
		stat.visible = false
	return
	
func configure_ui_stat(ui_stat : Node3D, stat : D_Stats.Stat) -> void:
	ui_stat.visible = true
	# bad way to do this
	var tooltiptext : Label3D = ui_stat.get_child(0)
	tooltiptext.text = stat.format_as_string()
	
	
	
	var tooltipsprite : Sprite3D = ui_stat.get_child(1)
	var shader = tooltipsprite.material_override as ShaderMaterial
	shader.set_shader_parameter("sprite_texture", Game.try_get_image(Game.texture_dict, stat.ui_image_path))
	shader.set_shader_parameter("glowSize", 4)
	shader.set_shader_parameter("line_color", Color.WHITE)
	
	var tooltiptip : N_Tooltip = tooltipsprite.get_child(0)
	tooltiptip.stat = stat
