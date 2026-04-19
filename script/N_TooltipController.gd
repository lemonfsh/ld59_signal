extends Node


@onready var tooltiptext : Label3D = %Tooltiptext

func _physics_process(delta: float) -> void:
	var raycast = Game.camera_raycast_all(99)
	var collider = raycast.get("collider")
	if !collider:
		tooltiptext.text = ""
		return
	if collider is N_Tooltip:
		var offset : Vector3 = Vector3(-2, -3, 0)
		if collider.stat:
			tooltiptext.text = collider.stat.desc
		else:
			tooltiptext.text = "null stat"
		tooltiptext.global_position = collider.global_position + offset
		return
	tooltiptext.text = ""
