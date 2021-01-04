class_name FPSPlayerAnimator
extends TextureRect


# extend animation states for the player by adding more textures here
export(AnimatedTexture) var idle_animaton
export(AnimatedTexture) var fire_animation

var animation_length = 0
var animation_timer

var current_state

# then add more states here
enum ANIMATION_STATES{
	IDLE = 0,
	FIRING = 1,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	animation_timer = get_node("AnimationTimer")
	animation_timer.one_shot = true


# sets the current animation state, will not interupt an animation, nor will it play the same animation twice
# looping handled by the animation asset itself
# called from the FPSController
# extend by adding new match cases to set the animation
func set_animation_state(var anim_state):
	if animation_timer.time_left == 0 and current_state != anim_state:
		# extend this match case with additional animation textures and enum states
		match anim_state:
			ANIMATION_STATES.IDLE:
				set_texture(idle_animaton)
			ANIMATION_STATES.FIRING:
				set_texture(fire_animation)

		# set the current frame to the first one
		texture.current_frame = 0
		# set the animation length for the counter based on the number of frames for the current animation and it's frame rate
		animation_length = texture.frames / fire_animation.fps
		animation_timer.start(animation_length)
		current_state = anim_state


func _on_AnimationTimer_timeout():
	set_animation_state(ANIMATION_STATES.IDLE)
