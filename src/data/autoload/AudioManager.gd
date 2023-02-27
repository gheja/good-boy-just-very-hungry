extends Node


var _music:AudioStreamPlayer
var _sfx:AudioStreamPlayer

var music_muted = false

func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	
	_sfx = AudioStreamPlayer.new()
	_sfx.bus = "Sfx"
	
	Lib.silence(_sfx.connect("finished", self, "_on_sfx_finished"))
	Lib.silence(_music.connect("finished", self, "_on_music_finished"))
	add_child(_music)
	add_child(_sfx)


func play_music(music_stream: AudioStream) -> void:
	_music.stop()
	_music.stream = music_stream
	_music.play()


func stop_music() -> void:
	_music.stop()


func play_sfx(sfx_stream: AudioStream) -> void:
	AudioServer.set_bus_mute(1, true)
	_sfx.stop()
	_sfx.stream = sfx_stream
	_sfx.play()


func _on_sfx_finished() -> void:
	AudioServer.set_bus_mute(1, music_muted)

func toggle_music_mute():
	music_muted = !music_muted
	AudioServer.set_bus_mute(1, music_muted)
