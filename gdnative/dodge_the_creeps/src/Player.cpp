#include "Player.h"

#include <Input.hpp>
#include <CollisionShape2D.hpp>

using namespace godot;

void Player::_register_methods()
{
    register_property<Player, int>("speed", &Player::speed, 400);
    register_method("_ready", &Player::_ready);
    register_method("_process", &Player::_process);
    register_method("_on_Player_body_entered", &Player::_on_Player_body_entered);
    register_method("start", &Player::start);

    register_signal<Player>("hit");
}

Player::Player()
{
}

Player::~Player()
{
}

void Player::_init()
{
}

void Player::_ready()
{
    _animation_sprite = static_cast<AnimatedSprite*>(get_node("AnimatedSprite"));
    _screen_size = get_viewport_rect().size;
	hide();
}

void Player::_process(float delta)
{
    Input* input = Input::get_singleton();
    Vector2 velocity;
	if (input->is_action_pressed("ui_right"))
	{
        velocity.x += 1;
    }
	if (input->is_action_pressed("ui_left"))
	{
        velocity.x -= 1;
    }
	if (input->is_action_pressed("ui_up"))
	{
        velocity.y -= 1;
    }
	if (input->is_action_pressed("ui_down"))
	{
        velocity.y += 1;
    }
	if (velocity.length() > 0)
    {
		velocity = velocity.normalized() * speed;
		_animation_sprite->play();
    }
	else
    {
		_animation_sprite->stop();
    }

    Vector2 position = get_position();
	position += velocity * delta;
	position.x = CLAMP(position.x, 0, _screen_size.x);
	position.y = CLAMP(position.y, 0, _screen_size.y);
    set_position(position);

	if (velocity.x != 0)
    {
		_animation_sprite->set_animation("right");
		_animation_sprite->set_flip_v(false);
		_animation_sprite->set_flip_h(velocity.x < 0);
    }
	else if (velocity.y != 0)
    {
		_animation_sprite->set_animation("up");
		_animation_sprite->set_flip_v(velocity.y > 0);
    }
}

void Player::_on_Player_body_entered()
{
    hide();
	emit_signal("hit");
	get_node("CollisionShape2D")->set_deferred("disabled", true);
}

void Player::start(Vector2 pos)
{
    set_position(pos);
	show();
	static_cast<CollisionShape2D*>(get_node("CollisionShape2D"))->set_disabled(false);
}