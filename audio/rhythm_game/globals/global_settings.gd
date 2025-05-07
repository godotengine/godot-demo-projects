extends Node

signal scroll_speed_changed(speed: float)

@export var use_filtered_playback: bool = true

@export var enable_metronome: bool = false
@export var input_latency_ms: int = 20

@export var scroll_speed: float = 400:
	set(value):
		if scroll_speed != value:
			scroll_speed = value
			scroll_speed_changed.emit(value)
@export var show_offsets: bool = false

@export var selected_chart: ChartData.Chart = ChartData.Chart.THE_COMEBACK
