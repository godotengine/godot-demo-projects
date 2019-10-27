#ifndef PLAYER_H
#define PLAYER_H

#include <Godot.hpp>
#include <Area2D.hpp>
#include <AnimatedSprite.hpp>

#ifndef CLAMP
#define CLAMP(m_a, m_min, m_max) (((m_a) < (m_min)) ? (m_min) : (((m_a) > (m_max)) ? m_max : m_a))
#endif

namespace godot {

class Player: public Area2D {
    GODOT_CLASS(Player, Area2D)

private:
    Vector2 _screen_size;
    AnimatedSprite* _animation_sprite;
public:
    int speed = 400;
public:
    static void _register_methods();

    Player();
    ~Player();

    void _init();

    void _ready();
    void _process(float delta);
    void _on_Player_body_entered();
    void start(Vector2 pos);
};

}

#endif