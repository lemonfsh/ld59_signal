extends Node

var audio_player_group : String = "audio_player"

var audio_sources : int = 20

var music_player : AudioStreamPlayer

func _ready() -> void:
	for i in range(audio_sources):
		var instance = AudioStreamPlayer.new()
		add_child(instance)
		instance.add_to_group(audio_player_group)
		
	var instance = AudioStreamPlayer.new()
	add_child(instance)
	music_player = instance
		

enum AudioName {
	Angry,
	Build,
	Buildattack,
	Hit,
	Ignore,
	Pickup,
	Sad,
	Converge,
	Diverge,
}
var audio_dictionary : Dictionary = {
	AudioName.Angry : preload("res://audio/angry.wav"),
	AudioName.Build : preload("res://audio/build.wav"),
	AudioName.Buildattack : preload("res://audio/buildattack.wav"),
	AudioName.Hit : preload("res://audio/hit.wav"),
	AudioName.Ignore : preload("res://audio/ignore.wav"),
	AudioName.Pickup : preload("res://audio/pickup.wav"),
	AudioName.Sad : preload("res://audio/sad.wav"),
	AudioName.Converge : preload("res://audio/converge.wav"),
	AudioName.Diverge : preload("res://audio/diverge.wav"),
}

var rng_pitch := RandomNumberGenerator.new()

var minimum_volume : float = .01
var total_sound_mult : float = .6
## There are {audio_sources} number of audio sources, when play_sound is called it tries to find one that currently isnt playing anything
## if it does find one, it plays the audio on that one. if it doesnt, the audio doesnt play, and we need more audio sources. 
func play_sound(sound : AudioName, volume : float, pitch_rng_range : float = 0.05):
	var sound_itself = audio_dictionary.get(sound)
	if !sound_itself:
		push_warning("TRIED TO PLAY INVALID SOUND OF TYPE: ", sound)
		return
	
	var poss_sound_players = get_tree().get_nodes_in_group(audio_player_group)
	
	for poss : AudioStreamPlayer in poss_sound_players:
		if !poss.playing:
			poss.stream = sound_itself
			poss.volume_linear = volume * total_sound_mult if volume > minimum_volume else minimum_volume
			poss.pitch_scale = 1.0 + rng_pitch.randf_range(-pitch_rng_range, pitch_rng_range)
			poss.play()
			return
	var poss = poss_sound_players[0]
	poss.stream = sound_itself
	poss.volume_linear = volume * total_sound_mult if volume > minimum_volume else minimum_volume
	poss.pitch_scale = 1.0 + rng_pitch.randf_range(-pitch_rng_range, pitch_rng_range)
	poss.play()
	#push_warning("TRYING TO PLAY MORE THAN: ", audio_sources, " SOUNDS AT A TIME, FAILED TO PLAY SOUND: ", sound)

## Overrides the audio currently playing on the single audio source designated for music
func play_music(music : AudioName, volume : float):
	var sound_itself = audio_dictionary.get(music)
	if !sound_itself:
		push_warning("TRIED TO PLAY INVALID MUSIC OF TYPE: ", music)
		return
	
	music_player.stream = sound_itself
	music_player.volume_linear = volume if volume > minimum_volume else minimum_volume
	music_player.pitch_scale = 1.0
	music_player.play()
	
	
