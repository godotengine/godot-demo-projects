extends Node2D

var _judgment_tween: Tween


func _enter_tree() -> void:
	$Notes.chart = GlobalSettings.selected_chart


func _ready() -> void:
	$Control/SettingsVBox/UseFilteredCheckBox.button_pressed = GlobalSettings.use_filtered_playback
	$Control/SettingsVBox/ShowOffsetCheckBox.button_pressed = GlobalSettings.show_offsets
	$Control/SettingsVBox/MetronomeCheckBox.button_pressed = GlobalSettings.enable_metronome
	$Control/SettingsVBox/InputLatencyHBox/SpinBox.value = GlobalSettings.input_latency_ms
	$Control/SettingsVBox/ScrollSpeedHBox/CenterContainer/HSlider.value = GlobalSettings.scroll_speed
	$Control/ChartVBox/OptionButton.selected = GlobalSettings.selected_chart
	$Control/JudgmentHBox/LJudgmentLabel.modulate.a = 0
	$Control/JudgmentHBox/RJudgmentLabel.modulate.a = 0

	var latency_line_edit: LineEdit = $Control/SettingsVBox/InputLatencyHBox/SpinBox.get_line_edit()
	latency_line_edit.text_submitted.connect(
		func(text: String):
			latency_line_edit.release_focus())

	await get_tree().create_timer(0.5).timeout

	$Conductor.play()
	$Metronome.start()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _update_stats(play_stats: PlayStats) -> void:
	$Control/StatsVBox/PerfectLabel.text = "Perfect: %d" % play_stats.perfect_count
	$Control/StatsVBox/GoodLabel.text = "Good: %d" % play_stats.good_count
	$Control/StatsVBox/MissLabel.text = "Miss: %d" % play_stats.miss_count
	var hit_error_ms := play_stats.mean_hit_error * 1000
	if hit_error_ms < 0:
		$Control/StatsVBox/HitErrorLabel.text = "Avg Error: %+.1f ms (Early)" % hit_error_ms
	else:
		$Control/StatsVBox/HitErrorLabel.text = "Avg Error: %+.1f ms (Late)" % hit_error_ms


func _update_filter_state(use_filter: bool) -> void:
	GlobalSettings.use_filtered_playback = use_filter
	if use_filter:
		$Notes.time_type = Enums.TimeType.FILTERED
	else:
		$Notes.time_type = Enums.TimeType.RAW


func _hit_type_to_string(hit_type: Enums.HitType) -> String:
	match hit_type:
		Enums.HitType.MISS_EARLY:
			return "Too Early..."
		Enums.HitType.GOOD_EARLY:
			return "Good"
		Enums.HitType.PERFECT:
			return "Perfect!"
		Enums.HitType.GOOD_LATE:
			return "Good"
		Enums.HitType.MISS_LATE:
			return "Miss..."
		_:
			assert(false, "Unknown HitType: %s" % hit_type)
			return "Unknown"


func _on_use_filtered_check_box_toggled(toggled_on: bool) -> void:
	_update_filter_state(toggled_on)


func _on_show_offset_check_box_toggled(toggled_on: bool) -> void:
	GlobalSettings.show_offsets = toggled_on


func _on_metronome_check_box_toggled(toggled_on: bool) -> void:
	GlobalSettings.enable_metronome = toggled_on


func _on_note_hit(hit_type: Enums.HitType, hit_error: float) -> void:
	var hit_type_str := _hit_type_to_string(hit_type)
	if GlobalSettings.show_offsets:
		var hit_error_ms := hit_error * 1000
		if hit_error_ms < 0:
			hit_type_str += "\n(Early %+d ms)" % hit_error_ms
		else:
			hit_type_str += "\n(Late %+d ms)" % hit_error_ms
	$Control/JudgmentHBox/LJudgmentLabel.text = hit_type_str
	$Control/JudgmentHBox/RJudgmentLabel.text = hit_type_str

	$Control/JudgmentHBox/LJudgmentLabel.modulate.a = 1
	$Control/JudgmentHBox/RJudgmentLabel.modulate.a = 1

	if _judgment_tween:
		_judgment_tween.kill()
	_judgment_tween = create_tween()
	_judgment_tween.tween_interval(0.2)
	_judgment_tween.tween_property($Control/JudgmentHBox/LJudgmentLabel, "modulate:a", 0, 0.5)
	_judgment_tween.parallel().tween_property($Control/JudgmentHBox/RJudgmentLabel, "modulate:a", 0, 0.5)


func _on_play_stats_updated(play_stats: PlayStats) -> void:
	_update_stats(play_stats)


func _on_song_finished(play_stats: PlayStats) -> void:
	$Control/SongCompleteLabel.show()
	_update_stats(play_stats)


func _on_input_latency_spin_box_value_changed(value: float) -> void:
	var latency_ms := roundi(value)
	GlobalSettings.input_latency_ms = latency_ms
	$Control/SettingsVBox/InputLatencyHBox/SpinBox.get_line_edit().release_focus()


func _on_scroll_speed_h_slider_value_changed(value: float) -> void:
	GlobalSettings.scroll_speed = value
	$Control/SettingsVBox/ScrollSpeedHBox/Label.text = str(roundi(value))


func _on_chart_option_button_item_selected(index: int) -> void:
	if GlobalSettings.selected_chart != index:
		GlobalSettings.selected_chart = index as ChartData.Chart
		get_tree().reload_current_scene()
