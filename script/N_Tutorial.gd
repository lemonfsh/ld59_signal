extends Node3D


@onready var tutorialtext : Label3D = %TutorialText
@onready var tutorialimage : Sprite3D = %TutorialImage

var tutorial_index : int = 0

var tutorial_texts : Array[String] = [
	"These are your GLORBLES.\n \nSignal to them where to go with\nLEFT CLICK\nSignal to them where to avoid with\nRIGHT CLICK\n \nPress SPACE to continue",
	"Your glorbles have EMOTIONS.\n \nSignal them too much and\ntheyll become ANGRY and unresponsive",
	"Signal them too little and\ntheyll become SAD and slow.",
	"They are also sometimes\ntoo dumb to understand you,\nand youll be ignored",
	"Your glorbles have STATS\nthat affect their EMOTIONS\n \nUse MIDDLE CLICK to inspect them",
	"Your glorbles pick up ITEMS when\nthey get close to one\n \nIf ALL glorbles that hold items are\nclose enough to each other,\ntheyll start to build a BUILDING",
	"Enemy glorbles will come every day.\nYour buildings will protect your glorbles against them\n \nThey are defenseless without buildings\n \nGood luck."
]

var tutorial_images : Array[Texture2D] = [
	null,
	Game.try_get_image(Game.texture_dict, "angry"),
	Game.try_get_image(Game.texture_dict, "sad"),
	Game.try_get_image(Game.texture_dict, "confused"),
	null,
	Game.try_get_image(Game.texture_dict, "hammer"),
	null,
]

func _ready() -> void:
	tutorialtext.text = tutorial_texts[tutorial_index]
	tutorialimage.texture = tutorial_images[tutorial_index]
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		if Game.game_started:
			return
		tutorial_index += 1
		if tutorial_index >= tutorial_texts.size():
			Game.game_started = true
			visible = false
			
			var cr = Game.get_creatures_by_team(0)
			for c in cr:
				c.data.get_stat(D_Stats.Mood).set_value(100)
			return
		tutorialtext.text = tutorial_texts[tutorial_index]
		tutorialimage.texture = tutorial_images[tutorial_index]
