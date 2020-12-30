extends Control

class_name FPSPlayerAnimator

# extend animation states for the player by adding more textures here
export(AnimatedTexture) var idle_animaton;
export(AnimatedTexture) var fire_animation;

var hand_rect;
var animation_length = 0;
var animation_timer = 0;
var animating = false;

# then add more states here
enum ANIMATION_STATES{
	IDLE		= 0,
	FIRING		= 1
}

# Called when the node enters the scene tree for the first time.
func _ready():
	hand_rect = get_node("./Hand");
	pass # Replace with function body.

# sets the current animation state, will not interupt a oneshot animation
# called from the FPSController
func set_animation_state(var anim_state):
	if (!animating):
		# extend this match case with additional animation textures and enum states
		match anim_state:
			ANIMATION_STATES.IDLE:
				hand_rect.set_texture(idle_animaton);
			ANIMATION_STATES.FIRING:
				hand_rect.set_texture(fire_animation);
				animating = true;
	
		# set the current frame to the first one
		hand_rect.texture.current_frame = 0;
		# set the animation length for the counter based on the number of frames for the current animation and it's frame rate 
		animation_length = hand_rect.texture.frames / fire_animation.fps;
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# process mainly used to count down to the animation state resets
	# this is really just for oneshot animations, which most of our animations would be if we had more guns
	# if we wanted to loop another animation til it was interupted, just don't set animating to true in that match case
	if (animating):
		animation_timer += delta;
		if (animation_timer >= animation_length):
			animation_timer = 0;
			animating = false;
			set_animation_state(ANIMATION_STATES.IDLE);
	pass
