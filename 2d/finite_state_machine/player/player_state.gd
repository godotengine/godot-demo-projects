extends "res://state_machine/state.gd"

const PLAYER_STATE: Dictionary[StringName, StringName]= {
	&"previous": &"previous",
	&"jump": &"jump",
	&"idle": &"idle",
	&"move": &"move",
	&"stagger": &"stagger",
	&"attack": &"attack",
	&"die": &"die",
	&"dead": &"dead",
	&"walk": &"walk",
}
