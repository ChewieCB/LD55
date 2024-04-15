extends "./abstract_audio_player_pool.gd"

func play(resource: AudioStream, override_bus: String="", randomize_pitch=false) -> AudioStreamPlayer:
	var player = prepare(resource, override_bus)
	if randomize_pitch:
		player.pitch_scale = randf_range(0.8, 1.2)
	else:
		player.pitch_scale = 1
	player.call_deferred("play")
	return player

func stop(resource: AudioStream) -> void:
	for player in busy_players:
		if player.stream == resource:
			player.call_deferred("stop")
